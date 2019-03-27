#Does stuff!
function deviseSum(target::Int64,arr::Array{Int64,1},index::Int64,len::Int64)
	if target == 0 return "" end #Hit target, return empty
	if index > len return "X" end #Ran out of numbers, failure X
	if !ismissing(table[target]) return table[target] end #Seen it, return
	for i = index:len
		n = arr[i]
		upper = Int64(trunc(target/n))
		for k = upper:-1:1
			table[n*k] = "$n*$k"
			val = string(table[n*k]," + ",deviseSum(target - n*k,arr,index+1,len))
			if ismissing(table[target]) #No value here?
				     if val[end] != 'X' #Hey, it wasn't a failure!
					     table[target] = val #Update value!
					     return val #Return it!
				     end
			else return table[target] end #Oh we found it!
		end
	end
	return "X"
end

#Stuff being done
n = rand(2:10000,1)[1]
l = 3
x = div(n,l*10)
if x > 2*l
	nums = rand(2:div(n,l*10),l)
	table = Array{Union{String,Missing},1}(missing,n)
	println("$(deviseSum(n,nums,1,l)) = $n")
end
