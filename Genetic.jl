using Statistics
using StatsBase

#Mutates the number, by dividing or multiplying by a number in the range (1,2)
function mutate(n::Float64)
	k = rand() + 1
	if(rand() < 0.5) return n*k
	else return n/k end
end

#Returns true if the population is too similar
function diversity(pop::Array{Float64,1})
	diffAVG = sum(diff(sort(pop)))/length(pop)
	if diffAVG < 0.05 return true
	else return false end
end

#Grabs the strongest members of the population
function grabStrong(f::Function,pop::Array{Float64,1})
	vals = map(f,pop)
	avg = mean(vals)
	strong = Array{Float64,1}()
	for i = 1:length(pop)
		if vals[i] <= avg push!(strong,pop[i]) end
	end
	return strong
end

#Converts from number to digits (in an array)
function numToDig(n::Int64)
	retval = Array{Int64,1}()
	while n > 0
		prepend!(retval,n%10)
		n = div(n,10)
	end
	return retval
end

#Converts from an Array of digits, to a number
function digToNum(ns::Array{Int64,1})
	retval = 0
	for i in ns
		retval *= 10
		retval += i
	end
	return retval
end

#Create children a different way (better!)
function createChild2(x::Float64,y::Float64)
	sign = 0
	if x > 0 && y > 0 sign = 1
	elseif x < 0 && y < 0 sign = -1
	else 
		if rand() < 0.5 sign = 1
		else sign = -1 end
	end
	x = abs(x)
	y = abs(y)

	xint = Int64(trunc(x))
	yint = Int64(trunc(y))

	xdec = Int64(trunc((x%1)*1e9))
	ydec = Int64(trunc((y%1)*1e9))

	intval = 0
	k = 0
	while xint > 0 && yint > 0
		xdig = xint % 10
		ydig = yint % 10
		if rand() < 0.5 intval += xdig*10^k
		else intval += ydig*10^k end
		xint = div(xint,10)
		yint = div(yint,10)
		k += 1
	end
	if rand() < 0.5
		while xint > 0
			xdig = xint % 10
			intval += xdig*10^k
			xint = div(xint,10)
			k += 1
		end
		while yint > 0
			ydig = yint % 10
			intval += ydig*10^k
			yint = div(yint,10)
			k += 1
		end
	end

	decval = 0
	k = 0
	while xdec > 0 && ydec > 0
		xdig = xdec % 10
		ydig = ydec % 10
		if rand() < 0.5 decval += xdig*10^k
		else decval += ydig*10^k end
		xdec = div(xdec,10)
		ydec = div(ydec,10)
		k += 1
	end
	if rand() < 0.5
		while xdec > 0
			xdig = xdec % 10
			decval += xdig*10^k
			xdec = div(xdec,10)
			k += 1
		end
		while ydec > 0
			ydig = ydec % 10
			decval += ydig*10^k
			ydec = div(ydec,10)
			k += 1
		end
	end

	retval = intval + (decval/1e9)
	if rand() < 0.1 retval = mutate(retval) end
	return retval*sign
end

#Creates child from two parents (use second version!)
function createChild(x::Float64,y::Float64)
	sign = 0
	if x > 0 && y > 0 sign = 1
	elseif x < 0 && y < 0 sign = -1
	else 
		if rand() < 0.5 sign = 1
		else sign = -1 end
	end
	x = abs(x)
	y = abs(y)

	xint = numToDig(Int64(trunc(x)))
	yint = numToDig(Int64(trunc(y)))

	xdec = numToDig(Int64(trunc((x%1)*1e9)))
	ydec = numToDig(Int64(trunc((y%1)*1e9)))

	intval = Array{Int64,1}()
	decval = Array{Int64,1}()

	i = 1
	while i <= length(xint) && i <= length(yint)
		if rand() < 0.5 push!(intval,xint[i])
		else push!(intval,yint[i]) end
		i += 1
	end
	if rand() < 0.5
		while i <= length(xint) 
			push!(intval,xint[i])
			i += 1
		end
		while i <= length(yint) 
			push!(intval,yint[i])
			i += 1
		end
	end

	i = 1
	while i <= length(xdec) && i <= length(ydec)
		if rand() < 0.5 push!(decval,xdec[i])
		else push!(decval,ydec[i]) end
		i += 1
	end
	if rand() < 0.5
		while i <= length(xdec) 
			push!(decval,xdec[i])
			i += 1
		end
		while i <= length(ydec) 
			push!(decval,ydec[i])
			i += 1
		end
	end

	retval = digToNum(intval) + (digToNum(decval)/1e9)
	if rand() < 0.1 retval = mutate(retval) end
	return retval*sign
end


#Creates the next generation
function nextGen(f::Function,pop::Array{Float64,1})
	retval = zeros(Float64,length(pop))
	strong = grabStrong(f,pop)
	l = length(strong)
	i = 1
	while i <= length(retval)
		retval[i] = createChild2(strong[rand(1:l)],strong[rand(1:l)])
		i += 1
	end
	return retval
end

#Creat initial population between bounds
function createPop(a::Int64,b::Int64,n::Int64) return rand(a:b,n) + rand(n) end

#Try to solve problem
f(x) = 2*x*sin(0.5*x)^2 - 0.0025*x^3 + 0.00007*x^4
pop = createPop(-200,200,120)
c = 0

while !diversity(pop)
	global c,pop
	pop = nextGen(f,pop)
	c += 1
end

println(c)
println(minimum(map(f,pop)))
