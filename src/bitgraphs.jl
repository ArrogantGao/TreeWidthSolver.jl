using BitBasis, Graphs

function graph_from_tuples(n::Int, edgs)
    g = SimpleGraph(n)
    for (i, j) in edgs
        add_edge!(g, i, j)
    end
    g
end

function graph_from_gr(filename)
    open(filename, "r") do file
        line = readline(file)
        first_str, second_str, first_num, second_num = split(line)
        n = parse(Int64, first_num)
        graph = SimpleGraph(n)

        for line in eachline(file)
            v1, v2 = split(line)
            add_edge!(graph, parse(Int64, v1), parse(Int64, v2))
        end
        return graph
    end
end
    
mutable struct BitGraph{INT}
    N::Int # size of the graph
    bitgraph::Vector{INT} # store the adjacency matrix as vector of BitStr
    fadjlist::Vector{Vector{Int}} # store the adjacency list, informate of sparse graph
    mask::INT # mask for the graph
end

function BitGraph(g::SimpleGraph)
    N = nv(g)
    C = N ÷ 64 + 1
    INT = LongLongUInt{C}
    bitgraph = [bmask(INT, g.fadjlist[i]) for i in 1:N]
    mask = bmask(INT, 1:N)
    return BitGraph(N, bitgraph, deepcopy(g.fadjlist), mask)
end

function Graphs.nv(bg::BitGraph{INT}) where{INT}
    return count_ones(bg.mask)
end

Base.show(io::IO, bg::BitGraph{INT}) where {INT} = print(io, "BitGraph{$INT}, N: $(bg.N), nv: $(nv(bg)), mask: $(BitStr{bg.N}(bg.mask))")
Base.copy(bg::BitGraph{INT}) where{INT} = BitGraph(bg.N, copy(bg.bitgraph), deepcopy(bg.fadjlist), bg.mask)

# needed graph operations: neighbors, induced_subgraph, connected_components, 

function Graphs.neighbors(bg::BitGraph{INT}, v::Int) where{INT}
    return bg.bitgraph[v] & bg.mask
end

function closed_neighbors(bg::BitGraph{INT}, vs::INT) where{INT}
    nebis = zero(INT)
    for i in 1:bg.N
        iszero(readbit(vs, i)) && continue
        nebis |= bg.bitgraph[i]
    end
    return (nebis & bg.mask) | vs
end

function open_neighbors(bg::BitGraph{INT}, vs::INT) where{INT}
    nebis = zero(INT)
    for i in 1:bg.N
        iszero(readbit(vs, i)) && continue
        nebis |= bg.bitgraph[i]
    end
    return (nebis & bg.mask) & ~vs
end

function is_connected(bg::BitGraph{INT}, v::Int, u::Int) where{INT}
    @assert (readbit(bg.mask, v) == 1) && (readbit(bg.mask, u) == 1)
    return isone(readbit(bg.bitgraph[v], u))
end

function Graphs.add_edge!(bg::BitGraph{INT}, src::Int, dst::Int) where{INT}
    bg.bitgraph[src] = bg.bitgraph[src] | bmask(INT, dst)
    bg.bitgraph[dst] = bg.bitgraph[dst] | bmask(INT, src)
    push!(bg.fadjlist[src], dst)
    push!(bg.fadjlist[dst], src)
    nothing
end

# consider induced subgraph with mask
function Graphs.induced_subgraph(bg::BitGraph{INT}, vertices::INT) where{INT}
    sub_bg = copy(bg)
    sub_bg.mask = sub_bg.mask & vertices
    return sub_bg
end

# we actually need neighobors of connected components of the induced subgraph

# mask is a parameter, to aviod creating new bitgraph when considering induced subgraph
function Graphs.connected_components(bg::BitGraph{INT}; mask::INT = bg.mask) where{INT}
    comps = Vector{INT}()
    labels = ~mask

    for i in 1:bg.N
        readbit(bg.mask, i) == 0 && continue
        readbit(labels, i) != 0 && continue
        comp = bmask(INT, i)
        labels = labels | comp
        comp, labels = _connected_components(bg, comp, labels, i)
        push!(comps, comp & bg.mask)
    end
    return comps
end

function _connected_components(bg::BitGraph{INT}, comp::INT, labels::INT, i::Int) where{INT}
    active_nebis = (neighbors(bg, i) & ~labels)
    (active_nebis == 0) && return comp, labels
    comp = comp | active_nebis
    labels = labels | active_nebis
    for j in bg.fadjlist[i]
        (iszero(readbit(active_nebis, j))) &&  continue
        comp, labels = _connected_components(bg, comp, labels, j)
    end
    return comp, labels
end

function is_full_component(bg::BitGraph{INT}, S::INT, comp::INT; mask::INT = bg.mask) where{INT}
    return (open_neighbors(bg, comp) & mask) == S
end

function is_clique(bg::BitGraph{INT}, S::INT) where{INT}
    flag = S
    for i in 1:bg.N
        iszero(readbit(S, i)) && continue
        flag &= (bg.bitgraph[i] | bmask(INT, i))
    end
    return (flag & S) == S
end