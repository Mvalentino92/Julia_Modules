using Plots
using DifferentialEquations

function dummyfunc(x...)
    return 0
end

#= Where p has:
p[1] = m
p[2] = n
p[3] = dx^2
p[4] = dy^2
p[5] = K =#
function rhs(u_t,u,p,t)
    # Calculate
    #Zero out
    map!(x -> 0.0,u_t,u_t)

    for col = 2:p[1]-1
        for row = 2:p[2]-1
            c = (col-1)*p[2] + row
            l = c - p[2]
            r = c + p[2]
            b = c - 1
            t = c + 1

            u_xx = (u[l] - 2*u[c] + u[r])/p[3]
            u_yy = (u[t] - 2*u[c] + u[b])/p[4]

            u_t[c] = p[5]*(u_xx + u_yy)
        end
    end
end



function laplace(L::Real,H::Real,m::Int,n::Int,K::Real,tend::Real;
                 u_0y::Function=dummyfunc, u_Ly::Function=dummyfunc,
                 u_x0::Function=dummyfunc, u_xH::Function=dummyfunc,
                 ic::Function=dummyfunc)

    # Begin to construct the dimensions in vectorized form.
    # For clarity, m is columns, and n is rows.
    # H of y, is the bottom of the matrix. (It's inverted)
    x = collect(LinRange(0,L,m))
    y = collect(LinRange(0,H,n))
    dx = x[2] - x[1]
    dy = y[2] - y[1]
    uvec = zeros(m*n)

    # ***Construct boundary conditions***

    # Left
    uvec[1:n] = u_0y.(y)

    # Right
    uvec[n*(m-1)+1:end] = u_Ly.(y)

    # top and bottom in y, they are inverted
    id = 1
    for b = 1:n:m*n
        t = b + n - 1
        uvec[b] = u_x0(x[id]) #Top of matrix, bottom of plate
        uvec[t] = u_xH(x[id]) #Bottom of matrix, top of plate
        id += 1
    end

    # Initial conditions
    for col = 2:m-1
        for row = 2:n-1
            c = (col-1)*n + row
            uvec[c] = ic(x[col],y[row])
        end
    end

    # Define Problem
    p = Vector{Any}(undef,5)
    p[1] = m
    p[2] = n
    p[3] = dx*dx
    p[4] = dy*dy
    p[5] = K
    tspan = (0.0,tend)
    prob = ODEProblem(rhs,uvec,tspan,p)
    sol = solve(prob)

    mnmx = map(u -> (minimum(u),maximum(u)),sol.u)
    mn = minimum(map(val -> first(val),mnmx))*1.2
    mx = maximum(map(val -> last(val),mnmx))*1.2
    anim = @animate for i = 1:length(sol.t)
        z = reshape(sol.u[i],n,m)
        surface(x,y,z,
		title=string("Time: ",sol.t[i]),xlims=(0,L),ylims=(0,H),zlims=(mn,mx))
    end
    gif(anim,"/mnt/chromeos/MyFiles/Downloads/PDES/trial.gif",fps=5)

end
