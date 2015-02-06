### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Find the nearest node to a given location ###
function nearestNode{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T}, loc::T)
    min_dist = Inf
    best_ind = 0

    for (key, node) in nodes
        dist = distance(node, loc)
        if dist < min_dist
            min_dist = dist
            best_ind = key
        end
    end

    return best_ind
end

function nearestNode{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T},
                                         loc::T,
                                         node_list::Vector{Int})
    min_dist = Inf
    best_ind = 0

    for ind in node_list
        dist = distance(nodes[ind], loc)
        if dist < min_dist
            min_dist = dist
            best_ind = ind
        end
    end

    return best_ind
end

function nodesWithinRange{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T},
                                             loc::T,
                                             range::Float64=Inf)
    if range == Inf
        return keys(nodes)
    end
    indices = Int[]
    for (key, node) in nodes
        dist = distance(node, loc)
        if dist < range
            push!(indices, key)
        end
    end
    return indices
end

function nodesWithinRange{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T},
                                              loc::T,
                                              node_list::Vector{Int},
                                              range::Float64=Inf)
    if range == Inf
        return node_list
    end
    indices = Int[]
    for ind in node_list
        dist = distance(nodes[ind], loc)
        if dist < range
            push!(ind, key)
        end
    end
    return indices
end

### Add a new node ###
function addNewNode!{T<:Union(LLA,ENU)}(nodes::Dict{Int,T}, 
                                        loc::T, 
                                        start_id::Int=abs(int(hash(loc))) )
    id = start_id
    while id <= typemax(Int)
        if !haskey(nodes, id)
            nodes[id] = loc
            return id
        end
        id += 1
    end

    msg = "Unable to add new node to map, $(typemax(Int)) nodes is the current limit."
    throw(OverflowError(msg))
end

### Compute centroid of list of nodes ###
function centroid{T<:Union(LLA,ENU)}(nodes::Dict{Int,T}, node_list::Vector{Int})
    sum_1 = 0
    sum_2 = 0
    sum_3 = 0

    for k = 1:length(node_list)
        if typeof(nodes) == Dict{Int,LLA}
            sum_1 += nodes[node_list[k]].lat
            sum_2 += nodes[node_list[k]].lon
            sum_3 += nodes[node_list[k]].alt
        else
            sum_1 += nodes[node_list[k]].east
            sum_2 += nodes[node_list[k]].north
            sum_3 += nodes[node_list[k]].up
        end
    end

    if typeof(nodes) == Dict{Int,LLA}
        return LLA(sum_1/length(node_list),sum_2/length(node_list),sum_3/length(node_list))
    else
        return ENU(sum_1/length(node_list),sum_2/length(node_list),sum_3/length(node_list))
    end
end


