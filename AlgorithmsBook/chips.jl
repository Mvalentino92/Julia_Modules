N = 1000000
function wrapper(indices::Array{Int64,1},arr::Array{Int64,1})
	len = length(indices)
	if len < 3 return indices[1] end
	if len == 3
		if arr[indices[1]] * arr[indices[2]] > 0 return indices[1]
		else return indices[3] end
	end

	indicesNext = Array{Int64,1}()
	i = 2
	while i <= len
		if arr[indices[i]] * arr[indices[i-1]] > 0
			push!(indicesNext,indices[i])
		end
		i += 2
	end
	if len % 2 == 1 && length(indicesNext) % 2 == 0 push!(indicesNext,indices[end]) end
	return wrapper(indicesNext,arr)
end

function solver(arr::Array{Int64,1})
	indices = Array{Int64,1}(undef,length(arr))
	for i = 1:length(indices) indices[i] = i end
	good = arr[wrapper(indices,arr)]
	retval = Array{Int64,1}()
	for i = 1:length(arr)
		if arr[i] * good > 0
			push!(retval,i)
		end
	end
	return retval
end

function makeArray()
	val = [1,-1]
	arr = zeros(Int64,N)
	for i = 1:N
		arr[i] = val[rand(1:2,1)[1]]
	end
	while sum(arr) <= 0
		change = rand(1:N,div(N,10))
		for i in change
			arr[i] = 1
		end
	end
	return arr
end

function checkCorrect(arr,indices)
	correct = Array{Int64,1}()
	for i = 1:length(arr)
		if arr[i] == 1
			push!(correct,i)
		end
	end
	if sort(indices) == correct return true
	else return false end
end

arr = makeArray()
@time mine = solver(arr)
println(checkCorrect(arr,mine))
