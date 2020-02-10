using StatsBase
using Plots
byperson = 0
byinjection = 0

# Some constants to represent states
const SUSCEPTIBLE = 0
const INFECTED = 1
const RECOVERED = 2

# The Person struct, where:
# vec: Is the solution vector 
# fitness: f(fec)
# state: Either 0 1 2, for Susceptible, Infected, Recovered
# strain: Personal best seen solution vector
# severity: f(strain)
# strand: strain of person who infected this person
# strandseverity: f(strand)
# iterinfected: How many iterations this person has been infected
mutable struct Person
	vec::Vector{Real}
	fitness::Real
	state::Int
	strain::Vector{Real}
	severity::Real
	strand::Vector{Real}
	strandseverity::Real
	iterinfected::Int
end

# The Epidemic struct, where:
# population: Vector of Person structs 
# size: Size of population
# dim: Dimensions of search domain
# deathstrain: The global best vec
# deathseverity: f(deathstrain)
# infectionrate: Affects the chance of infection spreading
# infectionradius: The distance required between an Infected and Susceptible
#                  for infection to have a chance to occur
# recoveryrate: Affects how quickly an infected person becomes Recovered
# quarantine: The bounds of the problem. Decreases with every iteration
# stepsize: Maximum change in vec components during random walk.
# susceptible: Number of susceptible
# infected: Number of infected
# recovered: Number of recovered
mutable struct Epidemic
	population::Vector{Person}
	size::Int
	dim::Int
	deathstrain::Vector{Real}
	deathseverity::Real
	infectionrate::Real
	infectionradius::Real
	recoveryrate::Real
	quarantine::Vector
	stepsize::Matrix{Real}
	susceptible::Int
	infected::Int
	recovered::Int
	
end

# Function for generating a random number between the bounds
function randb(a::Real,b::Real)
	return (b-a)*rand() + a
end

# Function for returning a number in bounds
function inbounds(v::Real,a::Real,b::Real)
	if v < a return a end
	if v > b return b end
	return v
end

# Function for randomly injecting Person's based on:
# The number of infected in the population
# The infection rate (potentially change this)
function inject(epidemic::Epidemic)
	val = 1
	for person in epidemic.population
		if person.state == SUSCEPTIBLE
			r = rand()
			p = exp(-epidemic.infected/(epidemic.susceptible+1))*
			    epidemic.infectionrate*val
			if r < p
				global byinjection += 1
				val *= 0.5
				person.strand = epidemic.deathstrain
				person.strandseverity = epidemic.deathseverity
				person.state = INFECTED
				person.iterinfected = 1
				epidemic.infected += 1
				epidemic.susceptible -= 1
			end
		end
	end
end


# Function for randomly walking everyone, where:
# Susceptible: Take a true random walk
# Infected: Take a true random walk
# Recovered: Only move to better locations
function walk(f::Function,params::Vector,epidemic::Epidemic)
	# For every Person update their positions with quarantine
	for person in epidemic.population
		r = map(x -> (x - 0.5)*2,rand(epidemic.dim))
		vecprime = person.vec + epidemic.stepsize*r
		vecprime = map((x,y) -> inbounds(x,y[1],y[2]),vecprime,epidemic.quarantine)

		# If RECOVERED, only take if better
		if person.state == RECOVERED
			fitnessprime = f(vecprime,params)
			if fitnessprime < person.fitness
				person.vec = vecprime
				person.fitness = fitnessprime
			end
		else
			person.vec = vecprime
			person.fitness = f(vecprime,params)
		end

		# Update strain (pb) and deathstrain (gb) if necessary
		if person.fitness < person.severity
			person.strain = person.vec
			person.severity = person.fitness

			# If the strain for this person was updated, see if deathstrain can be
			if person.severity < epidemic.deathseverity
				epidemic.deathstrain = person.strain
				epidemic.deathseverity = person.severity
			end
		end
	end
end

# Spread the disease from infected to susceptible
function spreadandrecover(epidemic::Epidemic)
	
	# Grab all indices of the susceptible and infected
	susdex = [i for i = 1:epidemic.size if epidemic.population[i].state == SUSCEPTIBLE]
	infdex = [i for i = 1:epidemic.size if epidemic.population[i].state == INFECTED]

	# Go through and spread infection
	for i in infdex
		for s in susdex
			# Calculate the distance between these two Person's
			dist = sqrt(mapreduce((x1,x2) -> (x1-x2)*(x1-x2),+,
					      epidemic.population[i].vec,epidemic.population[s].vec))
			# If can be infected
			if dist <= epidemic.infectionradius
				# If become infected, update strand with strain of infected
				if rand() < exp(-dist/epidemic.infectionradius)*epidemic.infectionrate
					global byperson += 1
					epidemic.population[s].strand = epidemic.population[i].strain
					epidemic.population[s].strandseverity = epidemic.population[i].severity
					epidemic.population[s].state = INFECTED
				end
			end
		end
		# Infected have potential to recover
		if rand() < exp(-1/(epidemic.population[i].iterinfected*epidemic.recoveryrate))
			epidemic.population[i].state = RECOVERED
			epidemic.population[i].vec = epidemic.population[i].strand
			epidemic.population[i].fitness = epidemic.population[i].strandseverity
			epidemic.infected -= 1
			epidemic.recovered += 1
		else
			epidemic.population[i].iterinfected += 1
		end
	end

	# Go through and update information for those who went from sus to inf
	for s in susdex
		if epidemic.population[s].state == INFECTED
			epidemic.infected += 1
			epidemic.susceptible -= 1
			epidemic.population[s].iterinfected = 1
		end
	end

