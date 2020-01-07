const ϵ = 1e-7

# Particle structs, just position and velocity
mutable struct Particle{T <: Real}
	position::Vector{T}
	velocity::Vector{T}
	bestPosition::Vector{T}
	bestValue::T
end

# Swarm structs, has particles as arguements, and default values for params associated with swarm
mutable struct Swarm{T <: Real}
	particles::Vector{Particle}
	bounds::Vector{Tuple{T,T}} #Change this to be velocity clamping
	bestPosition::Vector{T}
	bestValue::T
	cognitive::T
	social::T
	omega::T
	k::T
end

# Return a float within min and max
function randb(min::Real,max::Real)
	return min + (max - min)*rand()
end

#Master update function
function updateSwarm(f::Function,dim::Int64,swarm::Swarm)
	#Get size of the swarm
	size = length(swarm.particles)

	#For every particle in the swarm
	for i = 1:size
		particle = swarm.particles[i]

		#For every dimension of this particle
		for j = 1:dim

			#Update velocity
			inertia = particle.velocity[j]
			cognitive = swarm.cognitive*rand()*(particle.bestPosition[j] - particle.position[j])
			social = swarm.social*rand()*(swarm.bestPosition[j] - particle.position[j])

			velocity = inertia + cognitive + social #hardcoded velocity clamping
			sign = velocity < 0 ? -1 : 1
			particle.velocity[j] = abs(velocity) > 5 ? 5*ϵ*sign : velocity

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

# Function to initialize a swarm of optional size (default 21)
# with optinal bounds (default [-1.0,1.0] for all dimensions. 
# moving will start evert particle with a random velocity between [-1,1]
function initSwarm(f::Function,dim::Int64; bounds::Vector{Tuple{Float64,Float64}}=repeat([(-1.0,1.0)],dim),size::Int64=21
		   ,moving::Bool=false,cognitive::Real=1.49618,social::Real=cognitive,omega::Real=1.0,k::Real=0.777)

	#Iniatilize global best for swarm and particles
	globalBestPosition = zeros(Float64,dim)
	globalBest = Inf
	particles = Vector{Particle}(undef,size)

	#For every particle to initialize
	for p = 1:size

		#Initialize parameters for current particle
		position = Vector{Float64}(undef,dim)
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

	#Return generated swarm
	return Swarm(particles,bounds,globalBestPosition,globalBest,cognitive,social,omega,k) #Chagne bounds for velocity clamp
end

#Main algorithm
function ps(f::Function,dim::Int64,swarm::Swarm=initSwarm(f,dim))

	#Testing for random number of iterations
	for i = 1:1000
		updateSwarm(f,dim,swarm)
		println(swarm.bestValue," ",swarm.bestPosition)
	end
end
