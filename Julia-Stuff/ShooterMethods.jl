#Eulers (Function,tspan,y0,h)
function euler(f::Function,tspan::Tuple{Float64,Float64},y0::Float64,h::Float64)
	#Init condintions
	t = collect(tspan[1]:h:tspan[2])
	y = zeros(Float64,length(t))
	y[1] = y0

	#Perform Euler steps
	for i = 1:length(y)-1
		roc = f(t[i],y[i])
		y[i+1] = y[i] + roc*h
	end

	return (t,y)
end

#MidPoint (Function,tspan,y0,h)
function midpoint(f::Function,tspan::Tuple{Float64,Float64},y0::Float64,h::Float64)
	#Init condintions
	t = collect(tspan[1]:h:tspan[2])
	y = zeros(Float64,length(t))
	y[1] = y0

	#Perform Midpoint steps
	for i = 1:length(y)-1
		k1 = f(t[i],y[i])
		roc = f(t[i]+h/2,y[i] + k1*h/2)
		y[i+1] = y[i] + roc*h
	end

	return (t,y)
end

#RK4 (Function,tspan,y0,h)
function RK4(f::Function,tspan::Tuple{Float64,Float64},y0::Float64,h::Float64)
	#Init condintions
	len = Int64(ceil((tspan[2] - tspan[1])/h)) + 1
	t = collect(LinRange(tspan[1],tspan[2],len)) #Vector t
	h = t[2] - t[1] #New h if applicable
	y = zeros(Float64,len)
	y[1] = y0

	#Perform RK4 steps
	for i = 1:length(y)-1
		k1 = f(t[i],y[i])
		k2 = f(t[i]+h/2,y[i] + k1*h/2)
		k3 = f(t[i]+h/2,y[i] + k2*h/2)
		k4 = f(t[i]+h,y[i] + k3*h)
		roc = (1/6)*(k1 + 2*k2 + 2*k3 + k4)
		y[i+1] = y[i] + roc*h
	end

	return (t,y)
end

#N Order Boundary Value Problem, calls RungeKutta
function BVP(F::Array{Function,1},tspan::Tuple{Float64,Float64},
	     X0::Array{Float64,1},Y0::Array{Float64,1},h::Float64)

	#Get the order, and construct identity matrix with alpha as the first element
	order = length(Y0)
	idmat = Matrix{Float64}(I,order,order)
	idmat[1] = Y0[1] 

	#Create matrix of Ys values, and get t
	len = Int64(ceil((tspan[2] - tspan[1])/h)) + 1
	t = collect(LinRange(tspan[1],tspan[2],len))
	Ys = zeros(Float64,len,order)

	#Use RungeKutta to populate matrix
	for i = 1:order
		(_,Ycur) = RungeKutta(F,tspan,idmat[:,i],h)
		Ys[:,i] = Ycur[:,1]
	end
	h = t[2] - t[1] #Update h after RungeKutta

	#Get all the c constants, c1 = 1
	C = ones(Float64,order)

	#If the order is 2, solve for c2 manually
	#Otherwise, put everything in a matrix and solve (Using Ax = b)
	if order == 2
		C[2] = (Y0[2] - Ys[end,1])/Ys[end,2]
	else #Need to get spacing for t, and find indices for all Y0's
		A = zeros(Float64,order-1,order-1)
		b = zeros(Float64,order-1)
		Cindex = zeros(Int64,order-1)
		Cindex[end] = length(t)
		for i = 1:order-2
			Cindex[i] = Int64(round((X0[i+1] - tspan[1])/h))
		end

		#Get A
		for i = 1:order-1
			A[:,i] = map(x -> Ys[:,i+1][x],Cindex)
		end

		#Get B
		for i = 1:order-1
			b[i] = Y0[i+1] - Ys[:,1][Cindex[i]]
		end

		#Get x
		x = inv(A)*b

		#Fill in rest of C
		C[2:end] = x
	end

	#Get true y value and return
	y = zeros(Float64,len)
	for i = 1:order
		println(Ys[:,i])
		y += C[i]*Ys[:,i]
	end
	return (t,y)
end

#RungeKutta ([Functions],tspan,[Y0],j)
function RungeKutta(F::Array{Function,1},tspan::Tuple{Float64,Float64},Y0::Array{Float64,1},h::Float64)
	#Init time and return vals
	len = Int64(ceil((tspan[2] - tspan[1])/h)) + 1
	t = collect(LinRange(tspan[1],tspan[2],len)) #Vector t
	h = t[2] - t[1] #New h if applicable
	dim = length(Y0) #cols
	Y = zeros(Float64,len,dim) #Return values

	#Create K vectors
	K1 = zeros(Float64,dim)
	K2 = zeros(Float64,dim)
	K3 = zeros(Float64,dim)
	K4 = zeros(Float64,dim)

	#Populate initial conditions
	for j = 1:dim Y[1,j] = Y0[j] end


	#Perform RK4 steps
	for i = 1:len-1
		for j = 1:dim K1[j] = F[j](t[i],Y[i,:]) end
		for j = 1:dim K2[j] = F[j](t[i]+h/2,Y[i,:] + K1.*h/2) end
		for j = 1:dim K3[j] = F[j](t[i]+h/2,Y[i,:] + K2.*h/2) end
		for j = 1:dim K4[j] = F[j](t[i]+h,Y[i,:] + K3.*h) end
		roc = (1/6).*(K1 + K2.*2 + K3.*2 + K4)
		Y[i+1,:] = Y[i,:] + roc.*h
	end

	return (t,Y)
end

#shooterCompare (PlotTitle,Function,tspan,y0,h,TrueFunction)
function shooterCompare(func::String,f::Function,tspan::Tuple{Float64,Float64},y0::Float64,h::Float64,ftrue::Function)
	#Get all y results from all 3 methods
	(_,yEuler) = euler(f,tspan,y0,h)
	(_,yMidPoint) = midpoint(f,tspan,y0,h)
	(_,yRK4) = RK4(f,tspan,y0,h)

	#Get the true values
	t = collect(tspan[1]:h:tspan[2])
	yTrue = ftrue.(t)

	#Stuff into one variable
	Y = [yEuler yMidPoint yRK4 yTrue]

	#Get the error for each
	errEuler = abs.(yTrue - yEuler)
	errMidPoint = abs.(yTrue - yMidPoint)
	errRK4 = abs.(yTrue - yRK4)

	#Stuff errors into one variable
	errY = [errEuler errMidPoint errRK4]

	#Plot methods
	p1 = plot(t,Y,title="Comparison for: $func",xlabel="Time",ylabel="Function Values",
	     label=["Euler" "MidPoint" "RK4" "True"])

	#Plots errors
	p2 = plot(t,errY,title="Errors",xlabel="Time",ylabel="Error",
	     label=["Euler" "MidPoint" "RK4"])

	#Wrap in subplot
	plot(p1,p2,layout=(2,1))
end
