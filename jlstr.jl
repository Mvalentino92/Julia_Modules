module jlstr
	#This file will contain any relevant functions I need for operating on Strings, or anything not particularly related to mathematical needs.

	#***Start Count***

	#Counts the number of occurances of a character(s) in a string.
	"""
	```jldoctest
	Count(String,Character(s))
	```
	Counts the amount of times the supplied character(s) occurs in the given string.
	# Examples
	```jldoctest
	julia> My_String = "Writing code in Julia is so easy!!"
	       Num_of_occur = Count(My_String,"i")
	       print(Num_of_occur)
	       5
	```
	"""
	function Count(String,Character)
		String_Length = length(String)		
		Occur_Length = length(Character)
		Total_Occur = 0
		for i=1:String_Length			#Im iterating over the elements in the string
			Total_Match = 0			#I need to track if all the elements of the target string match
			for j=0:Occur_Length - 1				#Starting the second iteration to accomplish that
				if length(String[i:end]) >= Occur_Length	#Only check if you have enough space too!
					if String[i+j] == Character[j+1]	#EX: If I'm looking for 'happy', and the string is 3 char long
						Total_Match += 1		#It's a no go!
					end
				end
			end
			if Total_Match == Occur_Length		#If all the character match, add a point to total
				Total_Occur += 1
			end
		end
		return Total_Occur
	end

	#***End Count***

	#***Start rotR***

	#This function will rotate the elements in an array to right by the specified number of times.
	"""
	```jldoctest
	rotR(Array,Num_of_places)
	```
	Rotates an array the amount of places specified to the right.\n
	Works for *overshooting* as well. **Example:** If the array is of length 5, rotating 10 places will yield the same array.
	# Examples
	```jldoctest
	julia> Array = [1,2,3,4,5]
	       rotR(Array,3)
	       print(Array)
	       [3,4,5,1,2]
	```
	"""
	function rotR(array,n)
		if n == length(array)		#If the rotation matches the number of elements itll do a perfect 360!
			return array
		end
		while n > length(array)	   	#You can go more than 360 though! 540 is the same as 180!. But we can only work with 180!
			n -= length(array)	#Minus 360 til we can work with it!
		end
		Temp = array[end-n+1:end]	#Make a temporary array holding the elements that are going to do a revolution around!
		array[n+1:end] = array[1:end-n]		#Now move up the elements up that wont 'go over the edge'
		array[1:n] = Temp[1:n]			#Place the numbers from the temporary array where they belong! (Beginning)
		return array
	end
		
	#***End rotR***

	#***Start rotL***

	#This functiion will rotate the elements in array to the left by the specified number of times
	"""
	```jldoctest
	rotL(Array,Num_of_places)
	```
	Rotates an array the amount of places specified to the left.\n
	Works for *overshooting* as well. **Example:** If the array is of length 5, rotating 10 places will yield the same array.
	# Examples
	```jldoctest
	julia> Array = [1,2,3,4,5]
	       rotL(Array,2)
	       print(Array)
	       [3,4,5,1,2]
	```
	"""
	function rotL(array,n)
		if n == length(array)
			return array	#See above function!
		end
		while n > length(array)
			n -= length(array)
		end
		Temp = array[1:n]	#Same deal,save the elements that will 'fall off'
		array[1:end-n] = array[n+1:end]		#Place the elements where they belong, since they have room to move
		array[end-n+1:end] = Temp[1:n]		#And finally put the elements in the temp array where they belong (at the end)
		return array
	end

	#***Start slowSort***

	#=This function will sort an array in non decreasing order. Destroys/deletes the original. Efficient until around 1e4=#
	"""
	```jldoctest
	slowSort(Array)
	```
	Sorts an array in **non** decreasing order. Destroys the original array in the process.\n
	This function is inferior to `Sort`, advisable to use `Sort` instead.
	# Examples
	```jldoctest
	julia> x = [4,87,2,0,8]
	       y = slowSort(x)
	       print(x)
	       {} Empty Array!
	       print(y)
	       [0,2,4,8,87]
	```
	"""
	function slowSort(x)
		y = zeros(length(x))    #Making a new array of zeros. Doing the transfer technique
		for i=1:length(x)
			track = 1
			best = x[1]             #So the default lowest number will alwys be the first one
			for j=1:length(x)       #Iterating through starting from the top
				if x[j] < best
					best = x[j]             #if the number is lower, replace best
					track = j
				end
			end
			y[i] = best             #best is now the lowest number in x, so put it as the first entry into y
			deleteat!(x,track)      #So we dont just have an array of the first best, we need to delete it!
		end
		return y                        #return the new, and sorted vector y
	end

	#***End slowSort***

	#***Begin Sort***

	#Same as before, except a little bit more optimized, and doesnt destroy the original array.
	"""
	```jldoctest
	Sort(Array)
	```
	Sorts the supplied array in **non** decreasing order. Returns the original array sorted.\n
	Not intended for arrays of length 1e5++.
	# Examples
	```jldoctest
	julia> x = [4,98,3,65,8,8,9]
	       Sort(x)
	       print(x)
	       [3,4,8,8,9,65,98]
	```
	"""
	function Sort(x)
		for i=1:length(x)-1     #Only going out to the second to last elements, because the last remaining element, will be the largest
			hold = x[i]     #Setting a variable to hold the value that will be replaced
			best = x[i]
			tracker = i             #This will track if the best value was updated or not
			for j=(i+1):length(x)
				if x[j] < best          #Again, keep replacing the best (lowest) value
					best = x[j]
					tracker = j
				end

			end
			if tracker != i                 #If tracker changed (as in the original best wasnt the smallest value)..
				x[i] = x[tracker]       #Then switch the values around
				x[tracker] = hold
			else
				continue                #Otherwise, just do nothing, it was already the lowest!
			end
		end
		return x
	end

	#***End Sort***

	#***Start Sinput***

	"""
	```jldoctest
	Sinput(User_Prompt)
	```
	Prompts the user for String input, and saves the input to a variable.
	# Examples
	```jldoctest
	julia> Name = Sinput("What is you're name partner?: ")
	       What is you're name partner: Mike
	       print(Name)
	       Mike
	```
	"""
	function Sinput(Prompt)
		print(Prompt)
		chomp(readline())
	end

	#***End Sinput***

	#***Start Finput***
	"""
	```jldoctest
	Finput(User_Prompt)
	```
	Prompts the user for Float input, and saves the input to a variable.
	# Examples
	```jldoctest
	julia> Fav_Float = Finput("What is you're favorite Float?: ")
	       What is you're favorite Float?: 1.666
	       print(Fav_Float)
	       1.666
	```
	"""
	function Finput(Prompt)
		print(Prompt)
		parse(Float64,readline())
	end

	#***End Finput***

	#***Start Ninput***
	"""
	```jldoctest
	Ninput(User_Prompt)
	```
	Prompts the user for Int input, and saves the input to a variable.
	# Examples
	```jldoctest
	julia> Fav_Integer = Ninput("What is you're favorite Integer?: ")
	       What is you're favorite Integer?: 21
	       print(Fav_Float)
	       21
	```
	"""
	function Ninput(Prompt)
		print(Prompt)
		parse(Int64,readline())
	end

	#***End Ninput***

	#Start***alphasort***
	"""
	```jldoctest
	alphasort(Array_to_be_alphabetized)
	```
	This function will return the supplied array sorted in alphabetical order. Not speed efficient, will only work quickly on arrays ~ length(1000) and below
	# Examples
	```
	julia> Name_list = ["Mike","alexa","al","albert","zoe","Q","Raymond"]
	       alphasort(Name_list)
	       7-element Array{String,1}
	       "al"
	       "albert"
	       "alexa"
	       ...
	       "zoe"
	```
	"""
	function alphasort(x)
		for i=1:length(x)-1               #First I have to iterate through every word and keep updating which word replaces it in that slot
			Tester = true             #A variable that will be declared true every time in anticipation of the while loop
			Word_Hold = x[i]          #A variable to hold the value of the current word at the current index
			Lowest_Value = Int(uppercase(x[i][1]))           #First, we need to find which first letter is the next lowest value
			for j=i:length(x)     #Note we iterate from the next index every time
				if Int(uppercase(x[j][1])) < Lowest_Value
					Lowest_Value = Int(uppercase(x[j][1]))      #This loop is finding that next lowest value of the first letter
				end
			end
			Letter = 2            #The variable letter will update to which letter were currently checking for the lowest value
			Values = []           #We need a list of all the "winning" lowest values for the current iteration.
			while Tester == true
				push!(Values,Lowest_Value)     #Keep appending those values!
				Lowest_Value_Two = 635         #Merely a placeholder that has an initial non-important value
				Counter = 0
				Place = 0        #These are all tracking variables for various if statements
				Circumvent = 0
				for k=i:length(x)
					if length(x[k]) >= Letter-1 #Checking to make sure the word is long enough to actually be checked!
						if map(uppercase,x[k][1:Letter-1]) == String(map(Char,Values))  #If it is qualified contender...
								 if length(x[k]) == Letter-1       #If it is the winner by process of, well...shortness!
									 if k == i
										 Tester = false   #If it was lucky and was the winning word all along!
										 break
									 else
										 Circumvent = 1  #otherwise, switch it with the current word
										 x[i] = x[k]     #And circumvent is 1, so we dont switch again in case counter is 1
										 x[k] = Word_Hold
										 Tester = false
										 break
									 end
								 else
									 Counter += 1    #Else, increase counter, and update Place to hold k's value so can switch later
									 Place = k
									 if Int(uppercase(x[k][Letter])) < Lowest_Value_Two     #Simply finding lowest again
										 Lowest_Value_Two = Int(uppercase(x[k][Letter]))
									 end
								 end
						end
					end
				
				end
				Lowest_Value = Lowest_Value_Two  #After everything, set the new lowest_value to be added to values array in next iteration
				Letter += 1       #increase letter by 1!
				if Counter == 1 && Circumvent == 0  #okay so if counter is 1, and circumvent is 0, then switch them. it was the only one with a match.
					x[i] = x[Place]
					x[Place] = Word_Hold
					Tester = false
				end
			end
		end
		return x #And return it!
	end
	#***End alphasort***

	#***Start strcmp***

	"""
	```jldoctest
	strcmp(String_1,String_2)
	```
	Compares two strings and returns a value specifying which is lower in alphabetical order. If String_1 is lower, returns -1, If String_2 is lower, return 1. If equal, returns 0.\n
	**Note** This function does not differentiate between uppercase and lowercase characters.
	# Example
	```jldoctest
	julia> a = "hello man"
	       b = "hey"
	       Verdict = strcmp(a,b)
	       println(Verdict)
	       -1
	```
	"""
	function strcmp(str1,str2)
		Shorter,Tracker = length(str1) <= length(str2) ? [length(str1),true] : [length(str2),false] # Checks which string has less characters.
		Checker = 1  # Have to track which index to compare up to
		while Checker <= Shorter #Only compare up to this Index
			if Int(uppercase(str1[Checker])) < Int(uppercase(str2[Checker]))
				return -1                                                         #Checking to see which string is lower alphabetically character by character
			elseif Int(uppercase(str1[Checker])) > Int(uppercase(str2[Checker]))
				return 1
			else
				Checker += 1        #If the characters are equal, keep going
			end
		end
		if Tracker == true        #So if all the checked characters were equal.... If str1 was the shorter one, then its lower alphabetically
			return -1
		elseif Tracker == false  #Otherwise if str2 was the shorter one, then its lower alphabetically
			return 1
		else
			return 0          #Otherwise they were equal, and they are the same string!
		end
	end

	#***End strcmp***

	#***Start Alpha***

	"""
	```jldoctest
	Alpha(Array_to_be_Alphabetized)
	```
	This will sort the given array alphabetically. This function calls `strcmp`. To see how this function interprets characters and see `strcmp`.
	# Example
	```jldoctest
	julia> Names = ["alexa","matthew","matt","al","zeke"]
	       Alpha(Names)
	       5-element Array{String,1}
	       "al"
	       "alexa"
	       "matt"
	       "matthew"
	       "zeke"
	```
	"""
	function Alpha(x)               #See Sort for an explanation of the code. This simply inserts the strcmp function at the point of evaluation during each iteration.
		for i=1:length(x)-1       
			Hold = x[i]
			best = x[i]
			Tracker = i
			for j=(i+1):length(x)
				if strcmp(x[j],best) == -1
					best = x[j]
					Tracker = j
				end
			end
			if Tracker != i
				x[i] = x[Tracker]
				x[Tracker] = Hold
			else
				continue
			end
		end
		return x
	end

	#***End Alpha***
end
