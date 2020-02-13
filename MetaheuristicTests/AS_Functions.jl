using LightGraphs, MetaGraphs

# A single Ant, has the following properties
# path: The path along the graph, denoted by order of vertices
# source: The source node for this ant
# destination: The destination node for this ant
# cost: The cost of this ants path. Generally generated using edge weight of path
# pheromone: The pheromone to be deposited by this ant. Generally 1/cost
mutable struct Ant
	path::Vector{Int}
	source::Int
	destination::Int
	cost::Real
end

# The Colony, has the following properties
# ants: All the Ants in the Colony
# size: How many Ants are in the Colony
# graph: The original graph
# pheromoneGraph: A structural copy of the original graph, where the weights are the phermone levels
# evaporationRate: The evaporation rate for all trails every iteration
mutable struct Colony
	ants::Vector{Ant}
	size::Int
	mg::MetaGraph
	evaporationrate::Real
end



# Constructs a path for this Ant
function constructpath(ant::Ant,mg::MetaGraph,α::Real,β::Real,γ::Real)

	#Create the new path and visited set for this ant
	current = ant.source
	path = Vector{Int}([current])
	visited = Set{Int}([current])
	cost = 0

	# Keep adding to path while current is not destination
	while current != ant.destination

		# Grab the adjacent nodes of the current node
		adjacent = neighbors(mg,current)

		# Filter these by what is in visited
		adjacent = filter(v -> !(v in visited),adjacent)

		# If adjacent has destination, clearly go to it
		if ant.destination in adjacent
			cost += get_prop(mg,current,ant.destination,:weight)
			current = ant.destination
			push!(path,current)
			continue
		end


		# If there are no available neighbors, this is a deadend
		# Keep this current node in visited (as to not hit this deadend again)
		# and revert current back to previous node. Remove current from path,
		# and decrease cost
		if isempty(adjacent)

			# If this the source node, return false, no path exists
			if current == ant.source return false end

			# Otherwise, backtrack accordingly and update properties
			kill = pop!(path)
			current = last(path)
			cost -= get_prop(mg,current,kill,:weight)
			de = get_prop(mg,kill,:deadend)
			set_prop!(mg,kill,:deadend,de+0.35)
			continue
		end

		# Otherwise, begin to choose an adjacent node
		totalpheromones = 0
		probabilities = zeros(Float64,length(adjacent))
		for i = 1:length(adjacent)
			next = adjacent[i]
			probabilities[i] = get_prop(mg,current,next,:pheromone)^α *
			                   (1/get_prop(mg,current,next,:weight))^β *
							   (1/get_prop(mg,next,:deadend))^γ
			totalpheromones += probabilities[i]
		end
		probabilities /= totalpheromones

		# Pick a vertex based on probabilities, will terminate
		r = rand()
		idx = 1
		while r > probabilities[idx]
			probabilities[idx+1] += probabilities[idx]
			idx += 1
		end

		# Increment cost, update current and add to path and visited
		cost += get_prop(mg,current,adjacent[idx],:weight)
		current = adjacent[idx]
		push!(path,current)
		push!(visited,current)
	end

	# Update the current ants properties
	ant.path = path
	ant.cost = cost

	# Return true since a path was found
	return true
end

# Evaporates pheromones on pheromone graph
function evaporate(mg::MetaGraph,erate::Real)

	# For every edge in the graph, evaporate pheromones
	for edge in edges(mg)
		newpheromone = (1-erate)*get_prop(mg,edge,:pheromone)
		set_prop!(mg,edge,:pheromone,newpheromone)
	end
end

# Lay pheromone down on every path from the ants
function laypheromone(mg::MetaGraph,ants::Vector{Ant},reward::Real,δ::Real)

	# Find the smallest cost of the Ants
	mn = minimum([ant.cost for ant in ants])

	# Iterate the path of every ant, and update the pheromone for that edge
	for ant in ants
		pheromone = (mn^δ)/(ant.cost == mn ? ant.cost*reward : ant.cost)
		for i = 1:length(ant.path)-1
			src = ant.path[i]
			dst = ant.path[i+1]
			currentpheromone = get_prop(mg,src,dst,:pheromone)
			set_prop!(mg,src,dst,:pheromone,currentpheromone+pheromone)
		end
	end
end
