include("AS_Functions.jl")
include("Utils.jl")
using Plots, GraphPlot, Random, Colors, Measures, Printf, Compose
import Cairo

function as(mg::MetaGraph,source::Int,destination::Int;
	      size::Int=15,evaporationrate::Real=0.35,reward::Real=0.90,
		  alpha::Real=0.65, beta::Real=(1-alpha),gamma::Real=1,delta::Real=1,
		  plotit::Bool=false,filename::String="anim.gif",maxiter::Int=250)

	# The NULL Ant
	nullant = Ant([],source,destination,Inf)

	# Initialize the pheromone on the graph with small random values
	for edge in edges(mg)
		set_prop!(mg,edge,:pheromone,rand())
	end

	# Initialize the deadend property for the vertices
	for vertex in vertices(mg)
		set_prop!(mg,vertex,:deadend,1.0)
	end

	# Create the ants
	ants = Vector{Ant}(undef,size)
	for i = 1:size
		ants[i] = Ant([],source,destination,Inf)
	end

	# Create the colony
	colony = Colony(ants,size,mg,evaporationrate)

	# If plotit is true, create some needed variables
	if plotit
		g = SimpleGraph(mg)
		edgelist = collect(edges(g))
		colors_per_iter = Vector()
		colors = distinguishable_colors(size+1,colorant"lightblue")
	end
	# Begin to run the algorithm
	for i = 1:maxiter
		# Have all the ants construct their path
		foundpath = false
		for ant in colony.ants
			verdict = constructpath(ant,colony.mg,alpha,beta,gamma)
			foundpath = foundpath || verdict
		end

		#If no ant found a path, return NULL ant
		if !foundpath return nullant end

		# Evaporate pheromone
	    evaporate(colony.mg,colony.evaporationrate)

		# Update the pheromones
		laypheromone(colony.mg,colony.ants,reward,delta)

		delta *= 0.9375

		# If plotit is true, add to the color_vector
		if plotit
			push!(colors_per_iter,get_color_code(edgelist,colony.ants,colony.size))
		end
	end

	# If plotit is true, create a gif
	if plotit
		anim=Animation()
		for i = 1:maxiter
    		p=gplot(g,edgestrokec=colors[colors_per_iter[i]],
			        layout=circular_layout)
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
