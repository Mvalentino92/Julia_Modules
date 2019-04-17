function quasiNewton(F::Array{Function,1},X::Array{Float64,1},h::Float64,tol::Float64)
	xh = [h,0,0]
	yh = [0,h,0]
	zh = [0,0,h]
	fmap(F,X) = map(f -> f(X),F)
	while sum(abs.(fmap(F,X))) > tol
		jx = (fmap(F,X+xh) - fmap(F,X-xh))/(2*h)
		jy = (fmap(F,X+yh) - fmap(F,X-yh))/(2*h)
		jz = (fmap(F,X+zh) - fmap(F,X-zh))/(2*h)
		J = hcat(jx,jy,jz)
		X = X - inv(J)*fmap(F,X)
	end
	return X
end
