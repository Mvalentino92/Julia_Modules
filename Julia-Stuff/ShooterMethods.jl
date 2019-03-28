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
	t = collect(tspan[1]:h:tspan[2])
	y = zeros(Float64,length(t))
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

#RungeKutta ([Functions],tspan,[Y0],j)
function RungeKutta(F::Array{Function,1},tspan::Tuple{Float64,Float64},Y0::Array{Float64,1},h::Float64)
	#Init time and return vals
	t = collect(tspan[1]:h:tspan[2]) #Vector t
	len = length(t) #rows
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
