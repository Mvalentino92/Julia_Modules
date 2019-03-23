module NodeStuff

#Node class
mutable struct Node{T}
	value::T
	parent::(Union{Node,Nothing})
	child::(Union{Node,Nothing})
end

#Print value of single Node
function printNode(node::Node)
	println(node.value)
end

#------------------------------------------------------------

#LL class (Double Linked)
mutable struct LL
	head::(Union{Node,Nothing})
	tail::(Union{Node,Nothing})
	size::Int64
end

#Create empty LL
function emptyLL() return LL(nothing,nothing,0) end

#Create new LL with Initial value 
function singletonLL(val)
	retval = emptyLL()
	addInit(retval,val)
	return retval
end

#Create a LL from the supplied values
function toLL(arr) 
	retval = emptyLL()
	for i in arr
		addLast(retval,i)
	end
	return retval
end

#Add the initial Node of the LL
function addInit(list::LL,val)
	newNode = Node(val,nothing,nothing)
	list.head = newNode
	list.tail = list.head
	list.size += 1
end

#Add to beginning of the list
function addFirst(list::LL,val)
	newNode = Node(val,nothing,nothing)
	list.head.parent = newNode
	newNode.child = list.head
	list.head = newNode
	list.size += 1
end

#Add to the end of the list
function addLast(list::LL,val)
	newNode = Node(val,nothing,nothing)
	if list.size == 0 addInit(list,val)
	else
		list.tail.child = newNode
		newNode.parent = list.tail
		list.tail = newNode
		list.size += 1
	end
end

#Add at the specified index (assumes tail if index >= size)
function addAt(list::LL,val,index::Int64)
	newNode = Node(val,nothing,nothing)
	if index == 0 addFirst(list,val)
	elseif index >= list.size addLast(list,val)
	else
		current = list.head
		for i in 1:index
			current = current.child
		end
		newNode.parent = current.parent
		newNode.child = current
		current.parent.child = newNode
		current.parent = newNode
		list.size += 1
	end
end

#Return the head of the List, and tail of the List respectively
function getFirst(list::LL) return list.head.value end
function getLast(list::LL) return list.tail.value end

#Return the node at the specified index (assumes tail if index >= size)
function getValue(list::LL,index::Int64)
	if index == 0 return getFirst(list)
	elseif index >= list.size return getLast(list)
	else
		current = list.head
		for i in 1:index
			current = current.child
		end
		return current.value
	end
end

#Prints the LL
function printLL(list::LL)
	current = list.head
	for i in 1:list.size
		println(current.value)
		current = current.child
	end
end

end
