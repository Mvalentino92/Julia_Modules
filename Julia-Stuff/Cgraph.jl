# Node for Computation Graphs
# operator and value will both be Strings.
# operator, so the expression can be printed out easily.
# value simply because they're will be variables. 
# Use dictionaries to grab actual function and plugged in value supplied by user.
mutable struct Node
	op::String
	val::Union{String,Nothing}
	left::Union{Node,Nothing}
	right::Union{Node,Nothing}
end

mutable struct CG
	root::Node
	rootprime::Union{Node,Nothing}
end

# Set operator for a Node
function setop!(node::Node,op::String)
	node.op = op
end

# Set the value for a Node
function setval!(node::Node,val::String)
	node.val = val
end

# Set left child for Node
function setleft!(node::Node,child::Node)
	node.left = child
end

# Set right child for Node
function setright!(node::Node,child::Node)
	node.right = child
end

# The Dictionary of operators
OPS = Dict("+" => +, "-" => -, "*" => *, "/" => /, "^" => ^,
	   "sin" => sin, "cos" => cos, "tan" => tan, "sinh" => sinh, "cosh" => cosh, "tanh" => tanh,
	   "exp" => exp, "log" => log, "abs" => abs, "_" => -,"" => identity)

# The list of binary ops to be split on in order of precedence.
BINOPS = ["+","-","*","/","^"]

# Function to replace 6*-2 with 6*(0-2)
function fixneg(expr::AbstractString)

	# Replace all -- with +
	expr = replace(expr,"--" => "+")

	# Add a "*" to beginning and end, (so the function wont go out of bounds)
	expr = string("*",expr)
	expr = string(expr,"*")

	# Call wrapper, but the * from beginning
	return fixnegwrapper(expr)[2:end-1]
end

startops = ['+','*','/','^','(']
endops = ['+','-','*','/','^',')']
# Utility function for fixnegs
function addp(expr::AbstractString)
	
	# Find index that an operator first occurs in while l and r are equal
	i = 1; l = 0; r = 0;
	while !any(map(x -> x == expr[i],endops)) || l != r
		l += expr[i] == '(' ? 1 : 0
		r += expr[i] == ')' ? 1 : 0
		i += 1
	end

	# Return new expr
	front = string(expr[1:i-1],")")
	whole = string(front,expr[i:end])

	return whole
end

# Wrapper for fixing negatives in string
function fixnegwrapper(expr::AbstractString)

	# Base case, if there's no splits return
	exprs = split(expr,"-",limit=2)
        if length(exprs) == 1 return exprs[1] end
           
	# Otherwise build return value based on split
        retval = ""
        if exprs[1][end] in startops
		retval = string(exprs[1],"(0-")
		exprs[2] = addp(exprs[2])
           	retval = string(retval,fixnegwrapper(exprs[2]))
        else
		retval = string(exprs[1],"-")
		retval = string(retval,fixnegwrapper(exprs[2]))
        end
	return string(retval)
end

forwarsdops = ["+","*","^"]
backwardops = ["-","/"]
# Function needed to split the expression up to a max of 2 subexpressions around given operator.
# Doesn't split around parenthesis
function opsplit(expr::AbstractString,op::String,rev::Bool)
	
	# Reverse if needed
	expr = rev ? reverse(expr) : expr

	l = 0; r = 0; s = "";
	for i = 1:length(expr)
		char = expr[i]
		if string(char) == op && l == r
			retval = [string(expr[1:i-1]),string(expr[i+1:end])] 
			return rev ? reverse(map(x -> reverse(x),retval)) : retval
		end
		if char == '(' l += 1 end
		if char == ')' r += 1 end
	end
	return rev ? [reverse(string(expr))] : [string(expr)]
end

# Returns the function for this subexpression that contains parenthesis
function funcarg(expr::AbstractString)
	i = 1;
	while expr[i] != '('
		i += 1
	end
	return string(expr[1:i-1]),string(expr[i+1:end-1])
end

# Main function for Computation Graph construction
function cgraph(expr::AbstractString)

	# Eliminate whitespace
	expr = filter(x -> !isspace(x),expr)

	# Fix negatives
	expr = fixneg(expr)

	# Create root to return
	root = Node("",nothing,nothing,nothing)

	# Call wrapper and return root
	cgraphwrapper(expr,root)

	return CG(root,nothing)
end

# Wrapper function that does all work
function cgraphwrapper(expr::AbstractString,root::Node)

	# Begin to find if there is a split.
	for op in BINOPS

		# See if forward or backward
		rev = op in backwardops
		
		# Seek to split at this operator
		subexprs = opsplit(expr,op,rev)

		# If there was no split, continue
		if length(subexprs) == 1 continue end

		# Otherwise, set operator for root
		# If the operator is ^, check for if there's a _ in front and work accordingly
		if op == "^"
			if subexprs[1][1] == '_'
				setop!(root,"_")
				next = Node("",nothing,nothing,nothing)
				setleft!(root,next)
				root = next
			end
		end
				
		setop!(root,op)

		# Create left and right nodes
		left = Node("",nothing,nothing,nothing)
		right = Node("",nothing,nothing,nothing)

		# Set them as left and right children for root
		setleft!(root,left)
		setright!(root,right)

		# Call recursively with both these as root with subexprs to mutate roots children

		# If subtraction or division, swap order
		cgraphwrapper(subexprs[1],left)
		cgraphwrapper(subexprs[2],right)


		# Return to stop
		return
	end

	# ***If you made it here, no splits were found. Time to have a single child for a unary function***
	
	# Check first if the initial char is _, since it may not have brackets
	if expr[1] == '_'
		op = "_"
		subexpr = expr[2:end]

		# Repeat similar process as above
		setop!(root,op)
		left = Node("",nothing,nothing,nothing)
		setleft!(root,left)
		cgraphwrapper(subexpr,left)
		return
	end

	
	# Check if there's parenthesis in general, if so (and wasn't _), it's a function
	if occursin("(",expr)
		# Find the function and arguments for what must be here
		op,subexpr = funcarg(expr)

		# Repeat similar process for binary split, but only one child
		setop!(root,op)
		left = Node("",nothing,nothing,nothing)
		setleft!(root,left)
		cgraphwrapper(subexpr,left)
		return
	end

	# Otherwise it's just a value, so simply set it! (if empty string, set as 0!)
	setval!(root,expr)
	return
end

# The evaluation function, passed an optional dictionary that defaults to being empty
function cgeval(cg::CG;vars::Dict=Dict())

	# Make a deepcopy of Node
	root = deepcopy(cg.root)
	
	# Call the wrapper with the copied root node
	val = parse(Float64,cgevalwrapper(root,vars))

	# Return val and new compuation graph filled out
	return val,CG(root,nothing)
end

# Wrapper function to do all work for evaluation
function cgevalwrapper(root::Node,vars::Dict)

	# Base case, if there's a value simply return value as a string!
	if !isnothing(root.val) return string(get(vars,root.val,root.val)) end

	# If there's just a left child and right child, must be binary operator
	if !isnothing(root.left) && !isnothing(root.right)

		# Get left and right values (parsed as numbers)
		left = parse(Float64,cgevalwrapper(root.left,vars))
		right = parse(Float64,cgevalwrapper(root.right,vars))

		# Get op and set the value for this node
		op = get(OPS,root.op,identity)
		setval!(root,string(op(left,right)))

		# Return the val
		return root.val
	end

	# Otherwise, it must be a single left child, same as above
	left = parse(Float64,cgevalwrapper(root.left,vars))
	op = get(OPS,root.op,identity)
	setval!(root,string(op(left)))
	return root.val
end
