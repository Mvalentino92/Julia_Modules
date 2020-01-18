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
	Dlim::Vector
	δ::Real
	passmax::Real
	passmin::Real
	trials::Int
end

#Convergence test
function converged(D::Matrix,tol::Real)
	return sum(D)/size(D)[1] < tol
end

#Thermal equilibrium function
function thermalequilibrium(f::Function,samodel::SAmodel,T::Real)
	#Conditions for thermal equilibrium
	dim = length(samodel.X.vec)
	pass = 0

	#For the number of trials to attempt thermal equilibrium
	for i = 1:samodel.trials
		#Create new solution
		R = map(x -> (x - 0.5)*2,rand(dim))
		X1 = samodel.X.vec + samodel.D*R

		#Adjust for hardbounds
		for i = 1:dim
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
		end
	end

	#Check if at thermal equilibrium, adjust accordingly
	passratio = pass/samodel.trials
	if passratio > samodel.passmax #Too shy
		samodel.D /= samodel.δ
		#Limit check
		for i = 1:dim
			samodel.D[i,i] = samodel.D[i,i] > samodel.Dlim[i] ? samodel.Dlim[i] : samodel.D[i,i]
		end
	elseif passratio < samodel.passmin #Too bold
		samodel.D *= samodel.δ
	else #Just right
		return true
	end
	return false
end
	
#The main algorithm
#                MANDATORY 
# f: The objective function. Must take 2 vector paramters, x::Vector and params::Vector
# X0: The initial guess vector
#                OPTIONAL
# params: To be passed to objective function f, default is empty
#                KEY WORD ARGS
# hardbounds: Bounds restricting the algorithm from searching beyond this domain 
# stepsize: Initial stepsize, will default to values influenced from bounds, or random
# stepdecay: The constant for decreasing or increasing stepsize based on result of thermal equilibrium attempts
# steplimit: An upper bound limit for the stepsize. Prevents algorithm from diverging.
# 	     Default if not specified is the stepsize
# temperature: The temperature, default is 1. Higher values allow for worse solutions.
# islinear: Will use linear decay instead of exponential for the temperature
# tempdecay: Defaults for both exponential and linear
# convergencetol: How small the step size needs to be after thermal equilibrium to stop the algorithm
# maxfe: The maximum amount of function evaluations before terminating algorithm
# eqlibratio: The ratio for accepting and rejecting solutions. In the format (accept,reject)
# eqlibtol: The tolerance for thermal equilibrium. ∈ (0,1). Its relative to ratios.
#           0.1 tolerance with accept value of 0.4 (after calculation) will be 0.44 (0.4 + 0.4*0.1)
# eqlibtrails: How many trials for each iteration of attempting thermal equilibrium
# sinusoidal: Changes the equilibrium ratios in a sinusoidal fashion. Will alternate between high accept,
#             low reject, and low accept, high reject in a sine wave. Affected and converges towards the default
#             eqlibration given over time, through an exponential decay of the amplitude of the sine wave.
# sincoeff: The coefficient dictating the initial amplitude of the sine wave. Must ∈ [0,0.4]
# sindecay: The exponential decay of the sincoeff. As it approaches 0, the initial eqlibratio is achieved.
# sinupdate: The value to add to k, in sin(k) =#
function simanneal(f::Function,X0::Vector,params::Vector=[]
		   ; hardbounds::Vector=repeat([(-Inf,Inf)],length(X0))
		   , stepsize::Vector=[], stepdecay::Real=0.98789, steplimit::Vector=[]
		   , temperature::Real=1.0, islinear::Bool=false, tempdecay::Real=(islinear ? 1e-3 : 0.98789)
		   , convergencetol::Real=1e-7, maxfe::Int=5000000
		   , eqlibratio::Tuple=(1,1), eqlibtol::Real=0.1,eqlibtrials::Int=100
		   , sinusoidal::Bool=false, sincoeff::Real=pi/10, sindecay::Real=0.98, sinupdate::Real=pi/21)

	#=***Initialize simmulated annealing model***=#
	dim = length(X0)
	X = Solution(X0,f(X0,params))

	#Initiate matrix D for step size, use hardbounds if no step size provided
	sizeempty = isempty(stepsize)
	limitempty = isempty(steplimit)
	D = zeros(dim,dim)
	Dlimit = zeros(dim)
	for i = 1:dim
		step = sizeempty ? (hardbounds[i][2] - hardbounds[i][1])/2 : stepsize[i]
		D[i,i] = step == Inf ? 365*rand() : step
		Dlimit[i] = limitempty ? D[i,i] : steplimit[i]
	end

	#Parameters for thermal equilibrium
	total = sum(eqlibratio)
	initial = eqlibratio[1]/total
	passmax = initial + (1-initial)*eqlibtol
	passmin = initial*(1-eqlibtol)

	#Create model struct
	samodel = SAmodel(X,params,hardbounds,D,Dlimit,stepdecay,passmax,passmin,eqlibtrials)

	#Track number of function evaluations, and sin value
	fe = 1
	k = 0
	sincoeff = sincoeff > 4 || sincoeff < 0 ? pi/10 : sincoeff
	x = ((0.5 + sincoeff) - initial)/sincoeff - 1

	#While stopping critera not met (temp, function calls, and convergence)
	while temperature > 0 && fe < maxfe && !converged(samodel.D,convergencetol)

		#While not at thermal equilibrium
		while !thermalequilibrium(f,samodel,temperature)
			fe += samodel.trials
			if fe > maxfe break end #Check if hit max function calls every time
		end

		#Update passmax and passmin if opted for sinusoidal
		if sinusoidal
			temp = initial + sincoeff*(x+sin(k))
			samodel.passmax = temp + (1-temp)*eqlibtol
			samodel.passmin = temp*(1-eqlibtol)
			sincoeff *= sindecay
			k += sinupdate
		end
		
		#Increase function calls once more to account for while loop terminating
		fe += samodel.trials

		#Once at thermal equilibrium, decrease temperature
		temperature = islinear ? temperature - tempdecay : temperature*tempdecay
	end

	return (samodel.X.vec,samodel.X.val)
end
