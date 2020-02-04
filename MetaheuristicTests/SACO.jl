include("ACO_Functions.jl")

function saco(graph::SimpleWeightedGraph,source::Int,destination::Int;
	      size::Int=15,evaporationrate::Real=0.35, alpha::Real=0.65,maxiter::Int=1000)
	
	# The NULL Ant
	nullant = Ant([],source,destination,Inf,0)

	# Create and initialize the pheromonegraph with small random values
	pheromonegraph = deepcopy(graph)
	for edge in edges(graph)
		add_edge!(pheromonegraph,edge.src,edge.dst,rand())
	end

	# Create the ants
	ants = Vector{Ant}(undef,size)
	for i = 1:size
		ants[i] = Ant([],source,destination,Inf,0)
	end

	# Create the colony
	colony = Colony(ants,size,graph,pheromonegraph,evaporationrate)

	# Begin to run the algorithm
	for i = 1:maxiter

		# Have all the ants construct their path
		foundpath = false
		for ant in colony.ants
			verdict = constructpath(ant,colony.graph,colony.pheromonegraph,alpha)
			foundpath = foundpath || verdict
		end

		#If no ant found a path, return NULL ant
		if !foundpath return nullant end

		# Evaporate pheromone
		evaporate(colony.pheromonegraph,colony.evaporationrate)

		# Update the pheromones
		laypheromone(colony)
	end

	# Return ant with the best path
	retant = nullant
	for ant in colony.ants
		if ant.cost < retant.cost
			retant = ant
		end
	end
	return retant
end
