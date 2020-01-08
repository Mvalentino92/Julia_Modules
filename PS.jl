using Plots

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
	vclamp::Tuple{Real,Real}
	bestPosition::Vector{Float64}
	bestValue::Real
	cognitive::Real
	social::Real
	delta::Real
	omega::Real
	constraint::Bool
	k::Real
end

# Return a float within min and max
function randb(min::Real,max::Real)
	return min + (max - min)*rand()
end

#Master update function
function updateSwarm(f::Function,swarm::Swarm)
	#For every particle in the swarm
	for i = 1:swarm.size
		particle = swarm.particles[i]

		#For every dimension of this particle
		for j = 1:swarm.dim

			#=*********Update velocity*******=#
			
			#Get distance from personal and global best
			pbest = particle.bestPosition[j] - particle.position[j]
			gbest = swarm.bestPosition[j] - particle.position[j]

			#Calculate phi for checking constraints and minimizing equation footprint
			ϕ1 = swarm.cognitive*rand()
			ϕ2 = swarm.social*rand()
			ϕ = ϕ1 + ϕ2

			#Calculate the 3 components of the velocity update
			inertia = particle.velocity[j]
			cognitive = ϕ1*pbest
			social = ϕ2*gbest

			#If the constraint is wanted and applicable, apply it
			velocity = 0
			if swarm.constraint && ϕ >= 4
				χ = (2*swarm.k)/abs(2 - ϕ - sqrt(ϕ*(ϕ-4)))
				velocity = χ*(intertia + cognitive + social)

			#Otherwise, default to inertia weight and velocity clamping
			else
				velocity = swarm.omega*inertia + cognitive + social
				if velocity < swarm.vclamp[1]
					velocity = swarm.vclamp[1]
				elseif velocity > swarm.vclamp[2]
					velocity = swarm.vclamp[2]
				end
			end
			particle.velocity[j] = velocity

			#Update position
			particle.position[j] = particle.position[j] + particle.velocity[j]
		end

		#Update personal best
		fitness = f(particle.position)
		if fitness < particle.bestValue
			particle.bestValue = fitness
			particle.bestPosition = deepcopy(particle.position)
		end

		#Update global best
		if particle.bestValue < swarm.bestValue
			swarm.bestValue = particle.bestValue
			swarm.bestPosition = deepcopy(particle.bestPosition)
		end
	end
end

#=**********************Main algorithm, takes the following parameters:*********************=#
# f: Is the objective function to minimize
# bounds: The space you want to initially spawn particles. 
# 
# KEYWORD ARGS
# size: The size of the swarm.
# moving: Set to true if you want the particles initially moving with velocities ∈ (-1,1).
# vclamp: Velocity clamping bounds. Default generation is square root of average bound distance.
#
# cognitive: Influences the particle to move towards it's personal best location. 
#            < 1 will make reduce this influence, > 1 will increase it.
#
# social: Influeces the particle to move towards the global best location.
#            "" 		"" 		"" 		""
#
# delta: Affects the bounds of the swarm velocity clamping. Exponentially lowers the bounds each iteration.
# 	 < 1 will gradually reduce the max velocity which the particles may roam. Potentially enforcing exploitation.
# 	 > 1 will gradually increase the max velocity which the particles may roam. Potentially enforcing exploration.
#
# omega: Inertia weight. Affects the particles tendency to keep moving at it's current velocity.
#        < 1 will make it's current velocity have less of an impact on its updated velocity. (Exploitation)
#        > 1 will make its current velocity have more of an impact on its updated velocity.  (Exploration)
# 
# constraint: Set to true if you want the velocity update overidden with the constraint method.
#             NOTE: The constraint method is only eligible to kick in if the following is true
#                   ϕ >= 4 where
#                   ϕ = ϕ1 + ϕ2
#                   ϕ1 = c1*r1 (c1 = cognitive and r1 ∈ (0,1)
#                   ϕ2 = c2*r2 "" 	    "" 	           ""
#
# k: The constant involved in the constraint coefficient method. Must be ∈ (0,1)
function pswarm(f::Function,bounds::Vector{T}; size::Int64=21
		,moving::Bool=false,vclamp::T=(0,0),cognitive::Real=1.49618
		,social::Real=1.49618,delta::Real=1.0,omega::Real=1.0,
		constraint::Bool=false,k::Real=0.777) where T <: Tuple{Real,Real}

	#=**********************INITIALIZE SWARM************************=#                 
	
	#Calculate velocity clamping based on average of bounds
	distance = sqrt(mapreduce(x -> x[2] - x[1], +, bounds)/length(bounds))
	vclamp = (-randb(0.95,1.05)*distance,randb(0.95,1.05)*distance)

	#Iniatilize global best for swarm and particles
	dim = length(bounds)
	globalBestPosition = zeros(Float64,dim)
	globalBest = Inf
	particles = Vector{Particle}(undef,size)

	#For every particle to initialize
	for p = 1:size

		#Initialize parameters for current particle
		position = zeros(Float64,dim)
		velocity = zeros(Float64,dim)
	
		#For every dimension of each particle
		for d = 1:dim
			position[d] = randb(bounds[d][1],bounds[d][2])
			velocity[d] += moving ? (rand() - 0.5)*2.0 : 0.0
		end

		#Set personal best, and create particle
		personalBestPosition = deepcopy(position)
		personalBest = f(position)
		particles[p] = Particle(position,velocity,personalBestPosition,personalBest)

		#Update global best if necessary
		if personalBest < globalBest
			globalBest = personalBest
			globalBestPosition = deepcopy(personalBestPosition)
		end
	end
	
	#Create swarm model
	swarm = Swarm(particles,size,dim,bounds,vclamp,
		      globalBestPosition,globalBest,cognitive,social,delta,omega,constraint,k)

	#Testing for random number of iterations
	for i = 1:750

		updateSwarm(f,swarm)

		#Change bounds for velocity clamp
		swarm.vclamp = map(x -> x*swarm.delta,swarm.vclamp)

		#=Plotting every iteation
		x = map(x -> x.position[1],swarm.particles)
		y = map(x -> x.position[2],swarm.particles)
		plot(x,y,seriestype=:scatter,xlim=swarm.bounds[1],ylim=swarm.bounds[2])=#
	end

	return (swarm.bestPosition,swarm.bestValue)
end
