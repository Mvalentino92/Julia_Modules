include("ACO_Functions.jl")
include("GraphUtils.jl")
using Plots, GraphPlot, Random, Colors

function saco(graph::SimpleWeightedGraph,source::Int,destination::Int;
	      size::Int=15,evaporationrate::Real=0.35, alpha::Real=0.65,
		  plotit::Bool=false,filename::String="anim.gif",maxiter::Int=1000)

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

	# If plotit is true, create some needed variables
	if plotit
		h = SimpleGraph(nv(colony.graph))
		for edge in edges(colony.graph)
			add_edge!(h,edge.src,edge.dst)
		end
		edgelist = collect(edges(h))
		colors_per_iter = Vector()
		colors = distinguishable_colors(size+1,colorant"lightblue")
	end
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

		# If plotit is true, add to the color_vector
		if plotit
			push!(colors_per_iter,get_color_code(edgelist,colony.ants,colony.size))
		end
	end

	# If plotit is true, create a gif
	if plotit
		anim=Animation()
		for i = 1:maxiter
    		p=gplot(h,edgestrokec=colors[colors_per_iter[i]],
			        nodelabel=1:nv(h),layout=circular_layout)
    		output = compose(p,
        		(context(), Compose.text(1, 1, "Julia")),
        		(context(), rectangle(), fill("white")))
    		j=length(anim.frames) + 1
    		tmpfilename=joinpath(anim.dir,@sprintf("%06d.png",j))
    		Compose.draw(PNG(tmpfilename),output)
    		push!(anim.frames, tmpfilename)
		end
		gif(anim, string("/mnt/chromeos/MyFiles/Downloads/OptGifs/",filename), fps = 5)
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
