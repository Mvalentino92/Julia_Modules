#Solution struct
struct Solution
	vec::Vector
	val::Real
end

#Model
mutable struct SAmodel
	X::Solution
	params::Vector
	hardbounds::Vector
	D::Matrix
	δ::Real
	passmax::Real
	failmax::Real
	trials::Int
end

#Convergence test
function converged(D::Matrix,tol::Real)
	return sum(D)/size(D)[1] < tol
end

#Thermal equilibrium function
function thermalequilibrium(f::Function,samodel::SAmodel,T::Real)
	#Conditions for thermal equilibrium
	len = length(samodel.X.vec)
	pass = 0
	fail = 0

	#For the number of trials to attempt thermal equilibrium
	for i = 1:samodel.trials
		#Create new solution
		R = map(x -> (x - 0.5)*2,rand(len))
		X1 = samodel.X.vec + samodel.D*R
		#Adjust for hardbounds
		for i = 1:len
			X1[i] = X1[i] < samodel.hardbounds[i][1] ? samodel.hardbounds[i][1] : X1[i]
			X1[i] = X1[i] > samodel.hardbounds[i][2] ? samodel.hardbounds[i][2] : X1[i]
		end
		X1val = f(X1,samodel.params)

		#Accept or reject new solution, update pass or fail
		if X1val < samodel.X.val 
			samodel.X = Solution(X1,X1val)
			pass += 1
		elseif rand() < exp(-(X1val - samodel.X.val)/T)
			samodel.X = Solution(X1,X1val)
			pass += 1
		else fail += 1 end
	end

	#Check if at thermal equilibrium, adjust accordingly
	if pass/samodel.trials > samodel.passmax #Too shy
		samodel.D /= samodel.δ
	elseif fail/samodel.trials > samodel.failmax #Too bold
		samodel.D *= samodel.δ
	else #Just right
		return true
	end
	return false
end
	
#eqlibtol ∈ (0,0.5)
function simanneal(f::Function,X0::Vector,params::Vector=[]
		   ; hardbounds::Vector=repeat([(-Inf,Inf)],length(X0))
		   , stepsize::Vector=[], stepdecay::Real=0.98789
		   , temperature::Real=1.0, islinear::Bool=false, tempdecay::Real=(islinear ? 1e-3 : 0.98789)
		   , convergencetol::Real=1e-7, maxfe::Int=5000000
		   , eqlibratio::Tuple=(1,1), eqlibtol::Real=0.1,eqlibtrials::Int=100)

	#=***Initialize simmulated annealing model***=#
	dim = length(X0)
	X = Solution(X0,f(X0,params))

	#Initiate matrix D for step size, use hardbounds if no step size provided
	wasempty = isempty(stepsize)
	D = zeros(dim,dim)
	for i = 1:dim
		step = wasempty ? (hardbounds[i][2] - hardbounds[i][1])/2 : stepsize[i]
		step = step == Inf ? 365*rand() : step
		D[i,i] = step
	end

	#Parameters for thermal equilibrium
	total = sum(eqlibratio)
	passmax = eqlibratio[1]/total + eqlibtol
	failmax = eqlibratio[2]/total + eqlibtol

	#Create model struct
	samodel = SAmodel(X,params,hardbounds,D,stepdecay,passmax,failmax,eqlibtrials)

	#Track number of function evaluations	
	fe = 1

	#While stopping critera not met (temp, function calls, and convergence)
	while temperature > 0 && fe < maxfe && !converged(samodel.D,convergencetol)
		#While not at thermal equilibrium
		while !thermalequilibrium(f,samodel,temperature)
			fe += samodel.trials
			if fe > maxfe break end #Check if hit max function calls every time
		end
		fe += samodel.trials

		#Once at thermal equilibrium, decrease temperature
		temperature = islinear ? temperature - tempdecay : temperature*tempdecay
	end
	println(temperature," ",fe," ",sum(samodel.D)/size(samodel.D)[1])

	return (samodel.X.vec,samodel.X.val)
end
