module jlnum
	#***Function to Compute the Arc Lenght, Decent Precision.***

	import SymPy.diff
	"""
	```jldoctest
	ArcLen(Function,x0,xend)
	```
	Computes the distance between two points of a function

	# Examples

	```jldoctest
	julia> f(x) = sin(x)
	       Length = ArcLen(f,0,5)
	       print(Length)
	       6.02
	```
	"""
	function ArcLen(f,x0,xend)	#Finds the arc length of funtion between two points.	
		total = 0
		iter = 1e-4		#Spacing Steps
		x1 = x0
		x2 = x0 + iter		#Setting x1,x2,y1,y2 for equation 
		y1 = f(x1)		
		y2 = f(x2)
		while x2 <= xend
			total += sqrt((x2-x1)^2 + (y2-y1)^2)	#Performing the operation in a loop
			x1 = x2
			x2 = x1 + iter		#Adjusting/iterating the values of x's and y's
			y1 = f(x1)
			y2 = f(x2)
		end
		return total		#Return the value
	end

	#***End of ArcLength Function***


	#***Romberg integration***
	"""
	```jldoctest
	RomInt(Function,x0,xend)
	```
	Uses Romberg Integration to compute the area under a curve. Very efficient speed wise, and decently accurate.\n
	f(x) = x^2 between 0 and 1 yields an accuracy of e-15 from the true value.\n
	Must be supplied a FUNCTION (See `TrapZ` or `UnevenTrapZ` for data points)

	# Example
	```jldoctest
	julia> f(x) = sin(x)*sin(x)
	       Area_Under_Curve = RomInt(f,0,2*pi) 
	       print(Area_Under_Curve)
	       3.141598776
	```
	"""
	function RomInt(f,x0,xend)			#Parameters are the function and two points (Uses a function, not data points!!)
		dt = 2e-4
		total = zeros(4)			#Setting an array of zeros to hold the four iterations of intergration
		for count = 1:4
			dt /= 2				#Cutting down my spacing by factors of two for each iteration
			yhold = collect(x0:dt:xend)
			y = map(f,yhold)		#Getting y values
			total[count] += (y[1]*dt/2 + y[end]*dt/2)	#Getting each newly improved appoximation of the integral
			for i in y[2:end-1]
				total[count] += i*dt 			#Getting the first and last values added to the approximations
			end
		end
		n = 4					#Setting n up to compute the weighted averages
		t1 = (n*total[2] - total[1])/(n-1)
		t2 = (n*total[3] - total[2])/(n-1)	#Computing the weighted averages to get a more precise approximation
		t3 = (n*total[4] - total[3])/(n-1)
		n *= 4					#Incrementing n by neccessary factors of 4
		t1 = (n*t2 - t1)/(n-1)
		t2 = (n*t3 - t2)/(n-1)
		n *= 4
		final = (n*t2 - t1)/(n-1)
		return final				#Returning the final improved integral
	end

	#***End of Romberg function***

	#***Start Trapz****
	"""
	```jldoctest
	TrapZ(x_data_points,y_data_points)
	```
	Computes the area under a curve using the Trapazoidal Method. Data points must have even spacing (See `UnevenTrapZ` if they dont)\n
	Greater accuracy is achieved by using smaller spacing.
	```jldoctest
	julia> x = 0:1e-6:1
	       y = x.^2
	       Area_Under_Curve = TrapZ(x,y)
	       print(Area_Under_Curve)
	       0.3333333333376
	```
	"""
	function TrapZ(x,y)				#Gives area under the curve (integral), using Data Points!!
		dt = diff(x[1:2])[1]			#Finding what the spacing is...This is for even spacing!!
		total = (y[1]*dt/2 + y[end]*dt/2)	
		for i in y[2:end-1]
			total += i*dt			#Iterating through the values and adding them
		end
		return total				#Returning the total
	end

	#***End TrapZ***

	#***Start UnevenTrapZ***			Gives the area under the curve using Data Points!! (For UNEQUAL SPACING)
	"""
	```jldoctest
	UnevenTrapZ(x_data_points,y_data_points)
	```
	Computes the area under the curve using the Trapazoidal method. Use when the spacing between your data points is NOT even.\n
	Will yield more accurate results if more data points are generated using the function `Lagrange` first\n
	```jldoctest
	julia> x = [0,0.1,0.25,0.33,0.5,0.8,0.97,1]
	       y = x.^2
	       Area_Under_Curve = UnevenTrapZ(x,y)
	       print(Area_Under_Curve)
	       0.33345657
	```
	"""
	function UnevenTrapZ(x,y)							#***Interpolating then using this function advised***
		total = (y[1]*diff(x[1:2])[1]/2 + y[end]*diff(x[end-1:end])[1]/2)	#Getting the end values using different spacing
		for i=2:length(y[1:end-1])						#Setting the other points to iterate through
			dt = (diff(x[i:i+1])[1] + diff(x[i-1:i])[1])/2		#Finding the mean of the spacing between the left...
			total += y[i]*dt					#...and the right sides for this interval
		end
		return total							#Returning the total

	end
			

	#***Start of CumTrapz Function	
	"""
	```jldoctest
	CumTrapz(x_data_points,y_data_points)
	```
	Returns data points representating the integral of the data points provided.\n
	This function will only provide the shape of the underlying function, as the constant term of the integral can never be accounted for.\n
	For use with polynomial and trigonomic functions.
	# Example
	```jldoctest
	julia> x = 0:0.1:5
	       y = 2x
	       Y = CumTrapz(x,y)
	       plot(x,Y)
	       (This will yield a graph clearly representating the integral of x^2)
	```
	"""
	function CumTrapZ(x,y)				#This a function to estimate the numerical integral of points from a Polynomial
		y_end = TrapZ(x,y)[1]			#First I'm finding the area under the curve of the data points
		dt = diff(x[1:2])[1]			#For Polynomials, this number will be the same as the integral evaluated at the...
		Integral = zeros(length(x))		#...last point
		Integral[1] = y_end			#Setting the first (Last) point in the Integral to this value
		y  = reverse(y)				#I'm reversing the order of y, so I can operate in order
		for i=1:length(x)-1
			Integral[i+1] = Integral[i] - (y[i]*dt + y[i+1]*dt)/2		#I'm calulating the integral of the next point
		end									#Working backwards, using the previous point 
		Integral = reverse(Integral)						#And knowledge of the spacing
		return Integral							#Reversing the vector, and returning the answer.
	end

	#***Start Lagrangian Interpolation***
	"""
	```jldoctest
	Lagrange(x_data_points,y_data_points,divide_spacing)
	```
	Interpolates points between the supplied data points. If N = length(x_data_points), this functin returns N*divide_spacing - (divide_spacing-1) data points.\n
	Recommended for use with non chaotic type functions. 
	# Example using data points from function x^2
	```jldoctest
	julia> x = [0,0.1,0.5,0.55,0.9,1.4,1.53,1.8,2]
	       y = x.^2
	       Interpolated_Points = Lagrange(x,y,10)
	       plot(x,Interpolated_Points) ---> Will produce a smoothed out plot of x^2
	```
	"""
	function Lagrange(x,y,divide_spacing)			#Function to interpolate more data points between existing data points
		Left = 1			#I'm using 3 points per iteration to get values between those three points
		Right = 3			#Setting variables for left and right indexing
		InterpolationTicks = []
		InterpolationValues = []
		while Right != (length(x) - 1)		#while loop to iterate through conditions to satisfy my desired interval spacing
			NEWX = x[Left:Right]		#Setting the boundaries for each interval for the x and y values
			NEWY = y[Left:Right]
			InitialSpacing = sum(diff(NEWX))/2	#Finding the mean of the spacing between the points of my interval
			NewSpacing = InitialSpacing/divide_spacing	        #Getting a new reduced spacing
			NEWX = convert(Array{Float64,1},NEWX)
			LagInterval = NEWX[1]:NewSpacing:NEWX[end]	#Settng up the new intervel with spacing
			HoldInterval = zeros(length(LagInterval))	#Array of zeros to hold the values
			for j=1:length(LagInterval)
				X = LagInterval[j]
				Lag_Sum = 0
				for i=1:length(NEWX)			#Iterating through the generate values corresponding to this interval
					Numerator = 1
					Denominator = 1
					for k=1:length(NEWX)
						if i != k
							Numerator *= (X-NEWX[k])
							Denominator *= (NEWX[i]-NEWX[k])
						end
					end
					Lag_Sum += (Numerator*NEWY[i])/Denominator	#Getting the new vales	
				end
				if (LagInterval[j] in InterpolationTicks) != true	#Preventing identical values from being appended
					push!(InterpolationTicks,LagInterval[j])
					push!(InterpolationValues,Lag_Sum)
				end
			end
			if Right == length(x)	#If your finished with the last interval, stop.
				break
			end
			Left = Right		#Updating our left and right index variables for the next interval
			Right += 2
			
		end
		if length(x) != Right		#If we have an even number of points, the last interval with have 4 points instead of 3
			Left = Left 
			Right += 1		#Just iterating through the equation again for this case
			NEWX = x[Left:Right]
			NEWY = y[Left:Right]
			InitialSpacing = sum(diff(NEWX))/3
			NewSpacing = InitialSpacing/divide_spacing
			NEWX = convert(Array{Float64,1},NEWX)
			LagInterval = NEWX[1]:NewSpacing:NEWX[end]
			HoldInterval = zeros(length(LagInterval))
			for j=1:length(LagInterval)
				X = LagInterval[j]
				Lag_Sum = 0
				for i=1:length(NEWX)
					Numerator = 1
					Denominator = 1
					for k=1:length(NEWX)
						if i != k
							Numerator *= (X-NEWX[k])
							Denominator *= (NEWX[i]-NEWX[k])
						end
					end
					Lag_Sum += (Numerator*NEWY[i])/Denominator
				end
				if (LagInterval[j] in InterpolationTicks) != true
					push!(InterpolationTicks,LagInterval[j])
					push!(InterpolationValues,Lag_Sum)
				end
			end
		end			
		return InterpolationTicks,InterpolationValues	#Returning the new vectors with N*10 - 9 points of original
	end
			
	#***End Lagrangian Interpolation***


	#***Start Taylor Series Polynomial Expansion***
	"""
	```jldoctest
	TaylorPoly(Function,point_of_expansion,order)
	```
	Returns a vector of coefficients representating the Taylor Series expansion of the supplied function\n
	Recommended to declare a variable for the point_of_expansion. Easier to follow-up with `TaylorEval`
	# Examples
	```jldoctest
	julia> f(x) = sin(x)
	       point_of_expansion = 0
	       Coeffs = TaylorPoly(f,point_of_expansion,5)
	       print(Coeffs)
	       [0.0,1,0.0,-0.166667,0.0,0.0083333]
	```
	"""
	function TaylorPoly(Func,point_of_expansion,order)	#Gives the taylor series appoximation in the form of a vector of coefficients
		Polynomial_Vector = [Func(point_of_expansion)]	#Getting first coefficient for zero factorial (Will be same value)
		for i = 1:order
			Func  = diff(Func) 			#Iterating through subsequent derivatives
			Func_Value = Func(point_of_expansion)	
			Coefficient = Func_Value/factorial(i)	#Getting the respective coefficients for each value/iteration
			push!(Polynomial_Vector,Coefficient)	#Appending it to the vector
		end
		#Polynomial = Poly(Polynomial_Vector)
		Polynomial = Polynomial_Vector			#Returning the coeffcient vector
		return Polynomial
	end

	#***End Taylor Series Polynomial Expansion***

	#***Start Taylor Series Evaluation***
	"""
	```jldoctest
	TaylorEval(Coeff_Vector,Value(s),point_of_expansion)
	```
	Evaluates a vector of Taylor Series Coefficients at the supplied value(s)\n
	Must also supply the point of expansion used to obtain the coefficients.
	# Example with Coeff = TaylorSeries expansion of sin(x) at 0
	```jldoctest
	julia> Values = 0:0.1:1 
	       Estimated_Values = TaylorEval(Coeff,Values,0)
	       print(Estimated_Values) ---> Will produce values near perfect to sin(Values)
	```
	"""
	function TaylorEval(Coeff_Vector,Value,point_of_expansion)	#Evaluating the Taylor series appoximation for point(s)
		Value = Value - point_of_expansion			#Subtracting the point of expansion from value(s) to get actual value.
		Answer = PolyVecEval(Coeff_Vector,Value)
		return Answer						#Calling POLYVECEVAL to generate the answers
	end

	#***Start PolyVecEval***
	"""
	```jldoctest
	PolyVecEval(Coefficients,Value(s))
	```
	Evaluates a vector as Polynomial at the supplied value(s)
	# Examples
	```jldoctest
	julia> Coefficients = [1 4 2]
	       Value = 3
	       Solution = PolyVecEval(Coefficients,Value)
	       print(Solution)
	       31 ----> 1 + 4*3 + 2*3^2
	```
	"""
	function PolyVecEval(Coeff_Vector,Value)			#Evaluates a vector as a polynomial
		Total = zeros(length(Value))				
		for j=1:length(Value)					#Iterating through how many values are to be evaluated
			Total[j] = Coeff_Vector[1]			#The first one is just equal to the coefficient (no x)
			for i=2:length(Coeff_Vector)				#Iterating through the ascending orders
				Total[j] += Coeff_Vector[i]*Value[j]^(i-1)	#Performing the calculations EXAMPLE: 1.2*(x)^3
			end
		end
		return Total			#Returning the vector of the evaluated polynomial vector
			
	end
		
	#***End PolyVecEval***

	#***Start PolyForm***
	"""
	```jldoctest
	PolyForm(Value,Order)
	```
	Returns a vector of the specified order, with the coefficients being subsequent powers of the supplied Value\n
	The constant term will always be returned as 1.
	# Examples
	```jldoctest
	julia> Polynomial_Vector = PolyForm(2,5)
	       print(Polynomial_Vector)
	       [1.0 2.0 4.0 8.0 16.0,32.0]
	```
	"""
	function PolyForm(Value,Order)		#For Splines. Getting a polynomial with unknown coefficients evaulated at x=Value
		Vector = zeros(Order+1)		#Setting a vector of zeros, and setting the first value to 1 (no x attached to it)
		Vector[1] = 1
		for i=2:length(Vector)
			Vector[i] = Value^(i-1)	#Raising each value to its power in the polynomial
		end
		Vector = Vector'	#Tranpose the array before returning
		return Vector
	end

	#***EndPolyForm***

	#***Start PolyDiff***		#Differentiates a polynomial vector
	"""
	```jldoctest
	PolyDiff(Polynomial_Vector)
	```
	Differentiates the coefficients of a vector representating a polynomial\n
	The result will always yield a vector with a length of 1 less than the original
	# Examples
	```jldoctest
	julia> Polynomial_Vector = [3 1 4] ---> 3 + x + 4x^2
	       Derivative = PolyDiff(Polynomial_Vector)
	       print(Derivative)
	       [1 8] ---> 1 + 8x
	```
	"""
	function PolyDiff(Polynomial_Vector)
		PolyDeriv = zeros(length(Polynomial_Vector)-1)	#Length of derivative vector will of course have one less slot
		for i=1:length(PolyDeriv)
			PolyDeriv[i] = i*Polynomial_Vector[i+1]	#Mutiplying the power by the coefficient of each value
		end
		PolyDeriv = PolyDeriv'	#Transposing befor returning
		return PolyDeriv
	end

	#***End PolyDiff****

	#***Start PolyInt***		#Integrating polynomials vectors
	"""
	```jldoctest
	PolyInt(Polynomial_Vector)
	```
	Integrates the coefficients of a vector representating a polynomials\n
	The result will always yield a vector with a length of 1 more than the original, in the form of a new leading constant term of zero
	# Examples
	```jldoctest
	julia> Polynomial_Vector = [3 1 4] ----> 3 + x + 4x^2
	       Integral = PolyInt(Polynomial_Vector)
	       print(Integral)
	       [0 3 0.5 1.333] ---> C + 3x + 0.5x^2 + 1.333x^3
	```
	"""
	function PolyInt(Polynomial_Vector)
		PolyIntegral = zeros(length(Polynomial_Vector)+1)	#It will have 1 more index (The constant term, set to zero)
		for i=2:length(PolyIntegral)				#Stting first value to zero
			PolyIntegral[i] = Polynomial_Vector[i-1]/(i-1)	#Dividing the coeffcients by the powers
		end
		PolyIntegral = PolyIntegral'	#Transposing before returning
		return PolyIntegral
	end


	#***Start Rootz***
	"""
	```jldoctest
	Rootz(Function,x0,xend,spacing)
	```
	Finds all available roots of the function on the supplied interval and returns them as an array.\n
	Smaller spacing will yield more accurate results.
	# Examples
	```jldoctest
	julia> f(x) = sin(4x)
	       Func_Zeros = Rootz(f,-2*pi,2*pi,pi/30)
	```
	"""
	function Rootz(Func,x0,xend,dt)		#Finds mutiple roots of a function within a specified domain, using specified spacing
		x = x0:dt:xend			#Spacing of 1 is reccomended unless you expect very condensed zeros
		y = Func(x)	
		Interval = []
		for i=1:length(y)-1
			if ((y[i] < 0) && (y[i+1] > 0) || (y[i] > 0) && (y[i+1] < 0)) #Adds the intervals where the signs switch
				Bound = [x[i],x[i+1]]								
				push!(Interval,Bound)									
			end						#Created an array of intervals of left and right bounds for root findin
		end
		roots = zeros(length(Interval))
		for i=1:length(roots)
			roots[i] = fzero(Func,Interval[i][1],Interval[i][2])	#Iterating through calling the fzero function to find the 
		end								#roots for each interval containing a root
		for i=1:length(y)
			if y[i] == 0						#If any of our originally generated y values actually 
				push!(roots,x[i])				#contained a 0 (root), I'm tagging it on now
			end
		end
		roots = sort(roots)
		return roots			#Returning an array of all the roots
	end
		

	#***End Rootz***

	#***Start fzero***			#Will find the root of a function. Needs initial guesses		
	"""
	```jldoctest
	fzero(Function,a,b)
	```
	Finds the root of the function closest to the two guesses (a and b) supplied.\n
	Uses the bisection method followed by the newton method to converge quickly with great accuracy\n
	If mutiple roots are assumed, see function `Rootz`
	# Examples
	```jldoctest
	julia> f(x) = 2x - x^2
	       Func_Zero = fzero(f,-4,4)
	       print(Func_Zero)
	       2
	```
	"""
	function fzero(Func,a,b)
		Tol = 0.1			#Tolerance for the bisection method
		Deriv = diff(Func)		#Getting the derivative for the newton method
		x1 = 0.5*(a+b)
		if Func(x1) == 0		#If the first guess is right, just stop.
			x2 = x1
		else				#Otherwise generate the second value for the while loop
			if Func(x1)*Func(a) < 0
				b = x1
			else
				a = x1
			end
			x2 = 0.5*(a+b)
			if Func(x2)*Func(a) < 0
				b = x2
			else
				a = x2
			end
			count = 0
			while abs(x1 - x2) > Tol	#If the difference between values of x1 and x2 gets smaller than the Tol, stop.
				x1 = x2
				x2 = 0.5*(a+b)
				if Func(x2)*Func(a) < 0
					b = x2
				else
					a = x2
				end
				count += 1
			end
			xguess = x2			#The final x2 value from Bisection Method is the initial guess for Newtons Method
			Tol2 = 1e-6			#The tolerance is significantly lower
			x1 = xguess - Func(xguess)/Deriv(xguess)
			x2 = x1 - Func(x1)/Deriv(x1)			#Getting the first two values for the while loop
			while abs(x1 - x2) > Tol2	
				x1 = x2					#Iterating through
				x2 = x1 - Func(x1)/Deriv(x1)
			end
		end
		return x2						#Returning the zero
	end

	#***End fzero***

	#***Start Fibs***
	"""
	```jldoctest
	Fibs(Nth_Fib_Number,Optional_for_Array)
	```
	Calculates the Fibbonacci sequence up to the Nth Fibbonacci number specified.\n
	Can return either a single value (The Nth Fibbonacci number), or can return an array of all Fibbonacci numbers up to and including the Nth Fibbonacci number requested.\n
	Supply a second optional arguement as *true*, to request a return of an Array.
	# Examples
	**(Nth Fibonacci only)**
	```jldoctest
	julia> N = 10
	       Fibs(N)
	       34
	```
	**(Array up to Nth Fibbonacci)**
	```jldoctest
	julia> N = 5
	       Fibs(N,true)
	       5-element  Array{Float64,1}
	       0
	       1
	       1
	       2
	       3
	```
	"""
	function Fibs(N,length = false)  #I'm calling a function within a function. Testing out that methods performance. Pretty clear as well.
		if N < 1 || typeof(N) != Int
			print_with_color(:red,"ERROR. Must supply positive integers greater than 0")
			return 
		elseif  N == 1
			return 0::Int   #Taking care of possibilities of requesting just the first or first and second 
		elseif N == 2
			length == false ? y = 1::Int : y = [0::Int,1::Int]
			return y
		end
		function temp(x,y)
			return y,x+y 	#Creating the temp function to take care of generating the next Fibbonacci number.
		end
		if N > 185
			if length == false
				x,y = BigInt(0)::BigInt,BigInt(1)::BigInt 	#If the user requests on the single numbers, then do not store the values
				for i in 3:N
					x,y = temp(x,y)
				end
				return y
			else
				x = BigInt(0)::BigInt           #Otherwise, store the values
				y = map(BigInt,zeros(N))
				y[2] = BigInt(1)::BigInt
				for i in 3:N
					x,y[i] = temp(x,y[i-1])
				end
				return y
			end
		else
			if length == false
				x,y = Int128(0)::Int128,Int128(1)::Int128 	#If the user requests on the single numbers, then do not store the values
				for i in 3:N
					x,y = temp(x,y)
				end
				return y
			else
				x = Int128(0)::Int128           #Otherwise, store the values
				y = map(Int128,zeros(N))
				y[2] = Int128(1)::Int128
				for i in 3:N
					x,y[i] = temp(x,y[i-1])
				end
				return y
			end
		end
	end

	#***End Fibs***

	#***Start Theta***
	
	"""
	```jldoctest
	Theta(x-component,y-component)
	```
	This function will take the x and y components of a vector, and return the angle theta of the vector with repsect to the positive x-axis in the counterclockwise direction.
	# Example
	```jldoctest
	julia> x = 3
	       y = 4
	       angleTheta = Theta(x,y)
	       println(angleTheta)
	       53.13
	```
	"""
	function Theta(x,y)
		r = sqrt(x^2 + y^2)                                 
		if (x >= 0 && y >= 0) || (x <= 0 && y >= 0)
			Degrees = rad2deg(acos(x/r))                      #Depending on which quadrant the vector is in, will use a different approach
		elseif x <= 0 && y <= 0                                   #to solve for degrees in counter clockwise direction with respect to positive x axis
			Degrees = 360 - rad2deg(acos(x/r))
		elseif x >= 0 && y <= 0
			Degrees = 360 + rad2deg(asin(y/r))
		else
			println("You gave [0,0], no vector exists for that")
			return
		end
		if Degrees == 360
			return 0
		else
			return Degrees
		end
	end

	#***End Theta***

	#***Start NumDeriv****
	
	"""
	```jldoctest
	NumDeriv(x,y)
	```
	This function will return the numerical derivative of the supplied data points. The x data points must have equal spacing. Using Lagrangian Interpolation in order to return an array containing the same amount of data points as the original.
	# EXAMPLE
	```jldoctest
	julia> x = 1:0.2:5
	       f(x) = x.^2
	       y = f(x)
	       Deriv_y = NumDeriv(x,y)
	```
	"""
	function NumDeriv(x,y)
		newX,newY = Lagrange(x,y,2)            #Generates interpolated points between each existing value (exclusing the first, and last element)
		dt = diff(x[1:2])[1]                   #Finds the spacing of the x data points
		deleteSpots = 3:2:length(newY)-2       #In order to take the numerical derivative, we only need the interpolated generated points.
		deleteat!(newY,deleteSpots)            #Delete all the original points
		derivative_of_Y = diff(newY)/dt        #Take the numerical derivative
		derivative_of_Y[1] = derivative_of_Y[1]*2           
		derivative_of_Y[end] = derivative_of_Y[end]*2          #Fix the first and the last point (still will be the most inaccurate)
		return derivative_of_Y
	end
end
