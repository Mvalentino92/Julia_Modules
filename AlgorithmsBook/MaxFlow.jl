mutable struct Source
	flow::Int64
	outgoingIndex::Array{Int64,1}
	outgoingUsedCapacity::Array{Int64,1}
	outgoingTotalCapacity::Array{Int64,1}
end

function fromSource1(index::Int64,sources::Array{Source,1},visited::Array{Int64,1})
	#If we made it to the sink, return 0. We want to keep all flow here. It is optimal
	if index == length(sources) return 0 end

	#Mark this source as visited
	visited[index] += 1

	#Otherwise, iterate the outgoing of this node,
	#attempting to distribute all the flow
	currentSource = sources[index]
	for i = 1:length(currentSource.outgoingUsedCapacity)
		if visited[currentSource.outgoingIndex[i]] > 0 continue end #If we were here already during current flow cycle, continue
		if currentSource.flow > 0 && currentSource.outgoingUsedCapacity[i] < currentSource.outgoingTotalCapacity[i] #if we can still send flow through here

			#Get potential flow to be sent
			sentFlow = min(currentSource.flow,currentSource.outgoingTotalCapacity[i] - currentSource.outgoingUsedCapacity[i]) #Flow to send
			currentSource.flow -= sentFlow #Subtract it from current flow
			currentSource.outgoingUsedCapacity[i] += sentFlow #Add it to used capacity
			sources[currentSource.outgoingIndex[i]].flow += sentFlow  #Add it to flow for that next source

			#When we return with the excess
			for j = i+1:length(currentSource.outgoingTotalCapacity) visited[currentSource.outgoingIndex[j]] += 1 end
			excessFlow = fromSource1(currentSource.outgoingIndex[i],sources,visited)
			for j = i+1:length(currentSource.outgoingTotalCapacity) visited[currentSource.outgoingIndex[j]] -= 1 end

			currentSource.flow += excessFlow #Add it back to this sources flow
			currentSource.outgoingUsedCapacity[i] -= excessFlow #Subtract it from used capacity
		end
	end
	#Unmark this node as visited, and drain current source, and return its flow to previous
	visited[index] -= 1
	backFlow = currentSource.flow
	currentSource.flow = 0
	return backFlow
end

function fromSource2(index::Int64,sources::Array{Source,1},visited::Array{Int64,1})
	#If we made it to the sink, return 0. We want to keep all flow here. It is optimal
	if index == length(sources) return 0 end

	#Mark this source as visited
	visited[index] = 1

	#Otherwise, iterate the outgoing of this node,
	#attempting to distribute all the flow
	currentSource = sources[index]
	for i = 1:length(currentSource.outgoingUsedCapacity)
		if visited[currentSource.outgoingIndex[i]] == 1 continue end #If we were here already during current flow cycle, continue
		if currentSource.flow > 0 && currentSource.outgoingUsedCapacity[i] < currentSource.outgoingTotalCapacity[i] #if we can still send flow through here

			#Get potential flow to be sent
			sentFlow = min(currentSource.flow,currentSource.outgoingTotalCapacity[i] - currentSource.outgoingUsedCapacity[i]) #Flow to send
			currentSource.flow -= sentFlow #Subtract it from current flow
			currentSource.outgoingUsedCapacity[i] += sentFlow #Add it to used capacity
			sources[currentSource.outgoingIndex[i]].flow += sentFlow  #Add it to flow for that next source

			#When we return with the excess
			excessFlow = fromSource2(currentSource.outgoingIndex[i],sources,visited)

			currentSource.flow += excessFlow #Add it back to this sources flow
			currentSource.outgoingUsedCapacity[i] -= excessFlow #Subtract it from used capacity
		end
	end
	#Unmark this node as visited, and drain current source, and return its flow to previous
	visited[index] = 0
	backFlow = currentSource.flow
	currentSource.flow = 0
	return backFlow
end

function printPath(sources::Array{Source,1})
	for i = 1:length(sources)
		currentSource = sources[i]
		for j = 1:length(currentSource.outgoingUsedCapacity)
			if currentSource.outgoingUsedCapacity[j] > 0
				println("$i -> $(currentSource.outgoingIndex[j]): $(currentSource.outgoingUsedCapacity[j])")
			end
		end
	end
end

function maxFlow(sources::Array{Source,1})
	for i = 1:length(sources[1].outgoingTotalCapacity)
		sources[1].flow += sources[1].outgoingTotalCapacity[i]
	end

	visited = zeros(Int64,length(sources))
	sources[1].flow = fromSource1(1,sources,visited)
	fromSource2(1,sources,visited)
	maxflow = sources[length(sources)].flow

	println("The max flow is: $maxflow and the flows are...")
	printPath(sources)
end

#=s1 = Source(0,[2,3],[0,0],[16,13])
s4 = Source(0,[6,3],[0,0],[20,9])
s3 = Source(0,[2,5],[0,0],[4,14])
s5 = Source(0,[6,4],[0,0],[4,7])
s2 = Source(0,[4,3],[0,0],[12,10])
s6 = Source(0,[],[],[])=#
x = 1
a = 2
b = 3
c = 4
d = 5
e = 6
y = 7
sx = Source(0,[b,a],[0,0],[1,3])
sa = Source(0,[c],[0],[3])
sb = Source(0,[d,c],[0,0],[4,5])
sc = Source(0,[y],[0],[2])
sd = Source(0,[e],[0],[2])
se = Source(0,[y],[0],[3])
sy = Source(0,[],[],[])
sources = [sx,sa,sb,sc,sd,se,sy]
