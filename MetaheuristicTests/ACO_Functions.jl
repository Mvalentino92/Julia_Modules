using LightGraphs, SimpleWeightedGraphs, MetaGraphs

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
	pheromone::Real
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
	graph::SimpleWeightedGraph
	pheromonegraph::SimpleWeightedGraph
	evaporationrate::Real
end



# Constructs a path for this Ant
function constructpath(ant::Ant,graph::SimpleWeightedGraph,pgraph::SimpleWeightedGraph,α::Real)

	#Create the new path and visited set for this ant
	current = ant.source
	path = Vector{Int}([current])
	visited = Set{Int}([current])
	cost = 0

	# Keep adding to path while current is not destination
	while current != ant.destination

		# Grab the adjacent nodes of the current node
		adjacent = neighbors(graph,current)

		# Filter these by what is in visited
		adjacent = filter(v -> !(v in visited),adjacent)

		# If there are no available neighbors, this is a deadend
		# Keep this current node in visited (as to not hit this deadend again)
		# and revert current back to previous node. Remove current from path,
		# and decrease cost
		if isempty(adjacent)

			# If this the source node, return false, no path exists
			if current == ant.source return false end

			# Otherwise, backtrack accordingly
			cost -= get_weight(graph,path[end-1],current)
			path = path[1:end-1]
			current = path[end]
			continue
		end

		# Otherwise, begin to choose an adjacent node
		totalpheromones = 0
		probabilities = zeros(Float64,length(adjacent))
		for i = 1:length(adjacent)
			probabilities[i] = get_weight(pgraph,current,adjacent[i])^α
			totalpheromones += probabilities[i]
		end
		
		# Compute the sorted indices and reorder probabilities and adjacent sorted like this
		probabilities /= totalpheromones
		sortedindices = sortperm(probabilities,rev=true)
		probabilities[sortedindices]
		adjacent[sortedindices]

		# Pick a vertex based on probabilities
		r = rand()
		idx = 1
		while idx < length(probabilities) - 1
			if r < probabilities[idx] break
			else
				probabilities[idx+1] += probabilities[idx]
				idx += 1
			end
		end

		# Increment cost, update current and add to path and visited
		cost += get_weight(graph,current,adjacent[idx])
		current = adjacent[idx]
		push!(path,current)
		push!(visited,current)
	end
	
	# Update the current ants properties
	ant.path = path
	ant.cost = cost
	ant.pheromone = 1/cost

	# Return true since a path was found
	return true
end

# Evaporates pheromones on pheromone graph
function evaporate(pgraph::SimpleWeightedGraph,rate::Real)

	# For every edge in the graph, evaporate pheromones
	for edge in edges(pgraph)
		newpheromone = (1-rate)*get_weight(pgraph,edge.src,edge.dst)
		add_edge!(pgraph,edge.src,edge.dst,newpheromone)
	end
end

# Lay pheromone down on every path from the ants
function laypheromone(colony::Colony)

	# Iterate the path of every ant, and update the pheromone for that edge
	for ant in colony.ants
		for i = 1:length(ant.path)-1
			src = ant.path[i]
			dst = ant.path[i+1]
			currentpheromone = get_weight(colony.pheromonegraph,src,dst)
			add_edge!(colony.pheromonegraph,src,dst,currentpheromone+ant.pheromone)
		end
	end
end
