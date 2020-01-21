using Plots
realTuple = Tuple{Real,Real}

# Particle struct. To be used inside Swarm struct.
mutable struct Particle
	position::Vector{Float64}
	velocity::Vector{Float64}
	bestPosition::Vector{Float64}
	bestValue::Real
end

# Swarm struct. Holds all information needed about the swarm.
mutable struct Swarm
	particles::Vector{Particle} 
	size::Int64
	dim::Int64
	bounds::Vector{Tuple{Real,Real}}
	hardbounds::Vector{Tuple{Real,Real}}
	velocitybounds::Tuple{Real,Real}
	bestPosition::Matrix{Float64}
	bestValue::Vector{Real}
	c₁::Real #cognitive
	c₂::Real #social
	ω::Real  #inertia weight
	δ::Real  #Exponential decay of velocitybounds
	γ::Real  #Exponential decay of inertia weight
	constraint::Bool
	k::Real
	lbest::Bool
	nsize::Int64 #Size of neighborhood
end

# Return a float within min and max
function randb(min::Real,max::Real)
	return min + (max - min)*rand()
end

# Adjusts indices for the lbest neighborhoods
function adjustIndices(x,n)
	retval = (x + n) % n
	return retval == 0 ? n : retval
end

#Master update function
function updateSwarm(f::Function,swarm::Swarm,params::Vector)

	#For use if gbest algorithm
	gbestVal = Inf
	gbestPosition = zeros(Float64,swarm.dim)

	#Update memory for every particle in the swarm
	for i = 1:swarm.size
		particle = swarm.particles[i]

		#Update personal best
		fitness = f(particle.position,params)
		if fitness < particle.bestValue
			particle.bestValue = fitness
			particle.bestPosition = deepcopy(particle.position)
		end

		#=************Update global best************=#
		#If lbest, do all neighborhoods seperately
		if swarm.lbest
			#Get the best value within the adjusted indicies
			indices = map(x -> adjustIndices(x,swarm.size),i-swarm.nsize:1:i+swarm.nsize)
			ndex = indices[1]
			nbest = Inf
			for j in indices
				if swarm.particles[j].bestValue < nbest
					ndex = j
					nbest = swarm.particles[j].bestValue
				end
			end
			swarm.bestValue[i] = nbest
			swarm.bestPosition[:,i] = deepcopy(swarm.particles[ndex].bestPosition)

		#Otherwise if gbest, just update one by one
		else
			if particle.bestValue < gbestVal
				gbestVal = particle.bestValue
				gbestPosition = deepcopy(particle.bestPosition)
			end
		end
	end

	#If gbest, copy global best parameters onto every neighborhood (acting as one neighborhood)
	if !swarm.lbest
		for i = 1:swarm.size
			swarm.bestValue[i] = gbestVal
			swarm.bestPosition[:,i] = deepcopy(gbestPosition)
		end
	end

	#Update velocity and position for every particle.
	for i = 1:swarm.size
		particle = swarm.particles[i]

		#For every dimension of this particle
		for j = 1:swarm.dim

			#=*********Update velocity*******=#
			#Get distance from personal and global best
			pbest = particle.bestPosition[j] - particle.position[j]
			gbest = swarm.bestPosition[j,i] - particle.position[j]

			#Calculate phi for checking constraints and minimizing equation footprint
			ϕ1 = swarm.c₁*rand()
			ϕ2 = swarm.c₂*rand()
			ϕ = ϕ1 + ϕ2

			#Calculate the 3 components of the velocity update
			inertia = particle.velocity[j]
			cognitive = ϕ1*pbest
			social = ϕ2*gbest

			#If the constraint is wanted and applicable, apply it
			velocity = 0
			if swarm.constraint && ϕ >= 4
				χ = (2*swarm.k)/abs(2 - ϕ - sqrt(ϕ*(ϕ-4)))
				velocity = χ*(inertia + cognitive + social)

			#Otherwise, default to inertia weight and velocity clamping
			else
				velocity = swarm.ω*inertia + cognitive + social
				if velocity < swarm.velocitybounds[1]
					velocity = swarm.velocitybounds[1]
				elseif velocity > swarm.velocitybounds[2]
					velocity = swarm.velocitybounds[2]
				end
			end
			particle.velocity[j] = velocity

			#=**********Update position********=#
			position = particle.position[j] + particle.velocity[j]
			if position < swarm.hardbounds[j][1]
				position = swarm.hardbounds[j][1]
			elseif position > swarm.hardbounds[j][2]
				position = swarm.hardbounds[j][2]
			end
			particle.position[j] = position
		end
	end
