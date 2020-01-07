                                 #= Type aliases, and helpful functions =#
# For passing optional arguements to functions (mainly the temperature decreasing functions)
Maybe = Union{Float64,Nothing}

# Some constants
const MAX_ITER = 1e4
const MAX_FE = 1e6
const MAX_CONV = 1000

# Simple exponential decay
# ps[1]: α, exponential decay constant
function exponential(T::Float64,ps::Array{Float64,1}) return T*ps[1] end

# Shaving off same amount every iteration
# ps[1]: ϵ, small constant value taken off
function linear(T::Float64,ps::Array{Float64,1}) return T - ps[1] end


#Stopping criteria given by
# 1) Maximum number of function calls
# 2) Maximum number of iterations
# 3) Temperature reaching 0 or below
# 4) Not seeing improvement in recent iterations
function stoppingCriteria(iter::Int64,fe::Int64,T::Float64,convIter::Int64)
	if convIter > Inf
		println("Stopping because max convergence count of ",convIter," was achieved")
		return true
	end
	if iter > MAX_ITER
		println("Stopping because max iteration of ",iter," was achieved")
		return true
	end
	if fe > MAX_FE
		println("Stopping because max function evaluation of ",fe,"  was achieved")
		return true
	end
	if T < 0
		println("Stopping because temperature reached limit of 1e-7")
		return true
	end
	return false
end

#Update values to be within bounds if they are violated
function boundCheck(val::Float64,b::Tuple{Float64,Float64})
	if val <= b[2] && val >= b[1] return val
	else
		if val > b[2] return b[2]
		else return b[1] end
	end
end

#For use in a function call. Set vector a = b, internally in memory
function update(a::Vector{Float64},b::Vector{Float64})
	for i = 1:length(a)
		a[i] = b[i]
	end
end

#For use in a function call. Set diagonal matrix a = b, internally in memory
function updateDiag(a::Matrix{Float64},b::Matrix{Float64},op::Function)
	dim = size(a)[1]
	for i = 1:dim
		a[i,i] = op(a[i,i],b[i,i])
	end
end

#Reach thermal equilibrium
function thermalEquilibrium(X0::Vector{Float64},Xbest::Vector{Float64},xbest::Float64,D::Matrix{Float64},Dx::Matrix{Float64},
			    bounds::Array{Tuple{Float64,Float64},1},f::Function,T::Float64,sample::Int64,convIter::Int64)

	tol = sample*0.1
	fit0 = f(X0)
	len = length(X0)
	ϵ = 1e-5
	pass = 0
	fail = 0
	for i = 1:sample
		#Calculate R and the new 
		R = map(x -> (x - 0.5)*2,rand(len))
		X1 = X0 + D*R
		X1 = map((x,y) -> boundCheck(x,y),X1,bounds)
		fit1 = f(X1)

		#Mark that we will take this answer if better or coin flip
		took = false
		if fit1 < fit0 
			took = true
		else
			prob = exp(-(fit1 - fit0)/T)
			if rand() < prob 
				took = true 
			end
		end
		
		#If we take it, update convIter if necessary, update X0 and fit0
		if took
			convIter = abs(fit0 - fit1) < ϵ ? convIter + 1 : 0
			update(X0,X1)
			fit0 = fit1
			if fit0 < xbest
				xbest = fit0
				update(Xbest,X0)
			end
			pass += 1
		else 
			fail += 1
		end
	end

	#Check for thermal equilibrium
	if abs(pass - fail) < tol
		return (true,convIter)
	else 
		if pass > fail 
			updateDiag(D,Dx,/)
		else 
			updateDiag(D,Dx,*) end
		return(false,convIter)
	end
end

#=
# f: The objective function to minimize
# D: A diagonal matrix with the maximum values for changing current solution
# Dx: A diagonal matrix to scale D up or down depending on thermal equilibrium requirements
# X0: The initial solution vector
# T: The initial temperature
# Tf: The function for decreasing the temperature
# Tp: The parameters to be passed to Tf
# bounds: The bounds for every dimension of the problem, default is infinity for all) =#
function sa(f::Function,D::Matrix{Float64},Dx::Matrix{Float64},
	    X0::Vector{Float64}, T::Float64, Tf::Function, Tp::Array{Maybe,1},
	    bounds::Array{Tuple{Float64,Float64},1}=repeat([(-Inf,Inf)],length(X0)))

	#Fix the values in the Tp to have default values based on the function 
	#Add more functions here for temperature update as necessary
	defExp = [0.95]
	defLin = [0.01618]

	if Tf == exponential
		Tp = map((x,y) -> x == nothing ? y : x,Tp,defExp)
	elseif Tf == linear
		Tp = map((x,y) -> x == nothing ? y : x,Tp,defLin)
	else
		Tp = map(x -> x, Tp)
	end

	#Values needed for main algorithm
	iter = 0
	fe = 0
	convIter = 0
	sample = 100
	Xbest = deepcopy(X0)
	xbest = f(Xbest)

	#The main SA algorithm
	while(!stoppingCriteria(iter,fe,T,convIter))
		println(T)

		#Attempt to achieve thermal equilibrium until reached
		(verdict,convIter) = thermalEquilibrium(X0,Xbest,xbest,D,Dx,bounds,f,T,sample,convIter)
		while(!verdict)
			fe += sample
			if convIter > Inf  ||  fe > MAX_FE break end
			(verdict,convIter) = thermalEquilibrium(X0,Xbest,xbest,D,Dx,bounds,f,T,sample,convIter)
		end

		#Thermal equilibrium has been reached, decrease temperature
		T = Tf(T,Tp)

		#Increase stopping criteria variable
		iter += 1
	end
	return (X0,Xbest)
end
