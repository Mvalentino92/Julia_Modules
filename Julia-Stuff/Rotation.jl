function rotr(xs,n::Int64,vargs...)
	#Base case, return if no rotation
	if n == 0 return end

	#Optional args, getting bounds of rotation
	if length(vargs) == 0 a,b = 1,length(xs)
	else a,b = vargs end

	#Find the remainder to rotate excess by
	#Track swap position with ii
	rem = (b - a + 1) % n
	ii = 1+n

	#Swap and order the right side of the array
	for i = a+n:b
		j = (ii-1) % n + a 
		temp = xs[i]
		xs[i] = xs[j]
		xs[j] = temp
		ii += 1
	end

	#Rotate left on the left side thats unordered
	rotl(xs,rem,a,a+n-1)
end

function rotl(xs,n::Int64,vargs...)
	#Base case, return if no rotation
	if n == 0 return end

	#Optional args, getting bounds of rotation
	if length(vargs) == 0 a,b = 1,length(xs)
	else a,b = vargs end

	#Find the remainder to rotate excess by
	#Track swap position with ii
	rem = (b - a + 1) % n
	ii = 1+n

	#Swap and order the left side of the array
	for i = b-n:-1:a
		j = b - ((ii-1) % n)
		temp = xs[i]
		xs[i] = xs[j]
		xs[j] = temp
		ii += 1
	end

	#Rotate right on the right side thats unordered
	rotr(xs,rem,b-n+1,b)
end