end

# Convergence test for seeing if particles tightened around global best found so far.
function radiusConverge(perform::Bool,swarm::Swarm,D::Float64,ϵ::Real)
	if perform
		#=Get the bestneighborhood position=#
		ndex = 1
		if swarm.lbest #If lbest perform search, otherwise all indentical, return first.
			nbest = swarm.bestValue[ndex]
			for i = 2:swarm.size
				if swarm.bestValue[i] < nbest
					nbest = swarm.bestValue[i]
					ndex = i
				end
			end
		end
		bestPosition = swarm.bestPosition[:,ndex]

		#Compute the Euclidian distance for all
		rmax = -Inf
		for i = 1:swarm.size
			particle = swarm.particles[i]
			distance = sqrt(mapreduce((x,y) -> (x-y)*(x-y),+,particle.position,bestPosition))
			rmax = distance > rmax ? distance : rmax
		end
		return rmax/D < ϵ
	end
	return false
end

#= Main algorithm, accepts parameters that do the following:
#                                MANDATORY
#
# f: The objective function to be optimized. Must be written to accept 2 Vectors. 
#    1 for variable values, and another for parameter values. Parameter Vector is optional,
#    and will have have a default value of [] (an empty Vector)
# bounds: The bounds for the search space where the particles will spawn for every dimension.
#
#                                OPTIONAL
#
# params: A parameter vector to be passed to the objective function f.
#         The default value is an empty Vector []
#          
#                                KEY WORD ARGS
#
# maxiter: The max number of iterations for the algorithm to run before it stops and returns found solution.
# plotit: Plots a certain number of iterations of the particles on a 2D plot, and returns it as a gif.
# plotiter: The number of of iterations to plot for the gif
# clamping: If velocity clamping is desired.
# velocitybounds: A lower and upper bound applied to EVERY dimension for the particles velocity.
# velocitydecay: The expoenent in an equation  that lowers the values of velocity bounds every iteration exponentially
#                < 1 for faster decay, > 1 for slower decay.
# decayvelocity: True if you want to decay velocity bounds exponentially
# decayinertia: True if you want to decay inertia exponentially
# cognitive: The cognitive componenet for the velocity update. 
# inertiaweight: The constant that affects the cognitives components influence.
# inertiadecay: The exponent in an equation that lowers of the value of inertiaweight exponentially every iteation.
#                < 1 for faster decay, > 1 for slower decay.
# social: The social component of the velocity update
# constraint: If the constraint coefficient method is desired
#             This can be used in tandem with velocity clamping and inertia weight to help control the 
#             convergence of the swarm. For the constraint coefficient to be used,
#             cognitive*r1 + social*r2 >= 4, where r1,r2 ∈ (0,1)
# k: A constant used in the calculation of the constraint coefficient ∈ (0,1)
# size: The size of the swarm, 10 to 30 recommended
# moving: If true, the initial velocity of all the particles will be ∈ (-1,1)
# hardbounds: The barriers for where the particles can extend their search in each dimension.
#             The default is (-Inf,Inf) for all dimensions. To limit the hardbounds to the space you want
#             to initially spawn particles, simply set hardbounds=bounds
# lbest: If true performs localbest particle swarm as opposed to global best which is the default.
# nsize: The size of each neighborhood for local best.
#        Note that nsize corresponds to how far to extend in the left and right direction to generate the neighborhood.
#        EXAMPLE: nsize=3, would have the neighborhood be 7 wide. (3 on each side of the current particle,
#                 plus the current particle.
#        The default value makes each neighborhood 1/3 of the totla size of the swarm (with overlap, since there will 
#        always be n neighborhoods where n=size of swarm. Another suggested value is 1.
# convergence: If set to false, will not check for convergence of the swarm and will solely rely on maxiter for termination.
# convergencetol: The tolerance for the convergence criteria. Set to very low values to ensure tighter convergence.
# tabuassist: Will call tabu search which will attempt to find a tighter subspace of the initial search
#             space to spawn the particles.
#             WARNING: Will increase the running time of the algorithm. =#
function pswarm(f::Function, bounds::Vector{T}, params::Vector=[]
		; maxiter::Int64=50000, plotit::Bool=false, plotiter::Int64=100
		, clamping::Bool=false, velocitybounds::Tuple=(-Inf,Inf),velocitydecay::Real=1.0
		, decayvelocity::Bool=false, decayinertia::Bool=false
		, cognitive::Real=1.49618, inertiaweight::Real=1.0, inertiadecay::Real=1.0
		, social::Real=1.49618, constraint::Bool=false,k::Real=0.777
		, size::Int64=21, moving::Bool=false, hardbounds::Vector{G}=repeat([(-Inf,Inf)],length(bounds))
		, lbest::Bool=false, nsize::Int64=floor(Int64,size/6 - 0.5)
		, convergence::Bool=true,convergencetol::Real=1e-2
		, tabuassist::Bool=false) where T <: realTuple where G <: realTuple

	#=**********************INITIALIZE SWARM************************=#                 
	#Iniatilize global best for swarm and particles
	dim = length(bounds)
	globalBestPosition = zeros(Float64,dim,size)
	globalBest = repeat([Inf],size)
	particles = Vector{Particle}(undef,size)

	#If tabu assisted generate and print
	if tabuassist

		#Call tabu search
		avgbounds = mapreduce(x -> x[2] - x[1],+,bounds)/dim
		X0 = map(x -> (x[2]-x[1])/2 + x[1],bounds)	
		(_,tabu_positions) = tabusearch(f,X0,params,reach=avgbounds/2,elite_size=size,hardbounds=hardbounds)
		tabu_bounds = Vector{Tuple{Real,Real}}(undef,dim)

		#Print the starting positions after tabusearch
		println("Starting positions of particles after tabu search:")
		for i in tabu_positions
			println(i)
		end
	end
	
	#Calculate velocity clamping based on average of bounds if non supplied and desired
	if clamping && velocitybounds == (-Inf,Inf)
		distance = sqrt(mapreduce(x -> x[2] - x[1], +, bounds)/dim)
		velocitybounds = (-randb(0.95,1.05)*distance,randb(0.95,1.05)*distance)
	end

	#For every particle to initialize
	for i = 1:size

		#Initialize parameters for current particle
		position = zeros(Float64,dim)
		velocity = zeros(Float64,dim)
	
		#For every dimension of each particle
		for j = 1:dim
			position[j] = randb(bounds[j][1],bounds[j][2])
			velocity[j] += moving ? (rand() - 0.5)*2.0 : 0.0
		end

		#If tabu assist is on, and value exists, use this position instead
		if tabuassist && sum(tabu_positions[i]) < Inf
			position = tabu_positions[i]
		end

		#Create particle
		particles[i] = Particle(position,velocity,zeros(Float64,dim),Inf)
	end

	#Calculate the diameter of the swarm
	D = 0
	for i = 1:dim
		curdim = map(x -> x.position[i],particles)
		mn = minimum(curdim)
		mx = maximum(curdim)
		D += (mx - mn)
	end
	D /= dim
	
	#Create swarm model
	swarm = Swarm(particles,size,dim,bounds,hardbounds,velocitybounds,
		      globalBestPosition,globalBest,cognitive,social,inertiaweight,
		      velocitydecay,inertiadecay,constraint,k,lbest,nsize)

	#Plot if applicable, overrides maxiter and convergence
	if plotit
		@gif for i = 1:plotiter
			updateSwarm(f,swarm,params)

			#Change bounds for velocity clamp if applicable
			swarm.velocitybounds = decayvelocity ? map(x -> x*(1 - (i/maxiter)^swarm.δ),velocitybounds) : swarm.velocitybounds

			#Change inertiaweight if applicable
			swarm.ω = decayinertia ? inertiaweight*(1 - i/maxiter)^swarm.γ : swarm.ω

			#Plotting every iteation, averaging dimensions
			x = zeros(Float64,size)
			xdiv = 0
			y = zeros(Float64,size)
			ydiv = 0
			for j = 1:dim
				if isodd(j) 
					x += map(p -> p.position[j],swarm.particles)
					xdiv += 1
				else
					y += map(p -> p.position[j],swarm.particles)
					ydiv += 1
				end
			end
			x /= xdiv
			y /= ydiv
			plot(x,y,seriestype=:scatter,xlim=swarm.bounds[1],ylim=swarm.bounds[2])
		end
	end

	#Main algorithm
	i = plotit ? plotiter : 0
	while(i < maxiter && !radiusConverge(convergence,swarm,D,convergencetol))
		updateSwarm(f,swarm,params)
		swarm.velocitybounds = decayvelocity ? map(x -> x*(1 - (i/maxiter)^swarm.δ),velocitybounds) : swarm.velocitybounds
		swarm.ω = decayinertia ? inertiaweight*(1 - i/maxiter)^swarm.γ : swarm.ω
		i += 1
	end

	if swarm.lbest return (swarm.bestPosition,swarm.bestValue) end
	return (swarm.bestPosition[:,1],swarm.bestValue[1])
end
