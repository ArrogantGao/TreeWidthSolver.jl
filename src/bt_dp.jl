# The Bouchitte-Todinca algorithm for computing the exact tree width of a given graph.
# References:
# Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
# Korhonen, Tuukka, Jeremias Berg, and Matti Järvisalo. “Solving Graph Problems via Potential Maximal Cliques: An Experimental Evaluation of the Bouchitté--Todinca Algorithm.” ACM Journal of Experimental Algorithmics 24 (December 17, 2019): 1–19. https://doi.org/10.1145/3301297.

struct TreeDecomposition{TW, TL}
    tw::TW
    treebags::Vector{Set{TL}}
end

function is_treedecomposition(G::LabeledSimpleGraph{TG, TL, TW}, td::TreeDecomposition{TW, TL}) where{TG, TL, TW}
    # all vertices in G are in some bag
    if Set(foldr(∪, collect.(td.treebags))) != Set(vertices(G))
        return false
    end

    # all edges in G are in some bag
    for (i, j) in edges(G)
        flag = false
        for Ω in td.treebags
            if (i in Ω && j in Ω)
                flag = true
            end
        end
        if !flag
            return false
        end
    end

    return true
end

function clique_f(G::LabeledSimpleGraph{TG, TL, TW}, W::Set{TL}) where {TG, TL, TW}
    fw = zero(TW)
    for l in W
        fw += G.l2w[l]
    end
    return fw - one(TW)
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
        cost = clique_f(G, Ω)

        g_new = induced_subgraph(G, collect(setdiff(C, Ω)))
        ccs = connected_components(g_new.graph)
        CS2 = [Set([g_new.v2l[v] for v in cc]) for cc in ccs]

        for C2 in CS2
            S2 = open_neighbors(G, C2)
            @assert is_min_sep(G, S2)
            cost = max(cost, dp[(S2, C2)])
        end
        if cost < dp[(S, C)]
            dp[(S, C)] = cost
            optChoice[(S, C)] = Ω
        end
    end

    # reconstrcution step
    tree_bags = Vector{Set{TL}}()
    Q = [(Set{TL}(), Set{TL}(vertices(G)))]
    while !isempty(Q)
        S, C = popfirst!(Q)
        Ω = optChoice[(S, C)]
        push!(tree_bags, Ω)

        g_new = induced_subgraph(G, collect(setdiff(C, Ω)))
        ccs = connected_components(g_new.graph)
        CS2 = Set([Set([g_new.v2l[v] for v in cc]) for cc in ccs])

        for C2 in CS2
            S2 = open_neighbors(G, C2)
            push!(Q, (S2, C2))
        end
    end

    return TreeDecomposition(dp[Set{TL}(), Set{TL}(vertices(G))], tree_bags)
end