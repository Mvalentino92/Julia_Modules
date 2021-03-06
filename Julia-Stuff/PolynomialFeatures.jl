function permutations(xs)
	if length(xs) == 1 return [xs] end

	retval = []
	for i = 1:length(xs)
		pre = xs[i]
		rest = xs[setdiff(1:length(xs),i)]
		append!(retval,map(x -> prepend!(x,pre),permutations(rest)))
	end
	return retval
end

function unipermutations(xs)
	if length(xs) == 1 return [xs] end
	retval = []
	visited = Set([])
	for i = 1:length(xs)
		pre = xs[i]
		if pre in visited continue end
		rest = xs[setdiff(1:length(xs),i)]
		append!(retval,map(x -> prepend!(x,pre),unipermutations(rest)))
		push!(visited,pre)
	end
	return retval
end

function partitions(n,k=1)
	if n == 1 return [[1]] end
	retval = [[n]]
	while k <= n/2
		append!(retval,map(x -> prepend!(x,k),partitions(n-k,k)))
		k += 1
	end
	return retval
end

function fillpartitions(n,depth)
	return collect(Iterators.flatten(map(x -> unipermutations(append!(x,zeros(depth - length(x)))),partitions(n))))
end

function pf(order,depth)
	retval = []
	for i = 1:order
		append!(retval,fillpartitions(i,depth))
	end
	return retval
end

function transform(X,py)
	mapslices(features -> map(powers -> mapreduce((feature,power) -> feature^power,*,features,powers),py),X,dims=2)
end

function choose(n,r)
	if r == 1 return map(x -> [x],n) end
	retval = []
	for i = 1:length(n)
		pre = n[i]
		append!(retval,map(x->prepend!(x,pre),choose(n[i+1:end],r-1)))
	end
	return retval
end

function poly(features,order)
	retval = copy(features)
	for i = order:-1:2
		part = partitions(i)
		for p in part
			r = length(p)
			perm = unipermutations(p)
			ch = choose(features,r)
			for c in ch
				for pr in perm
					push!(retval,mapreduce((x,y) -> x^y,*,c,pr))
				end
			end
		end
	end
	return retval
end
