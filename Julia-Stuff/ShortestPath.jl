using DataStructures

#Node class
mutable struct Node
	node::String
	cost::Float64
	parent::(Union{Node,Nothing})
	child::(Union{Node,Nothing})
end

#Creates the graph from user input
function createGraph()
	retval = Dict{String,Array{Tuple{String,Float64},1}}()
	#print("How many nodes will be on the graph?: ")
	size = parse(Int64,readline())
	for i in 1:size
	#	print("Enter new node: ")
		k = readline()
		v = Array{Tuple{String,Float64},1}()
	#	println("Please enter adjacent nodes and their distance in the format \"node distance\".")
	#	println("Input \"stop\" when you are done.")
	#	print("node distance: ")
		next = split(readline())
		while next[1] != "stop"
			push!(v,(next[1],parse(Float64,next[2])))
	#		print("node distance: ")
			next = split(readline())
		end
		retval[k] = v
	end
	return retval
end

#Check if on closed list
function inClosed(current::Node, dest::(Union{Node,Nothing}), target::String)
	while current != dest
		if current.node == target return true end
		current = current.child
	end
	return false
end

#Link the solution backwards
function linkSolution(sol::Node)
	current = sol
	while current.parent != nothing
		current.parent.child = current
		current = current.parent
	end
	return current
end

#Print the solution
function printSol(root::Node)
	current = root
	cost = 0
	while true
		if current.child == nothing
			println("$(current.node)")
			cost = current.cost
			break
		else print("$(current.node) -> " ) end
		current = current.child
	end
	println("Path cost: $cost")
end

#Init, ask for start and destination and solve problem
graph = createGraph()
#print("Enter starting node: ")
start = readline()
#print("Enter destination node: ")
dest = readline()

#Init updated solution node, and declare root node with 3 pointers to represent open and closed list
sol = nothing
root = Node(start,0,nothing,nothing)
current = root
builder = root

#While current does not equal nothing do the follow
#1) Create all the children
#2) If child exists on closed list (represented by root -> current), dont add
#3) If child exists of open list (represented by current -> builder):
#   - Replace distance and parent if new distance to this node is shorter
#   - Otherwise, dont add
#4) If destination node is reached: update sol
#5) Current = nothing, were done
while current != nothing
	global root,current,builder,sol
	if current.node == dest 
		current.child = nothing #Kill potential children
		sol = current #Update with solution and break
		break
	end
	children = graph[current.node]
	for cdl in children
		if inClosed(root,current.child,cdl[1]) continue end #If we visited here, continue
		iter = current.child
		existed = false
		while iter != builder.child #Check open list, update nodes if we have better
			if iter.node == cdl[1]
				existed = true
				if current.cost + cdl[2] < iter.cost
					iter.cost = current.cost + cdl[2]
					iter.parent = current
				end
				break
			end
			iter = iter.child
		end
		if !existed #if it wasn't on open list, then add it
			builder.child = Node(cdl[1],current.cost + cdl[2], current,nothing)
			builder = builder.child
		end
	end
	current = current.child #Visit next node
end

#Print results
#println("\n\n\n\n\n\n")
printSol(linkSolution(sol))
