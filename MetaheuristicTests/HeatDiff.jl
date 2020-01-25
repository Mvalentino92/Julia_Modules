# Standard Solution Struct
struct Point
	vec::Vector
	val::Real
end

# Struct that represents a Rod during heat diffusion
# Solution Vector
# ω is the influence coefficent
# k is the bias constant, it will be ∈ (0,n) where n is the numerator of whichever ration belongs to the lower fitness
mutable struct Rod
	points::Vector{Point}
	params::Vector
	bounds::Vector
	size::Int
	dim::Int
	ω::Real
end

# Random bounds function
function randb(a::Real,b::Real)
	return a + rand()*(b - a)
end

# Checking for convergence
function stabilized(f::Function,rod::Rod,tol::Real,iter::Int)
	diff = 0
	flankpoint = rod.points[1]
	for i = 2:rod.size+1
		for j = 1:rod.dim
			diff += abs(flankpoint.vec[j] - rod.points[i].vec[j])
		end
	end
	diff /= length(rod.points)

	# Add 10 percent random solutions into rod
	if diff < tol
		println("HAPPENED")
		replace = sample(2:rod.size+1,trunc(Int64,rod.size*0.1),replace=false)
		for i in replace
			rvec = similar(flankpoint.vec)
			for j = 1:rod.dim
				rvec[j]= randb(bounds[j][1],bounds[j][2])
			end
			rval = f(rvec,rod.params)
			rod.points[i] = Point(rvec,rval)

			if rval < flankpoint.val
				flankpoint = rod.points[i]
			end
		end
		rod.points[1] = flankpoint
		rod.points[rod.size+2] = flankpoint
	end
end

# Update rod function
function updaterod(f::Function,rod::Rod)

	#Grab current global point
	bestpoint = rod.points[1]

	# New Point vector
	nextpoints = similar(rod.points)

	# Begin to calculate new value for each point
	leftpoint = rod.points[1]
	currentpoint = rod.points[2]
	rightpoint = []
	for i = 2:rod.size+1
		# Grab rightpoint
		rightpoint = rod.points[i+1]

		# Begin to update
		nextvec = zeros(rod.dim)
		for j = 1:rod.dim
			# Calculate influence ratios
			l = abs(currentpoint.val - leftpoint.val)
			r = abs(currentpoint.val - rightpoint.val)

			# Calculate k
			k = leftpoint.val < rightpoint.val ? randb(0,r) : -randb(0,l)

			# Update vec
			if l + r != 0
				lflu = (l+k)/(l+r)
				rflu = (r-k)/(l+r)
				ldist = leftpoint.vec[j] - currentpoint.vec[j]
				rdist = rightpoint.vec[j] - currentpoint.vec[j]
				nextvec[j] = currentpoint.vec[j] + rod.ω*(lflu*ldist + rflu*rdist) 
			else
				nextvec[j] = currentpoint.vec[j]
			end
		end

		#Add next point
		nextval = f(nextvec,rod.params)
		nextpoints[i] = Point(nextvec,nextval)

		# Update global
		if nextval < bestpoint.val
			bestpoint = nextpoints[i]
		end

		# Shift the points
		leftpoint = currentpoint
		currentpoint = rightpoint
	end

	# Fix the flank points
	nextpoints[1] = bestpoint
	nextpoints[rod.size+2] = bestpoint

	# Update rod with new Point vector
	rod.points = nextpoints
end

# The main algorithm
function heatdiff(f::Function,bounds::Vector,params::Vector=[]
		  ; size::Int=100, influence::Real=1, maxiter::Int=10000
		  , stabilizetol::Real=1,decayinfluence::Bool=false,influencedecay::Real=1)

	dim = length(bounds)
	points = Vector{Point}(undef,size+2)

	# Populate initial points space
	mn = Inf
	mnvec = []
	for i = 2:size+1
		vec = zeros(dim)
		for j = 1:dim
			vec[j] = randb(bounds[j][1],bounds[j][2])
		end
		val = f(vec,params)
		points[i] = Point(vec,val)

		# Finding global best
		if val < mn
			mn = val
			mnvec = vec
		end
	end

	# Add global best on ends
	points[1] = Point(mnvec,mn)
	points[size+2] = Point(mnvec,mn)

	# Initialize rod
	rod = Rod(points,params,bounds,size,dim,influence)

	# Begin main algorithm
	iter = 0	
	while iter < maxiter
		updaterod(f,rod)
		rod.ω = decayinfluence ? influence*(1 - (iter/maxiter)^influencedecay) : rod.ω
		stabilized(f,rod,stabilizetol,iter)
		iter += 1
	end
	return rod.points
	#return sort(rod.points,by=(x -> x.val))[1]
end
