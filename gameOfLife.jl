function update(mat)
	#Create new matrix to return
	n = size(mat)[1]
	retval = zeros(Int64,n,n)

	#Iterate the inner matrix
	#k is row, l is column. i is row, j is column
	for k = 2:n-1
		for l = 2:n-1
			neighbors = 0
			for i = k-1:k+1
				for j = l-1:l+1
					neighbors += mat[i,j] == 1 ? 1 : 0
				end
			end
			if mat[k,l] == 1
				neighbors -= 1
				if neighbors < 2 || neighbors > 3
					retval[k,l] = 0
				else retval[k,l] = 1 end
			else
				if neighbors == 3
					retval[k,l] = 1
				else retval[k,l] = 0 end
			end
		end
	end
	
	#Iterate top middle
	for l = 2:n-1
		neighbors = 0
		for i = 1:2
			for j = l-1:l+1
				neighbors += mat[i,j] == 1 ? 1 : 0
			end
		end
		if mat[1,l] == 1
			neighbors -= 1
			if neighbors < 2 || neighbors > 3
				retval[1,l] = 0
			else retval[1,l] = 1 end
		else
			if neighbors == 3
				retval[1,l] = 1
			else retval[1,l] = 0 end
		end
	end

	#Iterate bottom middle
	for l = 2:n-1
		neighbors = 0
		for i = n-1:n
			for j = l-1:l+1
				neighbors += mat[i,j] == 1 ? 1 : 0
			end
		end
		if mat[n,l] == 1
			neighbors -= 1
			if neighbors < 2 || neighbors > 3
				retval[n,l] = 0
			else retval[n,l] = 1 end
		else
			if neighbors == 3
				retval[n,l] = 1
			else retval[n,l] = 0 end
		end
	end

	#Iterate left middle
	for k = 2:n-1
		neighbors = 0;
		for i = k-1:k+1
			for j = 1:2
				neighbors += mat[i,j] == 1 ? 1 : 0
			end
		end
		if mat[k,1] == 1
			neighbors -= 1
			if neighbors < 2 || neighbors > 3
				retval[k,1] = 0
			else retval[k,1] = 1 end
		else
			if neighbors == 3
				retval[k,1] = 1
			else retval[k,1] = 0 end
		end
	end
	
	#Iterate right middle
	for k = 2:n-1
		neighbors = 0;
		for i = k-1:k+1
			for j = n-1:n
				neighbors += mat[i,j] == 1 ? 1 : 0
			end
		end
		if mat[k,n] == 1
			neighbors -= 1
			if neighbors < 2 || neighbors > 3
				retval[k,n] = 0
			else retval[k,n] = 1 end
		else
			if neighbors == 3
				retval[k,n] = 1
			else retval[k,n] = 0 end
		end
	end

	neighbors = 0
	#Left Top Corner
	neighbors += mat[1,2] == 1 ? 1 : 0
	neighbors += mat[2,1] == 1 ? 1 : 0
	neighbors += mat[2,2] == 1 ? 1 : 0
	if mat[1,1] == 1
		if neighbors < 2 || neighbors > 3
			retval[1,1] = 0
		else retval[1,1] = 1 end
	else
		if neighbors == 3
			retval[1,1] = 1
		else retval[1,1] = 0 end
	end

	neighbors = 0
	#Left Bottom Corner
	neighbors += mat[n-1,1] == 1 ? 1 : 0
	neighbors += mat[n-1,2] == 1 ? 1 : 0
	neighbors += mat[n,2] == 1 ? 1 : 0
	if mat[n,1] == 1
		if neighbors < 2 || neighbors > 3
			retval[n,1] = 0
		else retval[n,1] = 1 end
	else
		if neighbors == 3
			retval[n,1] = 1
		else retval[n,1] = 0 end
	end

	neighbors = 0
	#Right top Corner
	neighbors += mat[1,n-1] == 1 ? 1 : 0
	neighbors += mat[2,n-1] == 1 ? 1 : 0
	neighbors += mat[2,n] == 1 ? 1 : 0
	if mat[1,n] == 1
		if neighbors < 2 || neighbors > 3
			retval[1,n] = 0
		else retval[1,n] = 1 end
	else
		if neighbors == 3
			retval[1,n] = 1
		else retval[1,n] = 0 end
	end

	neighbors = 0
	#Right bottom Corner
	neighbors += mat[n-1,n] == 1 ? 1 : 0
	neighbors += mat[n-1,n-1] == 1 ? 1 : 0
	neighbors += mat[n,n-1] == 1 ? 1 : 0
	if mat[n,n] == 1
		if neighbors < 2 || neighbors > 3
			retval[n,n] = 0
		else retval[n,n] = 1 end
	else
		if neighbors == 3
			retval[n,n] = 1
		else retval[n,n] = 0 end
	end
	return retval
end

function printGame(mat)
	n = size(mat)[1]
	for i = 1:n
		for j = 1:n
			print("$(mat[i,j]) ")
		end
		println()
	end
end

n = 50
game = zeros(Int8,n,n)
for i = 1:n*n/1.5
	row = rand(1:n,1)[1]
	col = rand(1:n,1)[1]
	global game[row,col] = 1
end

for i = 1:10000
	printGame(game)
	global game = update(game)
	println()
end
