function matmult(A::Matrix{Int64},B::Matrix{Int64})
	if length(A) == 1 return A*B end

	s = size(A)[1]
	half = div(s,2)
	frst = 1:half
	last = half+1:s

	tl = matmult(A[frst,frst],B[frst,frst]) +
	     matmult(A[frst,last],B[last,frst])

	tr = matmult(A[frst,frst],B[frst,last]) + 
	     matmult(A[frst,last],B[last,last])

	bl = matmult(A[last,frst],B[frst,frst]) + 
	     matmult(A[last,last],B[last,frst])

	br = matmult(A[last,frst],B[frst,last]) + 
	     matmult(A[last,last],B[last,last])

	return [tl tr ; bl br]
end
