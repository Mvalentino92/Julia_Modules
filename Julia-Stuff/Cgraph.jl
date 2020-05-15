# Node for Computation Graphs
# operator and value will both be Strings.
# operator, so the expression can be printed out easily.
# value simply because they're will be variables. 
# Use dictionaries to grab actual function and plugged in value supplied by user.
#=mutable struct Node
	op::String
	val::Union{String,Nothing}
	left::Union{Node,Nothing}
	right::Union{Node,Nothing}
end

mutable struct CG
	root::Node
	rootprime::Union{Node,Nothing}
end=#

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
	   "exp" => exp, "log" => log, "abs" => abs, "_" => -,"sqrt" => sqrt, "" => identity)

# The list of binary ops to be split on in order of precedence.
BINOPS = ["+","-","*","/","^"]

# Function to replace 6*-2 with 6*(0-2)
function fixneg(expr::AbstractString)

	# Replace unecessary things with plus and minus
	expr = replace(expr,"--" => "+")
	expr = replace(expr,"+-" => "-")
	expr = replace(expr,"-+" => "-")

	# Add a "*" to beginning and end, (so the function wont go out of bounds)
	expr = string("*",expr)
	expr = string(expr,"*")

	# Call wrapper, but the * from beginning
	return fixnegwrapper(expr)
end

# Wrapper for fixing negatives in string
startops = ['*','/','^','(']
function fixnegwrapper(expr::AbstractString)
	retval = ""
	for i = 2:length(expr)-1
		retval = string(retval,expr[i] == '-' && expr[i-1] in startops ? "_" : expr[i])
	end

	return retval
end

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
				subexprs[1] = subexprs[1][2:end]
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
function cgeval(node::Node;vars::Dict=Dict())

	# Make a deepcopy of Node
	root = deepcopy(node)
	
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

# Reach node with actual value
function dval(root::Node,vars::String)
	# Set as 1 if matches vars or 0 otherwise
	setval!(root,root.val == vars ? "1" : "0")
	return root
end

# Addition for derivative
function dadd(root::Node,vars::String)
	# Simply add derivs
	newleft = derivewrapper(root.left,vars)
	setleft!(root,newleft)

	newright = derivewrapper(root.right,vars)
	setright!(root,newright)
	return root
end

# Subtraction for derivative
function dminus(root::Node,vars::String)
	# Simply subtract the deriv of each side
	newleft = derivewrapper(root.left,vars)
	setleft!(root,newleft)

	newright = derivewrapper(root.right,vars)
	setright!(root,newright)
	return root
end

# Multiplication, using product rule
function dmult(root::Node,vars::String,addi::Bool)

	# Create left and right nodes that are multiplication
	mleft = Node("*",nothing,nothing,nothing)
	mright = Node("*",nothing,nothing,nothing)
	
	# Set children of left f'*g
	setleft!(mleft,derivewrapper(root.left,vars))
	setright!(mleft,root.right)

	# Set children of right f*g'
	setleft!(mright,root.left)
	setright!(mright,derivewrapper(root.right,vars))

	# Set these as children of root, after changing op to +
	setop!(root,addi ? "+" : "-")
	setleft!(root,mleft)
	setright!(root,mright)

	return root
end

# Division, using quotient rule
function ddiv(root::Node,vars::String)

	# Create left node from product rule
	subleft = dmult(deepcopy(root),vars,false)

	# Create right node, g*g
	mright = Node("*",nothing,nothing,nothing)
	setleft!(mright,deepcopy(root.right))
	setright!(mright,deepcopy(root.right))

	# Keep op of root, it's already division, just change children
	setleft!(root,subleft)
	setright!(root,mright)

	return root
end

