function check(a::Function,b::Function,c::Function)
	arr = rand(-100000:100000,35000)
	@time x = a(arr)
	@time y = b(arr,1,length(arr))
	@time z = c(arr)
	println("\nO(n^2) solution: ",x)
	println("O(nlogn) solution: ",y)
	println("O(n) solution: ",z)
	println("\nCorresponding times above")
end

#O(n^2) algorithm to find the max sub array. Brute force solution.
function nsquared(arr::Array{Int64,1})
	max = -Inf
	for i in 1:length(arr)
		currentMax = 0
		for j in i:length(arr)
			currentMax += arr[j]
			max = max > currentMax ? max : currentMax
		end
	end
	return max
end

#O(nlogn) algorithm to find max sub array. Recursive.
function nlogn(arr::Array{Int64,1},s::Int64,t::Int64)
	if s == t return arr[s] end
	mid = div(s+t,2)
	left = nlogn(arr,s,mid)
	right = nlogn(arr,mid+1,t)
	cross = crossOver(arr,s,mid,t)
	return max(cross,max(left,right))
end

#Helper
function crossOver(arr::Array{Int64,1},s::Int64,mid::Int64,t::Int64)
	leftMax = -Inf
	left = 0
	for i = mid:-1:s
		left += arr[i]
		leftMax = left > leftMax ? left : leftMax
	end

	rightMax = -Inf
	right = 0
	for i = mid+1:t
		right += arr[i]
		rightMax = right > rightMax ? right : rightMax
	end
	return leftMax + rightMax
end


#O(n) algorithm to find the max sub array. Fastest solution
function linear(arr::Array{Int64,1})
	max = -Inf
	jMax = -Inf
	for i in arr
		jMax = jMax + i > i ? jMax + i : i
		max = jMax > max ? jMax : max
	end
	return max
end

check(nsquared,nlogn,linear)
