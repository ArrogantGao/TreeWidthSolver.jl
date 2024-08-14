"""
    mutable struct MaskedBitGraph{INT}

A mutable struct representing a masked bit graph.

# Fields
- `MaskedBitGraph::Vector{INT}`: Stores the adjacency matrix as a vector of BitStr.
- `fadjlist::Vector{Vector{Int}}`: Stores the adjacency list, providing information about the sparse graph.
- `mask::INT`: The mask for the graph.

"""
mutable struct MaskedBitGraph{INT}
    bitgraph::Vector{INT} # store the adjacency matrix as vector of BitStr
    fadjlist::Vector{Vector{Int}} # store the adjacency list, informate of sparse graph
    mask::INT # mask for the graph
end

function MaskedBitGraph(g::SimpleGraph)
    N = nv(g)
    INT = LongLongUInt{N ÷ 64 + 1}
    bitgraph = [bmask(INT, g.fadjlist[i]) for i in 1:N]
    mask = bmask(INT, 1:N)
    return MaskedBitGraph(bitgraph, deepcopy(g.fadjlist), mask)
end

function Graphs.nv(bg::MaskedBitGraph{INT}) where{INT}
    return count_ones(bg.mask)
end

N(bg::MaskedBitGraph{INT}) where{INT} = length(bg.bitgraph)

Base.show(io::IO, bg::MaskedBitGraph{INT}) where {INT} = print(io, "MaskedBitGraph{$INT}, N: $(N(bg)), nv: $(nv(bg)), mask: $(BitStr{N(bg)}(bg.mask))")
Base.copy(bg::MaskedBitGraph{INT}) where{INT} = MaskedBitGraph(copy(bg.bitgraph), deepcopy(bg.fadjlist), bg.mask)

function Graphs.neighbors(bg::MaskedBitGraph{INT}, v::Int) where{INT}
    bit_nebi = bit_neighbors(bg, v)
    return bit2id(bit_nebi, N(bg))
end

function bit_neighbors(bg::MaskedBitGraph{INT}, v::Int) where{INT}
    return bg.bitgraph[v] & bg.mask
end

function closed_neighbors(bg::MaskedBitGraph{INT}, vs::INT) where{INT}
    nebis = zero(INT)
    for i in 1:N(bg)
        iszero(readbit(vs, i)) && continue
        nebis |= bg.bitgraph[i]
    end
    return (nebis & bg.mask) | vs
end

function open_neighbors(bg::MaskedBitGraph{INT}, vs::INT) where{INT}
    nebis = zero(INT)
    for i in 1:N(bg)
        iszero(readbit(vs, i)) && continue
        nebis |= bg.bitgraph[i]
    end
    return (nebis & bg.mask) & ~vs
end

function Graphs.has_edge(bg::MaskedBitGraph{INT}, v::Int, u::Int) where{INT}
    @assert (readbit(bg.mask, v) == 1) && (readbit(bg.mask, u) == 1)
    return isone(readbit(bg.bitgraph[v], u))
end

function Graphs.add_edge!(bg::MaskedBitGraph{INT}, src::Int, dst::Int) where{INT}
    bg.bitgraph[src] = bg.bitgraph[src] | bmask(INT, dst)
    bg.bitgraph[dst] = bg.bitgraph[dst] | bmask(INT, src)
    push!(bg.fadjlist[src], dst)
    push!(bg.fadjlist[dst], src)
    nothing
end

# consider induced subgraph with mask
function bit_induced_subgraph(bg::MaskedBitGraph{INT}, vertices::INT) where{INT}
    sub_bg = copy(bg)
    sub_bg.mask = sub_bg.mask & vertices
    return sub_bg
end

# we actually need neighobors of connected components of the induced subgraph

# mask is a parameter, to aviod creating new MaskedBitGraph when considering induced subgraph
function bit_connected_components(bg::MaskedBitGraph{INT}; mask::INT = bg.mask) where{INT}
    comps = Vector{INT}()
    labels = ~mask

    for i in 1:N(bg)
        readbit(bg.mask, i) == 0 && continue
        readbit(labels, i) != 0 && continue
        comp = bmask(INT, i)
        labels = labels | comp
        comp, labels = _bit_connected_components(bg, comp, labels, i)
        push!(comps, comp & bg.mask)
    end
    return comps
end

function _bit_connected_components(bg::MaskedBitGraph{INT}, comp::INT, labels::INT, i::Int) where{INT}
    active_nebis = (bit_neighbors(bg, i) & ~labels)
    (active_nebis == 0) && return comp, labels
    comp = comp | active_nebis
    labels = labels | active_nebis
    for j in bg.fadjlist[i]
        (iszero(readbit(active_nebis, j))) &&  continue
        comp, labels = _bit_connected_components(bg, comp, labels, j)
    end
    return comp, labels
end

function is_full_component(bg::MaskedBitGraph{INT}, S::INT, comp::INT; mask::INT = bg.mask) where{INT}
    return (open_neighbors(bg, comp) & mask) == S
end

function is_clique(bg::MaskedBitGraph{INT}, S::INT) where{INT}
    flag = S
    for i in 1:N(bg)
        iszero(readbit(S, i)) && continue
        flag &= (bg.bitgraph[i] | bmask(INT, i))
    end
    return (flag & S) == S
end

function full_components(bg::MaskedBitGraph{INT}, S::INT) where{INT}
    comps = bit_connected_components(bg, mask = ~S & bg.mask)
    return [comp for comp in comps if is_full_component(bg, S, comp)]
end

function res_components(bg::MaskedBitGraph{INT}, C::INT, Ω::INT) where{INT}
    mask = C & ~Ω
    ccs = bit_connected_components(bg, mask = mask)
    return ccs
end
