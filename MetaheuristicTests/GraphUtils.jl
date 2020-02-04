using LightGraphs, SimpleWeightedGraphs, StatsBase

# Gets an edge from a set of edges, given the source and destination vertices
function get_edge(edges::Vector,src::Real,dst::Real,turn::Int64=0)
	from_src = filter(x -> x.src == src,edges)
	to_dst = filter(x -> x.dst == dst,from_src)
	if isempty(to_dst) return turn == 1 ? nothing : get_edge(edges,dst,src,1) end
	return to_dst[1]
end

# Gets an edge from a graph, given source and destination vertices.
function get_edge(g::SimpleWeightedGraph,src::Real,dst::Real)
	return get_edge(collect(edges(g)),src,dst)
end

# Given an array of visited vertices and edgelist return edges traveled
function edge_path(edges::Vector, vertices::Vector)
	nedges = length(vertices)-1
	path = Vector{SimpleWeightedEdge}(undef,nedges)
	for i = 1:nedges
		path[i] = get_edge(edges,vertices[i],vertices[i+1])
	end
	return path
end

# Given an array of visited vertices and graph, return edges traveled
function edge_path(g::SimpleWeightedGraph,vertices::Vector)
	return edge_path(collect(edges(g)),vertices)
end

# Finds the shortest path and returns edgelist, and value
function shortestpath(g::SimpleWeightedGraph,src::Real,dst::Real)
	sp = dijkstra_shortest_paths(g,src)
	if sp.dists[dst] == Inf return [],Inf end
	vertices = enumerate_paths(sp,dst)
	epath = edge_path(g,vertices)

	elen = length(epath)
	epath[1] = epath[1].src == src ? epath[1] : reverse(epath[1])
	epath[elen] = epath[elen].dst == dst ? epath[elen] : reverse(epath[elen])
	for i = 2:elen-1
		epath[i] = epath[i-1].dst == epath[i].src ? epath[i] : reverse(epath[i])
	end
	return (epath,sp.dists[dst])
end

# Generate a random weighted graph with n vertices, and m edges
function gen_graph(n::Int,p::Float64)
	# Get max
	mx = div(n*n - n,2)
	sources = Vector{Int64}(undef,mx)
	destinations = Vector{Int64}(undef,mx)

	# Fill sources and destinations
	k = 1
	for i = 1:n-1
		for j = i:n-1
			sources[k] = i
			destinations[k] = j+1
			k += 1
		end
	end

	# Take random sample
	m = trunc(Int64,mx*p)	
	take = sample(1:mx,m,replace=false)
	sources = sources[take]
	destinations = destinations[take]

	weights = map(x -> rand()*1000,1:m)
	return SimpleWeightedGraph(sources,destinations,weights)
end
