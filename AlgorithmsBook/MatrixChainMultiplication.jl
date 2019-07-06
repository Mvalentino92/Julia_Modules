function recur(A::Array{Tuple{Int64,Int64},1},solMatrix::Array{Int64,2},i::Int64,j::Int64)
	#Base case (covers if you need 0 as well)
	if solMatrix[i,j] < typemax(Int64) return solMatrix[i,j] end

	for k = i:j-1
		currentCost = recur(A,solMatrix,i,k) + recur(A,solMatrix,k+1,j) + A[i][1]*A[k][2]*A[j][2]
		if currentCost < solMatrix[i,j]
			solMatrix[i,j] = currentCost
			solMatrix[j,i] = k
		end
	end
	return solMatrix[i,j]
end

function chainMultMemo(matrices::Array{Array{Int64,2},1})
	#First construct the Array of dimension tuples
	Alength = length(matrices)
	A = Array{Tuple{Int64,Int64}}(undef,Alength)
	for i = 1:Alength
		A[i] = size(matrices[i])
	end

	#Construct the matrix that will hold all the costs for
	#multiplying the matrices i -> j on the upper right diagonal
	#and index of k (for splitting the chain i -> j into two parenthesis)
	#on the lower left diagonal. (the map to the solution) 
	#NOTE, i and j will be switched.
	#Since i is ALWAYS <= j. I'm just doing this to save space, and not 
	#create two matrices whom both have no entries in the lower diagonal.
	#The major diagonal will remain zeros, and act as a barrier to split the
	#uses the upper right, and lower left.
	#With respect to the costs (upper right), it is the trivial solution, so it is 0.
	#With respect to the mapping (lower left), it needs no value.
	solMatrix = zeros(Int64,Alength,Alength)
	for i = 1:Alength
		for j = 1:Alength
			if i != j solMatrix[i,j] = typemax(Int64) end
		end
	end

	#Call memo
	recur(A,solMatrix,1,Alength)
	
	#Use the lower half of the matrix to compute the solution
	print("Memo matrix mult time: ")
	retval = @time solver(matrices,solMatrix,Alength,1)
	print("Memo total execution time: ")
	return retval
end

function chainMultTab(matrices::Array{Array{Int64,2},1})
	#First construct the Array of dimension tuples
	Alength = length(matrices)
	A = Array{Tuple{Int64,Int64}}(undef,Alength)
	for i = 1:Alength
		A[i] = size(matrices[i])
	end

	#Construct the matrix that will hold all the costs for
	#multiplying the matrices i -> j on the upper right diagonal
	#and index of k (for splitting the chain i -> j into two parenthesis)
	#on the lower left diagonal. (the map to the solution) 
	#NOTE, i and j will be switched.
	#Since i is ALWAYS <= j. I'm just doing this to save space, and not 
	#create two matrices whom both have no entries in the lower diagonal.
	#The major diagonal will remain zeros, and act as a barrier to split the
	#uses the upper right, and lower left.
	#With respect to the costs (upper right), it is the trivial solution, so it is 0.
	#With respect to the mapping (lower left), it needs no value.
	solMatrix = zeros(Int64,Alength,Alength)
	for i = 1:Alength
		for j = 1:Alength
			if i != j solMatrix[i,j] = typemax(Int64) end
		end
	end

	#Begin tabulation
	for s = 1:Alength-1
		i = 1
		j = i + s
		while j <= Alength
			for k = i:j-1
				currentCost = solMatrix[i,k] + solMatrix[k+1,j] + A[i][1]*A[k][2]*A[j][2]
				if currentCost < solMatrix[i,j]
					solMatrix[i,j] = currentCost
					solMatrix[j,i] = k
				end
			end
			i += 1
			j += 1
		end
	end
	
	#Use the lower half of the matrix to compute the solution
	print("Tab matrix mult time: ")
	retval = @time solver(matrices,solMatrix,Alength,1)
	print("Tab total execution time: ")
	return retval
end

function solver(matrices::Array{Array{Int64,2},1},mapping::Array{Int64,2},i::Int64,j::Int64)
	#Base cases (j is less than i, must multiply in this order)
	if i == j return matrices[i] end
	if i - 1 == j return matrices[j]*matrices[i] end

	k = mapping[i,j]
	return solver(matrices,mapping,k,j) * solver(matrices,mapping,i,k+1);
end

function bruteForce(matrices::Array{Array{Int64,2},1})
	retval = matrices[1]
	for i = 2:length(matrices)
		retval = retval * matrices[i]
	end
	return retval
end

matrices = Array{Array{Int64,2}}(undef,128)
a = rand(-10:10,rand(2:1024),rand(2:1024))
matrices[1] = a
for i = 2:length(matrices)
	m = size(matrices[i-1])[2]
	next = rand(-10:10,m,rand(2:1024))
	matrices[i] = next
end

@time x = chainMultTab(matrices)
@time y = chainMultMemo(matrices)
print("Brute: ")
@time z = bruteForce(matrices)
x == y == z
