# The Gene struct. Represents a solution
mutable struct Gene
	phenotype::Vector{Real}
	fitness::Real
end

# The Generation struct, represents a population of solutions
mutable struct Generation
	parents::Vector{Gene}
	children::Vector{Gene}
	fittest::Gene
	mutationrate::Real
	size::Int
	dims::Int
end

# Function to check for convergence
function converged(generation::Generation,tol::Real)
	temp = mapreduce(vec -> abs.(vec.phenotype .- generation.fittest.phenotype),+,generation.parents)
	dist = sum(temp)/length(temp)
	return dist < tol
end

function randb(a::Real,b::Real)
	return a + (b-a)*rand()
end

# Generates and mutates a child population
function breed_and_mutate(f::Function,params::Vector,generation::Generation)
	temp = map(gene -> gene.phenotype .+ 
			   [rand() < generation.mutationrate ? 1 : 0 for i = 1:generation.dims].*
			   randn(generation.dims),generation.parents)
	generation.children = map(x -> Gene(x,f(x,params)),temp)
end

# Selects the top to survive
function survive(generation::Generation)
	temp = vcat(generation.parents,generation.children)
	sort!(temp,by=(x -> x.fitness))
	generation.parents = temp[1:generation.size]
	generation.fittest = temp[1]
end

function ep(f::Function,bounds::Vector,params::Vector=[];
	    mutationrate::Real=1/length(bounds),size::Int=100,
	    maxiter::Int=1000,convergence::Bool=false,tol::Real=1e-2)

	# Generate an initial generation
	dims = length(bounds)
	parents = map(x -> Gene(x,f(x,params)),
                     [[randb(bounds[gene][1],bounds[gene][2]) for gene = 1:dims] for parents = 1:size])
	fittest = parents[argmin(map(x -> x.fitness,parents))]
	children = []
	generation = Generation(parents,children,fittest,mutationrate,size,dims)

	# Perform operations for specified number of iterations
	for i = 1:maxiter

		# Check for convergence
		if convergence && converged(generation,tol) return generation.parents,generation.fittest end

		# Breed and mutate a children population
		breed_and_mutate(f,params,generation)

		# Select fittest n members of the now 2n generation to survive
		survive(generation)
	end
	return generation.parents,generation.fittest
end
