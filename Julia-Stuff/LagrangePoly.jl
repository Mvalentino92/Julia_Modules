using LinearAlgebra
#=Uses the Choose Function to calculate a desired coefficient
#from lagranges numerator EXAMPLE using -> (x-5)*(x+2.3)*(x-1.7)*(x+3)*(x-9.2)
#n = [-5,2.3,-1.7,3,-9.2]
#r = 3, corresponds to x^2 (This is the same as n Choose r, where n = 5)
#index = 1, (will always equal one, changes during recursive calls=#
#table, dynamic, makes it faster
function choose(n,r,index,table)
	if table[r,index] != 0 return table[r,index] end
	if r == 1 return sum(n[index:end]) end
	s = 0
	for i = index:length(n)-r+1
		s += n[i] * choose(n,r-1,i+1,table)
	end
	table[r,index] = s
	return s
end

#Wrapper
function fastChoose(n,r)
	table = zeros(r,length(n))
	return choose(n,r,1,table)
end

#Gets all possible combos (all coefficients
function totalChoose(n)
	l = length(n)
	table = zeros(l,l)
	poly = zeros(l+1)
	poly[1] = reduce(*,n)
	poly[end] = 1
	for i = 2:l
		poly[l-i+2] = choose(n,i-1,1,table)
	end
	return poly
end

#Actually does lagrange
g(x) = x*(-1)
function lag(xs,ys)
	n = length(xs) 
	m = n - 1
	mat = zeros(n,n)
	for i = 1:n
		current = splice!(xs,i) # Take out first element
		map!(g,xs,xs) #Flip all the signs, for passing to choose func
		mat[i,:] = totalChoose(xs) #Find total polynomial for row
		denom = mapreduce(x->current + x,*,xs) # Get denominator
		mat[i,:] = map(x->x*ys[i]/denom,mat[i,:]) #Multiply by y value, and divide by denom
		map!(g,xs,xs) #Reflip elements, work is done
		splice!(xs,i:i-1,current) #Add element back
		println(mat[i,:])
	end
	return reduce(+,mat,dims=1) #Reduce row wise, to add polys
end
