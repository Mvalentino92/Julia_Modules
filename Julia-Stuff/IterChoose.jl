function choose(arr,c)
	index = 1
	table = zeros(Int64,c)
	table[1] = 1
	current = Array{typeof(arr[1]),1}()
	retval = Array{Array{typeof(arr[1]),1},1}()

	while table[1] <= length(arr) - c + 1
		while index > 0 && table[index] <= length(arr) - c + 1
			if c > 1
				push!(current,arr[table[index]])
				c -= 1
				table[index] += 1
				table[index+1] = table[index]
				index += 1
			else
				append!(retval,map(x -> push!(deepcopy(current),x),arr[table[index]:end]))
				c += 1
				index -= 1
				current = current[1:end-1]
			end
		end
		c += 1
		index -= 1
		current = current[1:end-1]
	end
	return retval
end
