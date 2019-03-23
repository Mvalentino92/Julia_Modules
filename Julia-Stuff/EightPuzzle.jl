using DataStructures
using Random

#Node struct
mutable struct Node
	board::Array{Int8,1}
	depth::Int8
	parent::(Union{Node,Nothing})
	child::(Union{Node,Nothing})
end

#Function to generate all the permutations of a list
function permutations(xs)
	l = length(xs)
	if length(xs) == 1 return [[xs[1]]] end
	retval = []
	for i = 1:l
		head = splice!(xs,i)
		xsp = permutations(xs)
		for i in xsp prepend!(i,head) end
		splice!(xs,i:0,head)
		append!(retval,xsp)
	end
	return retval
end

#Generate children
function genChildren(xs)
	retval = Array{Array{Int8,1},1}()
	index = indexin(0,xs)[1]
	for i in [1,-1]
		s = index + i
		if s >= 1 && s <= 9
			if((index in [1,2,3] && s in [1,2,3])
			|| (index in [4,5,6] && s in [4,5,6])
			|| (index in [7,8,9] && s in [7,8,9]))
				xsp = deepcopy(xs)
				temp = xsp[index]
				xsp[index] = xsp[s]
				xsp[s] = temp
				push!(retval,xsp)
			end
		end
	end
	for i in [3,-3]
		s = index + i
		if s >= 1 && s <= 9
			xsp = deepcopy(xs)
			temp = xsp[index]
			xsp[index] = xsp[s]
			xsp[s] = temp
			push!(retval,xsp)
		end
	end
	return retval
end

#Get the goodness value of this board
function g(xs)
	retval = 0
	ys = [1,2,3,4,5,6,7,8,0]
	for i = 1:9
		if xs[i] != ys[i] retval += 1 end
	end
	return retval
end

#Returns if a board is solvable or not
function isSolvable(xs)
	inv = 0
	for i = 1:8
		for j = i+1:9
			if xs[i] > xs[j] && xs[j] > 0 inv += 1 end
		end
	end
	return inv % 2 == 0 && inv > 0
end

#Get the depth of current run
function getDepthAndPath(node)
	depth = 0
	while node.parent != nothing
		depth += 1
		node.parent.child = node
		node = node.parent
	end
	return (depth,node)
end

#Prints all info
function printInfo(node,count)
	(depth,node) = getDepthAndPath(node)
	println("It took $count iterations with a depth of $depth and a path of:")
	while node != nothing
		i = 0
		print("Press ENTER to see next move: ")
		readline()
		for j = 1:3
			for k = 1:3
				i += 1
				n = node.board[i]
				if node.child != nothing
					if node.child.board[i] == 0
						printstyled("$n ", color = :light_red)
						continue
					end
				end
				if n == 0 printstyled("$n ",color = :red)
				else print("$n ") end
			end
			println()
		end
		println()
		node = node.child
	end	
	println("Finished! Calculating next solution...")
end


#Create initial variables
print("Enter value for alpha: ")
α = parse(Float64,readline())
print("Enter value for beta: ")
β = parse(Float64,readline())
print("Enter a max depth, delta (or 0 for no max): ")
δ = parse(Int64,readline())

println("Creating boards and solving first board...")
allBoards = permutations(Array{Int8,1}([0,1,2,3,4,5,6,7,8]))
allBoards = filter(isSolvable,allBoards)

for board in shuffle(allBoards)
	dict = Dict()
	op = PriorityQueue() #Initialize OPEN (priority queue)
	op[Node(board,0,nothing,nothing)] = α*0 + β*g(board) #Place start node on OPEN
	dict[board] = (0,nothing)
	cl = Array{Array{Int8,1},1}() #Initialize CLOSED
	
	head = nothing
	count = 0
	while !isempty(op) #Loop while OPEN is not empty
		count += 1
		head = dequeue!(op) #Get best node (parent, im calling it head) from OPEN
		if δ > 0 && head.depth >= δ continue end
		if head.board == [1,2,3,4,5,6,7,8,0] break end #If parent/head is goal node, done
		currentDepth = head.depth + 1
		push!(cl,head.board) #Place parent/head on CLOSED
		children = genChildren(head.board) #Expand parent/head to children (adj nodes)
		for c in children
			if c in cl continue end #If adj_node (child) is on CLOSED, discard
			(depth,parent) = get(dict,c,(-1,nothing))
			if depth == -1
				op[Node(c,currentDepth,head,nothing)] = α*currentDepth + β*g(c) #if not in OPEN, add
				dict[board] = (currentDepth,head)
			else
				if currentDepth < depth
					n = getkey(op,Node(c,depth,parent),0)
					op[n] = α*currentDepth + β*g(c)	
					dict[c] = (currentDepth,head)
					n.depth = currentDepth
					n.parent = head
				end
			end
		end
	end
	print("Press ENTER to begin next solution: ")
	readline()
	printInfo(head,count)
end