function dpow(root::Node,vars::String)

	#Create left that is n*d/dx(x) (chain rule)
	mleft = Node("*",nothing,nothing,nothing)

	#Set it's left simply as root.right
	setleft!(mleft,deepcopy(root.right))

	# Set it's right as the deriv of root.left (chain rule)
	setright!(mleft,derivewrapper(root.left,vars))

	# Create right child with "^"
	pright = Node("^",nothing,nothing,nothing)

	# Set left child of pright by cloning root.left
	setleft!(pright,deepcopy(root.left))

	# Create it's right child, with "-"
	pright_right = Node("-",nothing,nothing,nothing)

	# Set the left child as a copy of root.right
	setleft!(pright_right,deepcopy(root.right))

	# Set right child as 1
	setright!(pright_right,Node("","1",nothing,nothing))

	# Set right child of pright
	setright!(pright,pright_right)

	# Finally change op of root, and set children
	setop!(root,"*")
	setleft!(root,mleft)
	setright!(root,pright)

	return root
end

# Function for negatives, simply return 0 - deriv
function dneg(root::Node,vars::String)

	# Set op to -
	setop!(root,"-")

	# Set right to left
	setright!(root,deepcopy(root.left))

	# Set left to new node of zeros
	setleft!(root,Node("","0",nothing,nothing))

	return root
end

# Function for sin, chain rule
function dsin(root::Node,vars::String)

	# Create left child which is cosine of root.left
	l = Node("cos",nothing,nothing,nothing)
	setleft!(l,root.left)

	# Set left and right of root
	setright!(root,derivewrapper(root.left,vars))
	setleft!(root,l)

	# Change operator of of root
	setop!(root,"*")

	return root
end

# Function for cos, very similar to dsin but need a negative
function dcos(root::Node,vars::String)
	# Create left child which is cosine of root.left
	l = Node("sin",nothing,nothing,nothing)
	setleft!(l,root.left)

	# Set left and right of root
	setright!(root,derivewrapper(root.left,vars))
	setleft!(root,l)

	# Change operator of of root
	setop!(root,"*")

	addneg = Node("_",nothing,nothing,nothing)
	setleft!(addneg,root)

	return addneg
end

# Function for exp, similar to dsin, but just use exp
function dexp(root::Node,vars::String)
	# Create left child which is cosine of root.left
	l = Node("exp",nothing,nothing,nothing)
	setleft!(l,root.left)

	# Set left and right of root
	setright!(root,derivewrapper(root.left,vars))
	setleft!(root,l)

	# Change operator of of root
	setop!(root,"*")

	return root
end

# Function for log, just original divided by deriv
function dlog(root::Node,vars::String)

	# Create right child for 1/x
	dright = Node("/",nothing,nothing,nothing)

	# Set it's children
	setleft!(dright,Node("","1",nothing,nothing))
	setright!(dright,root.left)

	# Set children for root and change sign
	setleft!(root,derivewrapper(root.left,vars))
	setright!(root,dright)
	setop!(root,"*")

	return root
end

# Function for sqrt, convert to ^ first
function dsqrt(root::Node,vars::String)

	# Change op
	setop!(root,"^")

	# Add right child
	setright!(root,Node("","0.5",nothing,nothing))

	# now call the deriv function for ^
	return dpow(root,vars)
end


# Derivative of function
function deriv(cg::CG,vars::String)

	# Clone the cg for deriv
	cg.rootprime = deepcopy(cg.root)

	# Pass the rootnode to wrapper
	cg.rootprime = derivewrapper(cg.rootprime,vars)
end

# Wrapper function for derivative
function derivewrapper(mainroot::Node,vars::String)
	
	# Pass a copy
	root = deepcopy(mainroot)

	# Base case if actual value
	if !isnothing(root.val) return dval(root,vars) end

	# Other base case for identity
	if root.op == "" return derivewrapper(root.left,vars) end

	# Other base case for neg!
	if root.op == "_" return derivewrapper(dneg(root,vars),vars) end

	# Check what operation to use
	if root.op == "+" return dadd(root,vars) end
	if root.op == "-" return dminus(root,vars) end
	if root.op == "*" return dmult(root,vars,true) end
	if root.op == "/" return ddiv(root,vars) end
	if root.op == "^" return dpow(root,vars) end
	if root.op == "sin" return dsin(root,vars) end
	if root.op == "cos" return dcos(root,vars) end
	if root.op == "exp" return dexp(root,vars) end
	if root.op == "log" return dlog(root,vars) end
	if root.op == "sqrt" return dsqrt(root,vars) end
end
