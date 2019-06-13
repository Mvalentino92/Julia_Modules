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
	print("How many nodes will be on the graph?: ")
	size = parse(Int64,readline())
	UnVisited = Array{Node,1}(undef,size)
	for i in 1:size
		print("Enter new node: ")
		k = readline()
		UnVisited[i] = Node(k,Inf,nothing,nothing)
		v = Array{Tuple{String,Float64},1}()
		println("Please enter adjacent nodes and their distance in the format \"node distance\".")
		println("Input \"stop\" when you are done.")
		print("node distance: ")
		next = split(readline())
		while next[1] != "stop"
			push!(v,(next[1],parse(Float64,next[2])))
			print("node distance: ")
			next = split(readline())
		end
		retval[k] = v
	end
	return (retval,UnVisited)
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

#Skip if here already
function inVisited(list::Array{Node,1},target::String)
	for i in list
		if i.node == target return true end
	end
	return false
end

#Get min of current stuff
function upDateCost(num,v,list::Array{Node,1},current)
	for i in 1:length(list)
		if list[i].node == v
			if num < list[i].cost
				list[i].cost = num
				list[i].parent = current
				break
			end
		end
	end
end

#Init, ask for start and destination and solve problem
(graph,UnVisited) = createGraph()
print("Enter starting node: ")
start = readline()
print("Enter destination node: ")
dest = readline()
sol = nothing

#Init updated solution node, and declare root node with 3 pointers to represent open and closed list
Visited = Array{Node,1}(undef,0)
for i in 1:length(UnVisited)
	if UnVisited[i].node == start
		UnVisited[i].cost = 0
		break
	end
end

#Solves
while length(UnVisited) > 0
	global UnVisited,Visited,graph,sol
	sort!(UnVisited, by = val -> val.cost)
	currentNode = UnVisited[1]
	if currentNode.node == dest
		sol = currentNode
		break
	end
	for i in graph[currentNode.node]
		println(i)
		if inVisited(Visited,i[1]) continue end
		costToNeighbor = i[2]
		costToCurrent = currentNode.cost
		upDateCost(costToCurrent + costToNeighbor,i[1],UnVisited,currentNode)
	end
	UnVisited = UnVisited[2:end]
	push!(Visited,currentNode)
end

#Print results
println("\n\n\n\n\n\n")
printSol(linkSolution(sol))
