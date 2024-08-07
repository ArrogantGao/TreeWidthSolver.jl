# The Bouchitte-Todinca algorithm for computing the exact tree width of a given graph.
# References:
# Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
# Korhonen, Tuukka, Jeremias Berg, and Matti Järvisalo. “Solving Graph Problems via Potential Maximal Cliques: An Experimental Evaluation of the Bouchitté--Todinca Algorithm.” ACM Journal of Experimental Algorithmics 24 (December 17, 2019): 1–19. https://doi.org/10.1145/3301297.

struct TreeDecomposition{TW, TL}
    tw::TW
    tree::DecompositionTreeNode{TL}
end

function Base.show(io::IO, td::TreeDecomposition)
    print(io, "tree width: $(td.tw)\n", "tree decomposition:\n$(td.tree)")
end

function is_treedecomposition(G::LabeledSimpleGraph{TG, TL, TW}, td::TreeDecomposition{TW, TL}) where{TG, TL, TW}
    treebags = [node.bag for node in collect(PreOrderDFS(td.tree))]

    # all vertices in G are in some bag
    if Set(foldr(∪, collect.(treebags))) != Set(vertices(G))
        return false
    end

    # all edges in G are in some bag
    for (i, j) in edges(G)
        flag = false
        for Ω in treebags
            if (i in Ω && j in Ω)
                flag = true
            end
        end
        if !flag
            return false
        end
    end

    # all treebags containing the same vertex form a connected subtree
    eo = vcat(EliminationOrder(td.tree).order...)
    if (length(eo) != nv(G)) || (unique(eo) != eo)
        return false
    end

    return true
end

function clique_max(G::LabeledSimpleGraph{TG, TL, TW}, W::Set{TL}) where {TG, TL, TW}
    fw = zero(TW)
    for l in W
        fw += G.l2w[l]
    end
    return fw - one(TW)
end

function res_components(G::LabeledSimpleGraph{TG, TL, TW}, C::Set{TL}, Ω::Set{TL}) where {TG, TL, TW}

    g_new = induced_subgraph(G, collect(setdiff(C, Ω)))
    ccs = connected_components(g_new.graph)
    CS2 = [Set([g_new.v2l[v] for v in cc]) for cc in ccs]

    return CS2
end

# The BT-DP algorithm for computing the exact tree width of a given graph
function BTDP_exact_tw(G::LabeledSimpleGraph{TG, TL, TW}, Π::Set{Set{TL}}) where{TG, TL, TW}

    # precomputation phase
    T = Vector{Tuple{Set{TL}, Set{TL}, Set{TL}}}()
    for Ω in Π
        push!(T, (Ω, Set{TL}(), Set{TL}(vertices(G))))
        for D in components(G, Ω)
            S = Set{TL}(open_neighbors(G, D))
            for C in full_components(G, S)
                if (Ω ⊆ S ∪ C) && (S ⊊ Ω)
                    push!(T, (Ω, S, C))
                end
            end
        end
    end

    unique!(T)
    sort!(T, by = x -> length(x[2]) + length(x[3]))

    # dynamic programing phase
    dp = Dict{Tuple{Set{TL}, Set{TL}}, TW}()
    optChoice = Dict{Tuple{Set{TL}, Set{TL}}, Set{TL}}()
    for t in T
        Ω, S, C = t
        dp[(S, C)] = typemax(TW)
    end

    for t in T
        Ω, S, C = t
        cost = clique_max(G, Ω)

        CS2 = res_components(G, C, Ω)
        for C2 in CS2
            S2 = open_neighbors(G, C2)
            cost = max(cost, dp[(S2, C2)])
        end
        if cost < dp[(S, C)]
            dp[(S, C)] = cost
            optChoice[(S, C)] = Ω
        end
    end

    # reconstrcution step
    tree = construct_tree(G, optChoice)
    tw = dp[(Set{TL}(), Set{TL}(vertices(G)))]
    return TreeDecomposition(tw, tree)
end

function construct_tree(G::LabeledSimpleGraph{TG, TL, TW}, optChoice::Dict{Tuple{Set{TL}, Set{TL}}, Set{TL}}) where{TG, TL, TW}
    S0, C0 = Set{TL}(), Set{TL}(vertices(G))
    Ω0 = optChoice[(S0, C0)]
    root_node = DecompositionTreeNode(Ω0)
    _construct_tree!(root_node, optChoice, G, C0)
    return root_node
end

function _construct_tree!(node::DecompositionTreeNode{TL}, optChoice::Dict{Tuple{Set{TL}, Set{TL}}, Set{TL}}, G::LabeledSimpleGraph{TG, TL, TW}, C::Set{TL}) where{TG, TL, TW}
    Ω = node.bag
    CS2 = res_components(G, C, Ω)
    for C2 in CS2
        S2 = open_neighbors(G, C2)
        Ω2 = optChoice[(S2, C2)]
        add_child!(node, Ω2)
        _construct_tree!(node.children[end], optChoice, G, C2)
    end
    return nothing
end

function exact_treewidth(G::LabeledSimpleGraph{TG, TL, TW}) where {TG, TL, TW}
    Π = all_pmc(G)
    td = BTDP_exact_tw(G, Π)
    return td
end