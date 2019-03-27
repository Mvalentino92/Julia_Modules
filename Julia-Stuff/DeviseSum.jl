#Does stuff!
function deviseSum(target::Int64,arr::Array{Int64,1})
	if target == 0 return "" end
	if length(arr) == 0 return "X" end
	if !ismissing(table[target]) return table[target] end
	tail = deepcopy(arr)
	if length(tail) == 1 tail = Array{Int64,1}()
	else pop!(tail) end
	for i in arr
		upper = Int64(trunc(target/i))
		for k = upper:-1:1
			table[i*k] = "$i*$k"
			val = string(table[i*k]," + ",deviseSum(target - i*k,tail))
			if ismissing(table[target]) && val[end] != 'X' 
				table[target] = val
				break
			end
		end
		if !ismissing(table[target]) break end
		val = string("",deviseSum(target,tail))
		if ismissing(table[target]) && val[end] != 'X' 
			table[target] = val
			break
		end
	end
	if ismissing(table[target]) return "X"
	else return table[target] end
end

#Stuff being done
n = 6584
nums = [87,161,213]
table = Array{Union{String,Missing},1}(missing,n)
println("$(deviseSum(n,nums)) = $n")
