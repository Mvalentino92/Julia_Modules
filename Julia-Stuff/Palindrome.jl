using Random
using StatsBase

# Function to read in the data and return words
function getdata(math::String,normal::String)
	mathfile = open(math,"r")
	mathwords = readlines(mathfile)
	close(mathfile)

	normalfile = open(normal,"r")
	normalwords = readlines(normalfile)
	close(normalfile)

	# Wrap in our new word types
	mathwords = map(x -> MathWord(x),mathwords)
	normalwords = map(x -> NormalWord(x),normalwords)
	
	# Concat and shuffle
	return shuffle!(vcat(mathwords,normalwords))
end

# Need some types, because I need the destinction if a word
# is a math word, or a normal word.
abstract type Word end

struct MathWord <: Word
	word::String
end

struct NormalWord <: Word
	word::String
end

# Need a struct that is each phenotype
mutable struct Pheno
	sentence::Vector{Word}
	fitness::Real
end

# Basically all parameters passed to function
# Easy access, no sending with a function call everytime.
struct Model
	population::Vector{Pheno}
	size::Int
	m1r::Real
	m2r::Real
	m3r::Real
	halloffame::Set{Vector{String}}
end

# Here is the objective function
# k = args[1]
# p1 = args[2]
# ϵ = args[3]
# r = args[4]
function obj(sentence::Vector,params::Vector)
	# Convert sentence to single string
	str = mapreduce(x -> x.word,string,sentence)
	strlen = length(str)

	# Count the number of non matches palindrone style
	n = 0
	i = 1
	j = strlen
	while i < j
		n += str[i] == str[j] ? 0 : 2
		i += 1
		j -= 1
	end
	val = params[1]^(1 + n/strlen) - params[1]

	# Get p1, if there's no math words
	p1 = any(map(x -> x isa MathWord,sentence)) ? 0 : params[2] 

	# Get p2, based on length of sentence
	one = strlen - params[4]
	two = one*one
	four = two*two
	p2 = params[3]*four + 1

	# Return objective function
	return val*p2 + p1
end

# Function for mutatation, every parent has chance to mutate, compete with child
function mutate(f::Function,params::Vector,model::Model,words::Vector{Word},wordlen::Int)

	# Iterate everyone in the population, chance to mutate everyone in 3 different ways
	population = model.population
	for i = 1:model.size
		# Copy the sentence for this parent
		sentence = copy(population[i].sentence)

		# Mutation 1, chance to swap any word with another from database
		l = length(sentence)
		for j = 1:l
			r1 = rand()
			if r1 < 1/l*model.m1r
				sentence[j] = words[rand(1:wordlen)]
			end
		end

		# Mutation 2, inject random word anywhere in sentence
		r2 = rand()
		if r2 < model.m2r
			insert!(sentence,rand(1:l+1),words[rand(1:wordlen)])
		end
		l = length(sentence) # in case it's longer

		# Mutation 3, swap two words randomly
		r3 = rand()
		if r3 < model.m3r
			a = rand(1:l)
			b = rand(1:l)
			temp = sentence[a]
			sentence[a] = sentence[b]
			sentence[b] = temp
		end

		# Have this child compete with parent for survival
		fitness = f(sentence,params)
		if fitness < population[i].fitness
			population[i] = Pheno(sentence,fitness)
		end
	end
end

# Breeding function, and survival. low breed pressure, fair survival pressure
# vsrandom default true, false results for proportion
function breedandsurvive(f::Function,params::Vector,model::Model;
			 vsrandom::Bool=true,breedings::Int=model.size)
	# Get population
	population = model.population

	# Get sum of fitnesses
	fitsum = mapreduce(x -> x.fitness,+,population)
	
	# How many breedings
	for i = 1:breedings

		# Get index for random parent, get parents and their lengths
		p1dex,p2dex = sample(1:model.size,2,replace=false)
		p1 = population[p1dex].sentence
		p2 = population[p2dex].sentence
		p1len = length(p1)
		p2len = length(p2)

		# Get split point for each parent
		p1split = rand(1:p1len-1)
		p2split = rand(1:p2len-1)

		# Get splits for parents
		p1left = p1[1:p1split]
		p1right = p1[p1split+1:end]
		p2left = p2[1:p2split]
		p2right = p2[p2split+1:end]

		# Make 2 children using combinations
		c1 = vcat(p1left,p2right)
		c2 = vcat(p2left,p1right)

		# Evaluate fitness of children
		c1fitness = f(c1,params)
		c2fitness = f(c2,params)

		# Pick stronger child
		child = c1fitness < c2fitness ? Pheno(c1,c1fitness) : Pheno(c2,c2fitness)

		if vsrandom
			#Pick child against random parent, stronger survives
			pdex = rand(1:model.size)
			if child.fitness < population[pdex].fitness
				population[pdex] = child
			end
		else

			# Proportion selection for parent to face child
			# Weaker have higher chance to fight for survival
			r = rand()
			index = 1
			s = population[index].fitness/fitsum
			while index < model.size && r > s 
				index += 1
				s += population[index].fitness/fitsum
			end
			
			# Compete
			if child.fitness < population[index].fitness
				fitsum += child.fitness - population[index].fitness
				population[index] = child
			end
		end
	end
end

# Checks for palindromes
function induct(model::Model)
	palindromes = [model.population[i].sentence for i = 1:model.size if model.population[i].fitness == 0]
	for p in palindromes
		push!(model.halloffame,map(x -> x.word,p))
	end
end

# Lets begin the general frameword of the function,
# and fill in as needed.
# f(sentence,params)
function ea(f::Function,params::Vector;size::Int=75,
	    maxiter::Int=1000,m1r::Real=1,
	    m2r::Real=1/size,m3r::Real=m2r,breed::Bool=true,breedings::Int=model.size,vsrandom::Bool=false)

	# First let's read in the files, and get our list of words
	words = getdata("mathwords.txt","normalword.txt")
	wordlen = length(words)

	# Lets build a model, by randomly generating some Phenotypes
	population = Vector{Pheno}(undef,size)
	for i = 1:size
		len = rand(2:7)
		sentence = Vector{Word}(undef,len)
		for j = 1:len
			r = rand(1:wordlen)
			sentence[j] = words[r]
		end
		fitness = f(sentence,params)
		population[i] = Pheno(sentence,fitness)
	end
	halloffame = Set{Vector{String}}()
	model = Model(population,size,m1r,m2r,m3r,halloffame)
	y = zeros(maxiter)

	# Begin the evolutionary algorithm
	for i = 1:maxiter
	
		# Mutate
		mutate(f,params,model,words,wordlen)

		# Add any palindromes to hall of fame
		induct(model)

		# Breed and select for survival
		if breed
			breedandsurvive(f,params,model,vsrandom=vsrandom,breedings=breedings)

			# Add any palindromes to hall of fame
			induct(model)
		end

		# Print avgfitness
		y[i] = avgfitness(model.population)
	end

	# Print anyone in hall of fame
	for palindrome in model.halloffame
		for word in palindrome
			print(word," ")
		end
		println()
	end

	return model.population,model.halloffame,1:maxiter,y
end

# Printing average fitness
function avgfitness(population::Vector)
	return mapreduce(x -> x.fitness,+,population)/length(population)
end