end

# Funtion to skrink the quarantine size
function shrink(epidemic::Epidemic)
	quarantine = [[Inf,-Inf] for i in 1:epidemic.dim]
	for i = 1:epidemic.size
		for j = 1:epidemic.dim
			quarantine[j][1] = quarantine[j][1] < epidemic.population[i].vec[j] ?
			                   quarantine[j][1] : epidemic.population[i].vec[j]
			quarantine[j][2] = quarantine[j][2] > epidemic.population[i].vec[j] ?
			                   quarantine[j][2] : epidemic.population[i].vec[j]
		end
	end
	return map(x -> (x[1]-(x[2] - x[1])*0.2,x[2]+(x[2] - x[1])*0.2),quarantine)
end



# The main sir function, where:
# bounds: Must be a vector of Tuples
function sir(f::Function,bounds::Vector,params::Vector=[]
	     ; size::Int=100,infectionrate::Real=1,infectionradius::Real=Inf
	     , recoveryrate::Real=1, maxiter::Int=1000, source::Int=1
	     , stepsize::Matrix{Real}=Matrix{Real}(undef,0,0)
	     , stepdecay = 0.95)
	
	# Randomy populate the initial population
	dim = length(bounds)
	population = Vector{Person}(undef,size)
	deathstrain = []
	deathseverity = Inf
	for i = 1:size
		# Create a Person
		vec = map(x -> randb(x[1],x[2]),bounds)
		fitness = f(vec,params)
		if fitness < deathseverity
			deathseverity = fitness
			deathstrain = vec
		end
		population[i] = Person(vec,fitness,0,vec,fitness,vec,fitness,1)
	end
	
	# Pick random Person's from the population, and mark them as infected
	infect = sample(1:size,source,replace=false)
	for i in infect
		population[i].state = INFECTED
		population[i].strand = deathstrain
		population[i].severity = deathseverity
	end

	# If stepsize wasn't specified, supply it based on bounds
	if isempty(stepsize)
		stepsize = zeros(Float64,dim,dim)
		for i = 1:dim
			stepsize[i,i] =(bounds[i][2] - bounds[i][1])*0.05
		end
	end

	# If infectionradius wasn't specified, supply it
	infectionradius = infectionradius < Inf ? infectionradius : 
	                  sqrt(mapreduce(x -> x^2,+,stepsize))


	# Create the Epidemic
	epidemic = Epidemic(population,size,dim,deathstrain,deathseverity
			    ,infectionrate,infectionradius
			    ,recoveryrate,bounds,stepsize
			    ,size-source,source,0)


	# For required iterations, run the simulation
	for k in 1:maxiter
		turns = 0
		# While the population is still not entirely recovered
		while epidemic.recovered < epidemic.size
			turns += 1
			# Potentially infect a random person with deathstrain
			if epidemic.infected < epidemic.susceptible*0.05 inject(epidemic) end

			# Update everyones random walk
			walk(f,params,epidemic)

			# Potentially infect any Susceptible and Infected can be recovered
			spreadandrecover(epidemic)

		end
		#=x = [epidemic.population[i].vec[1] for i in 1:epidemic.size]
		y = [epidemic.population[i].vec[2] for i in 1:epidemic.size]
		plot(seriestype=:scatter,x,y,xlim=(-2.048,2.048),ylim=(-2.048,2.048))=#

		# Calculate new bounds of the quarantine,
		# and decrease stepsize
		epidemic.quarantine = shrink(epidemic)

		# Restart the states of the population
		for person in epidemic.population
			person.state = SUSCEPTIBLE
		end

		# Populate initial infected
		infect = sample(1:size,source,replace=false)
		for i in infect
			epidemic.population[i].state = INFECTED
			epidemic.population[i].strand = epidemic.deathstrain
			epidemic.population[i].strandseverity = epidemic.deathseverity
		end

		# Calculate new step size based on quanrantine
		for i = 1:epidemic.dim
			epidemic.stepsize[i,i] = (epidemic.quarantine[i][2] - epidemic.quarantine[i][1])*0.05
		end

		# Calculate infection radius
		epidemic.infectionradius = sqrt(mapreduce(x -> x^2,+,epidemic.stepsize))

		# Calculate new state counts
		epidemic.susceptible = size-source
		epidemic.infected = source
		epidemic.recovered = 0

		#=println("Infection Radius: ",epidemic.infectionradius)
		println("Quarantine: ",epidemic.quarantine)
		println("Stepsize: ",epidemic.stepsize)
		println("Turns: ",turns)
		println("\n")=#

		if sum(epidemic.stepsize) < 1e-9 
			println(k)
			println("By person: ",byperson)
			println("By injection: ",byinjection)
			global byperson = 0
			global byinjection = 0
			return epidemic.deathstrain,epidemic.deathseverity
		end
		#=for person in epidemic.population
			println(person.vec)
			println(person.strain)
			println()
		end=#
	end

	# Return the deathstrain
	println("By person: ",byperson)
	println("By injection: ",byinjection)
	global byperson = 0
	global byinjection = 0
	return epidemic.deathstrain,epidemic.deathseverity
end
