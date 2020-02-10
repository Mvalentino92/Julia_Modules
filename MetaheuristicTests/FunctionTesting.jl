# Functions to test algorithms on. Supplied by Computational Swarm Intelligence, Chapter 3

# Any dimension
function Spherical(x::Vector,p::Vector)
	retval = 0
	for j = 1:length(x)
		retval += x[j]*x[j]
	end
	return retval
end
bounds_sperical = (-100,100)
min_sperical = 0.0

# Any dimension
function Quadratic(x::Vector,p::Vector)
	retval = 0
	for j = 1:length(x)
		inner = 0
		for k = 1:j
			inner += x[j]
		end
		retval += inner*inner
	end
	return retval
end
bounds_quadratic = (-100,100)
min_quadratic = 0.0

# Any dimension
function Ackley(x::Vector,p::Vector)
	dim = length(x)
	c1 = 0
	c2 = 0
	for j = 1:dim
		c1 += x[j]*x[j]
		c2 += cos(2*pi*x[j])
	end
	return -20*exp(-0.2*sqrt(c1/dim)) - exp(1/dim*c2) + 20 + exp(1)
end
bounds_ackley = (-30,30)
min_ackley = 0.0

# 2 dimensional
function Bohachevsky1(x::Vector,p::Vector)
	return x[1]*x[1] + 2*x[2]*x[2] - 0.3*cos(3*pi*x[1]) - 0.4*cos(4*pi*x[2]) + 0.7
end
bounds_bohachevsky1 = (-50,50)
min_bohachevsky1 = 0.0

# 4 dimensional
function Colville(x::Vector,p::Vector)
	return 100*(x[2] - x[1]*x[1])^2 + (1-x[1])*(1-x[1]) + 90*(x[4] - x[3]*x[3])^2 + 
	(1-x[3])*(1-x[3]) + 10.1*((x[2]-1)*(x[2]-1) + (x[4]-1)*(x[4]-1)) + 19.8*(x[2]-1)*(x[4]-1)
end
bounds_colville = (-10,10)
min_colville = 0.0

# 2 dimensional
function Easom(x::Vector,p::Vector)
	return -cos(x[1])*cos(x[2])*exp(-(x[1] - pi)*(x[1]-pi) - (x[2]-pi)*(x[2]-pi))
end
bounds_easom = (-100,100)
min_easom = -1.0

# Any dimension
function Griewank(x::Vector,p::Vector)
	c1 = 0
	c2 = 1
	for j = 1:length(x)
		c1 += x[j]*x[j]
		c2 *= cos(x[j]/sqrt(j))
	end
	return 1 + (1/4000)*c1 - c2
end
bounds_griewank = (-600,600)
min_griewank = 0.0

# Any dimension
function Hyperellipsoid(x::Vector,p::Vector)
	retval = 0
	for j = 1:lenth(x)
		retval += j*j*x[j]*x[j]
	end
	return retval
end
bounds_hyperellipsoid = (-1,1)
min_hyperellipsoid = 0.0

# Any dimension
function Rastrigin(x::Vector,p::Vector)
	retval = 0
	for j = 1:length(x)
		retval += (x[j]*x[j] - 10*cos(2*pi*x[j]) + 10)
	end
	return retval
end
bounds_rastrigin = (-5.12,5.12)
min_rastrigin = 0.0

# Even dimension
function Rosenbrock(x::Vector,p::Vector)
	retval = 0
	for j = 1:div(length(x),2)
		retval += 100*(x[2*j] - x[2*j-1]*x[2*j-1])^2 + (1-x[2*j-1])*(1-x[2*j-1])
	end
	return retval
end
bounds_rosenbrock = (-2.048,2.048)
min_rosenbrock = 0.0

# Any dimension
function Schwefel(x::Vector,p::Vector)
	retval = 0
	for j = 1:length(x)
		retval += x[j]*sin(sqrt(abs(x[j]))) + 418.9829
	end
	return retval
end
bounds_schwefel = (-500,500)
min_schwefel = 0.0

# A utility function to create bounds vectors
function createbounds(bounds::Tuple,dim::Int)
	return repeat([bounds],dim)
end
