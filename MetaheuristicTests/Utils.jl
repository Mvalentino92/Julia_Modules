using LightGraphs, MetaGraphs

# Finds shortest path
function sp(mg::MetaGraph,u::Int,v::Int)
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
