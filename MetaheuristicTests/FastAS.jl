include("FastAS_Functions.jl")
include("Utils.jl")
using Plots, GraphPlot, Random, Colors, Measures, Printf, Compose
import Cairo

function fas(g::SimpleGraph,weights::Vector,source::Int,destination::Int;
	      size::Int=15,evaporationrate::Real=0.35,reward::Real=0.90,
		  alpha::Real=0.65, beta::Real=(1-alpha),gamma::Real=1,delta::Real=1,
		  plotit::Bool=false,filename::String="anim.gif",maxiter::Int=250)

	# The NULL Ant
	nullant = Ant([],source,destination,Inf)

    # Create the edgelist
    edgelist = collect(edges(g))

	# Initialize the attributes matrix
    attributes = zeros(Float64,2,length(edgelist))

    # Populate weights and pheromone
    for i = 1:length(edgelist)
        attributes[1,i] = weights[i]
        attributes[2,i] = rand()
    end

	# Initialize the deadend
    deadend = ones(Float64,nv(g))

	# Create the ants
	ants = Vector{Ant}(undef,size)
	for i = 1:size
		ants[i] = Ant([],source,destination,Inf)
	end

	# Create the colony
	colony = Colony(ants,size,g,edgelist,attributes,deadend,evaporationrate)

	# If plotit is true, create some needed variables
	if plotit
		colors_per_iter = Vector()
		colors = distinguishable_colors(size+1,colorant"lightblue")
	end
	# Begin to run the algorithm
	for i = 1:maxiter
		# Have all the ants construct their path
		foundpath = false
		for ant in colony.ants
			verdict = constructpath(ant,colony.g,
                                    colony.attributes,colony.deadend,
                                    colony.edgelist,alpha,beta,gamma)
			foundpath = foundpath || verdict
		end

		#If no ant found a path, return NULL ant
		if !foundpath return nullant end

		# Evaporate pheromone
	    evaporate(colony.edgelist,colony.attributes,colony.evaporationrate)

		# Update the pheromones
		laypheromone(colony.edgelist,colony.attributes,colony.ants,reward,delta)

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
