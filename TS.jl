#Possibly generic for all problems. 
struct Solution{T <: Real}
	vec::Vector{T}
	fitness::Real
end

#Generate random number in range (Possibly generic for all problems
function randb(min::Real,max::Real)
	return min + rand()*(max - min)
end

#Generate neighborhood
function generateneighborhood(f::Function,X0::Vector{T},reach::Real,size::Int64) where T <: Real

	dim = length(X0)
	neighborhood = Vector{Solution}(undef,size)

	#Get bounds for each dimension and begin to generate
	bounds = map(x -> (x-reach,x+reach),X0)
	for i = 1:size
		vec = zeros(Float64,dim)
		for j = 1:dim
			vec[j] = randb(bounds[j][1],bounds[j][2])
		end
		neighborhood[i] = Solution(vec,f(vec))
	end
	return neighborhood
end

#Check if tabu solution vector is tabu
function istabu(x0::Vector{Float64},tabulist::Vector{Solution},tol::Real)
	for tabu in tabulist
		if sqrt(mapreduce((x,y) -> (x-y)*(x-y),+,x0,tabu.vec)) < tol return true
		end
	end
	return false
end

#Percent error
function error(actual::Real,expected::Real)
	return abs(actual - expected)/expected*100 < rand()
end

function tabusearch(f::Function,X0::Vector{T}; reach::Real=500,delta::Real=0.98789, elite_size::Int64=21,
		    max_iter::Int64=1000, tabu_size::Int64=div(max_iter,7),neighborhood_size::Int64=1000) where T <: Real
	#Init initial and best solution etc
	dim = length(X0)
	X0 = Solution(X0,f(X0))
	Xbest = X0
	tabu_index = 1
	elite_index = 1
	tol = sqrt(reach)

	#Initialize tabu list and elite
	tabulist = Vector{Solution}(undef,tabu_size)
	elitelist = Vector{Solution}(undef,elite_size)
	for i = 1:tabu_size
		tabulist[i] = Solution(repeat([Inf],dim),0)
	end
	for i = 1:elite_size
		elitelist[i] = Solution(repeat([Inf],dim),Inf)
	end

	markedtabu = false
	iter = 0
	while !markedtabu && iter < max_iter #While all not tabu or iterations left
		#Generate the neighborhood
		neighborhood = generateneighborhood(f,X0.vec,reach,neighborhood_size)

		#Sort it by value
		sort!(neighborhood,by=(x -> x.fitness))

		#Check for tabu
		for neighbor in neighborhood
			markedtabu = istabu(neighbor.vec,tabulist,tol)

			#If not tabu, make current solution
			if !markedtabu 
				#Update values
				X0 = neighbor
				Xbest = X0.fitness < Xbest.fitness ? X0 : Xbest

				#Update elite
				if error(X0.fitness,Xbest.fitness)
					elitelist[elite_index] = X0
					elite_index = elite_index + 1 > elite_size ? 1 : elite_index + 1
				end

				#Add to tabu list
				tabulist[tabu_index] = X0
				tabu_index = tabu_index + 1 > tabu_size ? 1 : tabu_index + 1
				break
			end
		end

		#Update reach bound
		reach *= delta
		tol = sqrt(reach)
		iter += 1

	end
	return (Xbest,map(x -> x.vec,elitelist))
end
