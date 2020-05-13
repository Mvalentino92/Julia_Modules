# Has an operator (identity function for leaves with actual values)
# A value, (to be computed or default because it's a leaf
# Left and right children
mutable struct Node
	op::Function
	val::Union{Real,Nothing}
	left::Union{Node,Nothing}
	right::Union{Node,Nothing}
end

# Set operator for a Node
function setop(node::Node,op::Function)
	node.op = op
end

# Set the value for a Node
function setval(node::Node,val)
	node.val = val
end

# Set left child for Node
function setleft(node::Node,child::Union{Node,Nothing})
	node.left = child
end

# Set right child for Node
function setright(node::Node,child::Union{Node,Nothing})
	node.right = child
end

# Split correctly on parenthesis
function mysplit(expr::AbstractString,delim::String)
	retval = Vector{String}()
        l = 0
        r = 0
        s = ""
        for c in expr
        	if string(c) == delim && l == r
                push!(retval,s)
                s = ""
                else s = string(s,c)
                end
                if c == ')' l += 1 end
                if c == '(' r += 1 end
        end
        return push!(retval,s)
end

# Build a computatation graph from an expression
operators = Dict("+" => + ,"-" => - ,"*" => *,"/" => /,"^" => ^)
opkeys = ["+","-","*","/","^"]
functions = Dict("sin" => sin ,"cos" => cos ,"tan" => tan ,"exp" => exp ,"log" => log)
function compgraph(expr::AbstractString)
	# Root node is the identity (this is fine, will add a lot of unnecessary nodes but whatever for POC)
	root = Node(identity,nothing,nothing,nothing)

	# Set current node
	current = root

	# Check if we've already split across something, only want to split once
	hassplit = false

	# Begin to iterate precedences
	for op in opkeys

		# If we have split already, just return root
		if hassplit return root end

		# Seek to split at this operator
		funcs = map(x -> strip(x),mysplit(expr,op))

		# If there was no split, just continue
		if length(funcs) == 1 continue end

		# Otherwise....say we have split then do stuff
		hassplit = true
		
		# Create next node
		next = Node(get(operators,op,0), nothing, nothing,nothing)

		# Set next node as the child node of current node
		setleft(current,next)

		# Set next node as current
		current = next

		# Recur left with subexpression
		setleft(current,compgraph(funcs[1]))

		# Recur right with subexpression
		setright(current,compgraph(join(funcs[2:end],op)))
	end

	# Double check the return for splitting
	if hassplit return root end

	# If there were never any splits, we must be at our functions/constants
	
	# Check if parenthesis are in the expr, if they are we have a function
	if occursin("(",expr) && occursin(")",expr)

		# Figure out which function
		for func in keys(functions)
			if occursin(func,expr[1:3])
				
				# Create new node
				next = Node(get(functions,func,0),nothing,nothing,nothing)

				# Set next node as the child node of current node
				setleft(current,next)

				# Grab stuff inside the parenthesis as new expr
				l = length(func)
				expr = expr[l+2:end-1]

				# next is the new current
				current = next

				# Add child to current
				setleft(current,compgraph(expr))

				# Return the root
				return root
			end
		end

		# Otherwise, it's just parenthesis, do the above but use identity
		next = Node(identity,nothing,nothing,nothing)

		# Set next node as the child node of current node
		setleft(current,next)

		# Grab stuff inside the parenthesis as new expr
		expr = expr[2:end-1]

		# next is the new current
		current = next

		# Add child to current
		setleft(current,compgraph(expr))

		# Return the root
		return root

	end

	# If no parenthesis, it's a just a number, return it
	return Node(identity,parse(Float64,expr),nothing,nothing)
end

# Function to evaluate a computation graph
function geval(g::Node)
	# If there's just nothing

	# If its a value, return value (use identity why not)
	if !isnothing(g.val) return g.op(g.val) end

	# If it has one child (the left) return function applied to it
	if !isnothing(g.left) && isnothing(g.right) return g.op(geval(g.left)) end

	# Otherwise, it has both children
	return g.op(geval(g.left),geval(g.right))
end
