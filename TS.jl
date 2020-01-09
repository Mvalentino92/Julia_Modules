struct Solution{T <: Real}
	vec::Vector{T}
	fitness::Real
end

#Generate random number in range
function randb(min::Real,max::Real)
	return min + rand()*(max - min)
end

#Generate neighborhood
function generateneighborhood(f::Function,X0::Vector{T},reach::Real,size::Int64) where T <: Real
	dim = length(X0)
	neighborhood = Vector{Solution}(undef,size)

	#Get bounds for each dimension
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

#Check if tabu
function istabu(x0::Vector{Float64},tabulist::Vector{Solution},tabu::Real)
	for i in tabulist
		if sqrt(mapreduce((x,y) -> (x-y)*(x-y),+,x0,i.vec)) < tabu return true
		end
	end
	return false
end

function tabusearch(f::Function,X0::Vector{T}; reach::Real=500, elite::Int64=21, max_iter::Int64=10000,
		    tabu::Int64=div(max_iter,7),size::Int64=1000) where T <: Real
	dim = length(X0)
	X0 = Solution(X0,f(X0))
	Xbest = deepcopy(X0)
	index = 1
	forbidden = sqrt(reach)

	#Initialize tabu list
	tabulist = Vector{Solution}(undef,tabu)
	for i = 1:tabu
		tabulist[i] = Solution(repeat([Inf],dim),0)
	end

	markedtabu = false
	iter = 0
	while !markedtabu && iter < max_iter #While all not tabu or iterations left
		#Generate the neighborhood
		neighborhood = generateneighborhood(f,X0.vec,reach,size)

		#Sort it by value
		sort!(neighborhood,by=(x -> x.fitness))

		#Check for tabu
		for neighbor in neighborhood
			markedtabu = istabu(neighbor.vec,tabulist,forbidden)

			#If not tabu, make current solution
			if !markedtabu 

				#Update values
				X0 = neighbor
				Xbest = X0.fitness < Xbest.fitness ? deepcopy(X0) : Xbest

				#Add to tabu list
				tabulist[index] = X0
				index = index + 1 > tabu ? 1 : index + 1
				
				break
			end
		end

		#Update reach bound
		reach *= 0.98789
		forbidden = sqrt(reach)
		iter += 1
	end
	println(iter)
	return Xbest
end
