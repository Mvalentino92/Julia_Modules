function randomsearch(f::Function,bounds::Vector,maxiter::Int,params::Vector=[])
	dim = length(bounds)
	mnvec = zeros(dim)
	mnval = Inf
	iter = 0

	while iter < maxiter
		vec = similar(mnvec)
		for j = 1:dim
			vec[j] = randb(bounds[j][1],bounds[j][2])
		end
		val = f(vec,params)
		if val < mnval 
			#Update
			mnval = val
			mnvec = vec

			#Exploit
			exploitvec = mnvec
			for i = 1:(maxiter-iter)*0.01
				vec = similar(mnvec)
				for j = 1:dim
					vec[j] = randb(exploitvec[j]-1,exploitvec[j]+1)
				end
				val = f(vec,params)
				if val < mnval 
					#Update
					mnval = val
					mnvec = vec
				end
				iter += 1
			end
		end
		iter += 1
	end
	return (mnvec,mnval)
end
