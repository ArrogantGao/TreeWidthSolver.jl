"""
    exact_treewidth(g::SimpleGraph{TG}; weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW}

Compute the exact treewidth of a given graph `g` using the BT algorithm.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `weights::Vector{TW} = ones(nv(g))`: The weights of the vertices in the graph. Default is equal weights for all vertices.
- `verbose::Bool = false`: Whether to print verbose output. Default is `false`.

# Returns
- `tw`: The treewidth of the graph.

"""
function exact_treewidth(g::SimpleGraph{TG}; weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW}
    bg = MaskedBitGraph(g)
    Π = all_pmc_enmu(bg, verbose)
    td = bt_algorithm(bg, Π, weights, verbose)
    return td.tw
end

"""
    elimination_order(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TL, TW}

Compute the elimination order of a graph `g` using the BT algorithm.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `labels::Vector{TL}`: (optional) Labels for the vertices of `g`. Default is `collect(1:nv(g))`.
- `weights::Vector{TW}`: (optional) Weights for the vertices of `g`. Default is `ones(nv(g))`.
- `verbose::Bool`: (optional) Whether to print verbose output. Default is `false`.

# Returns
- `labeled_eo::Vector{Vector{TL}}`: The elimination order of the graph `g`, where each vertex is labeled according to `labels`.

"""
function elimination_order(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TL, TW}
    bg = MaskedBitGraph(g)
    Π = all_pmc_enmu(bg, verbose)
    td = bt_algorithm(bg, Π, weights, verbose)
    eo = EliminationOrder(td.tree)
    labeled_eo = Vector{Vector{TL}}()
    for bag in eo.order
        push!(labeled_eo, labels[bag])
    end
    return labeled_eo
end