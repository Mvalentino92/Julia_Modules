#Node class
mutable struct Node{T}
	value::T
	parent
	child
end

#Print value of single Node
function printNode(node::Node)
	println(node.value)
end

#------------------------------------------------------------

#LinkedList class (Double Linked)
mutable struct LinkedList
	head
	tail
	size::Int64
end

#Create empty LinkedList
function emptyLL() return LinkedList(Nothing,Nothing,0) end

#Create new LinkedList with Initial value 
function singletonLL(val)
	retval = emptyLL()
	addInit(retval,val)
	return retval
end

#Create a LinkedList from the supplied values
function toLL(arr) 
	retval = emptyLL()
	for i in arr
		addLast(retval,i)
	end
	return retval
end

#Add the initial Node of the LinkedList
function addInit(list::LinkedList,val)
	newNode = Node(val,Nothing,Nothing)
	list.head = newNode
	list.tail = list.head
	list.size += 1
end

#Add to beginning of the list
function addFirst(list::LinkedList,val)
	newNode = Node(val,Nothing,Nothing)
	list.head.parent = newNode
	newNode.child = list.head
	list.head = newNode
	list.size += 1
end

#Add to the end of the list
function addLast(list::LinkedList,val)
	newNode = Node(val,Nothing,Nothing)
	if list.size == 0 addInit(list,val)
	else
		list.tail.child = newNode
		newNode.parent = list.tail
		list.tail = newNode
		list.size += 1
	end
end

#Add at the specified index (assumes tail if index >= size)
function addAt(list::LinkedList,val,index::Int64)
	newNode = Node(val,Nothing,Nothing)
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
function getFirst(list::LinkedList) return list.head.value end
function getLast(list::LinkedList) return list.tail.value end

#Return the node at the specified index (assumes tail if index >= size)
function getValue(list::LinkedList,index::Int64)
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

#Prints the LinkedList
function printLL(list::LinkedList)
	current = list.head
	for i in 1:list.size
		println(current.value)
		current = current.child
	end
end
