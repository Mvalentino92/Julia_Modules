#=struct Solution 
	vec::Vector
	val::Real
end=#

count = 0

mutable struct Tournament
	fighters::Vector{Solution}
	params::Vector
	hardbounds::Vector
	reach::Real
	rounds::Int
	matches::Int
end


# Return value between a and b
function randb(a::Real,b::Real)
	return a + rand()*(b-a)
end

# Return permutation of vector using reach, while staying within bounds
function permutate(vec::Vector,reach::Real,hardbounds::Vector)
	retval = similar(vec)
	for j = 1:length(vec)
		mn = vec[j]-reach
		mx = vec[j]+reach

		mn  = mn < hardbounds[j][1] ? hardbounds[j][1] : mn
		mx  = mx > hardbounds[j][2] ? hardbounds[j][2] : mx

		retval[j] = randb(mn,mx)
	end
	return retval
end


#The fight function, returns true if the left fighter won, false if the right fighter won
function fight(f::Function,tourny::Tournament,dex1::Int,dex2::Int)
	#Grab fighters
	p1 = tourny.fighters[dex1]
	p2 = tourny.fighters[dex2]

	#Set up for matches
	dim = length(p1.vec)
	fitwin = p1.val < p2.val ? 1 : 0
	p1wins = 0
	tol = exp(-tourny.reach)

	#Begin to iterate matches
	for i in 1:tourny.matches
		if rand() < tol
			p1wins += fitwin
		else
			p1prime = permutate(p1.vec,tourny.reach,tourny.hardbounds)
			p2prime = permutate(p2.vec,tourny.reach,tourny.hardbounds)
			p1wins += f(p1prime,tourny.params) < f(p2prime,tourny.params) ? 1 : 0
			global count += 2
		end
	end

	return p1wins/tourny.matches > 0.5
end

#Runs through the commencing of the tournament, the winner will be in the first index
function commence(f::Function,tourny::Tournament)
	#How many contestents are in tournament
	contestents = length(tourny.fighters)

	#For every round of the tournament
	for i = 1:tourny.rounds
		#Get shifts for fights
		opponentshift = i
		fightshift = opponentshift*2

		for j = 1:fightshift:contestents-opponentshift
			#Verdict of fight
			verdict = fight(f,tourny,j,j+opponentshift)

			#If p2 won, copy them into p1 slots
			if !verdict tourny.fighters[j] = tourny.fighters[j+opponentshift] end
		end
	end

	#Return the winner of the fight
	return tourny.fighters[1]
end

#Function to generate new tournament
function gentournament(f::Function,tourny::Tournament,winner::Solution)
	dim = length(winner.vec)
	for i = 1:length(tourny.fighters)
		vec = permutate(winner.vec,tourny.reach,tourny.hardbounds)
		tourny.fighters[i] = Solution(vec,f(vec,tourny.params))
		global count += 1
	end
end

function touramentsearch(f::Function,X0::Vector, params::Vector=[]
			 ; reach::Real=100, matches::Int=50, rounds::Int=8
			 , hardbounds::Vector=repeat([(-Inf,Inf)],length(X0)))
		 			
	#Initialize the tournament struct
	winner = Solution(X0,f(X0,params))
	fighters = Vector{Solution}(undef,trunc(Int64,2^rounds))
	tourny = Tournament(fighters,params,hardbounds,reach,rounds,matches)
	gentournament(f,tourny,winner)

	#While the reach area is still large enough
	while tourny.reach > 1e-5

		# Begin tournament	
		winner = commence(f,tourny)

		# Generate next tournament
		gentournament(f,tourny,winner)

		# Decrease reach
		tourny.reach *= 0.98789
	end

	#Return the winner of the tournament
	println(count)
	global count = 0
	return winner
end
