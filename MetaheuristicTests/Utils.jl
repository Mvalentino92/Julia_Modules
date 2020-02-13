using LightGraphs, MetaGraphs

# Finds shortest path
function sp(g::SimpleGraph,weights::Vector,u::Int,v::Int)
    mg = MetaGraph(g)
    edgelist = collect(edges(g))
    for i = 1:length(weights)
        set_prop!(mg,edgelist[i],:weight,weights[i])
    end
    path = enumerate_paths(dijkstra_shortest_paths(mg,u),v)
    cost = 0
    for i = 1:length(path)-1
        cost += get_prop(mg,path[i],path[i+1],:weight)
    end
    return path,cost
end

# Adds random weights to graph
function addweights(mg::MetaGraph)
        numv = nv(mg)
        for edge in edges(mg)
            set_prop!(mg,edge,:weight,rand()*numv + 1)
        end
end

# Returns a vector of integers corresponding to colors
function get_color_code(edgelist::Vector,ants::Vector{Ant},size::Int)

	# The matrix that will be condensed to a single Vector
	edgelen = length(edgelist)
	pathmatrix = ones(Int64,size,edgelen)

	# Begin to iterate every ant, and update the matrix
	for i = 1:size
		# For each ant path, create an edge edgelist
		ap = ants[i].path
		antedges = [ap[j] < ap[j+1] ? Edge(ap[j],ap[j+1]) :
		           Edge(ap[j+1],ap[j]) for j = 1:length(ap)-1]
		# For every edge in this list, see if it occurs in edgelist
		for antedge in antedges
			match = [j for j in 1:edgelen if edgelist[j] == antedge]
			if !isempty(match)
				pathmatrix[i,match[1]] = i+1
			end
		end
	end
	return maximum(pathmatrix,dims=1)[1,:]
end

# Get the edge index between this two vertices
function get_edge_index(edgelist::Vector,src,dst)

    # Swap src and dst if dst smaller
    if dst < src
        temp = src
        src = dst
        dst = temp
    end

    # Find the original index hit of the first binary search for src
    s = 1
    t = length(edgelist)
    hit_src = bs_src(edgelist,src,s,t)

    # Find the leftmost index of this hit
    left = hit_src > s ? lbs(edgelist,src,s,hit_src-1) : s

    # Find the rightmost index of this hit
    right = hit_src < t ? rbs(edgelist,src,hit_src+1,t) : t

    # Use original binary search to find only index of dst
    hit_dst = bs_dst(edgelist,dst,left,right)

    return hit_dst
end

# Functions needed for binarysearch
function bs_src(edgelist::Vector,target::Int,s::Int,t::Int)

    while s <= t
        m = div(s + t,2)
        current = edgelist[m].src

        if current < target
            s = m + 1
        elseif current > target
            t = m - 1
        else return m end
    end
    return -1
end

function bs_dst(edgelist::Vector,target::Int,s::Int,t::Int)

    while s <= t
        m = div(s+t,2)
        current = edgelist[m].dst

        if current < target
            s = m + 1
        elseif current > target
            t = m - 1
        else return m end
    end
    return -1
end

# Go until you fail to return!
function lbs(edgelist::Vector,target::Int,s::Int,t::Int)
    retval = t + 1
    next = bs_src(edgelist,target,s,t)
    while next > 0
        retval = next
        next = bs_src(edgelist,target,s,next-1)
    end
    return retval
end

# Go until you fail to return!
function rbs(edgelist::Vector,target::Int,s::Int,t::Int)
    retval = s - 1
    next = bs_src(edgelist,target,s,t)
    while next > 0
        retval = next
        next = bs_src(edgelist,target,next+1,t)
    end
    return retval
end
