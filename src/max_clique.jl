# listing all potential maximal cliques in a graph
# following the method provided in BouchitteÃ, Vincent, and Ioan Todinca. “Listing All Potential Maximal Cliques of a Graph.” Theoretical Computer Science, 2002.

function is_pmc(G::LabeledSimpleGraph{TG, TL, TW}, K::Set{TL}) where{TG, TL, TW}
    cs = components(G, K)
    for C in cs
        if is_full_component(G, K, C)
            return false
        end
    end

    GSGKK = copy(G)
    for C in cs
        neibs_c = open_neighbors(G, C)
        @assert neibs_c ⊆ K
        complete!(GSGKK, neibs_c)
    end

    if is_clique(GSGKK, K)
        return true
    else
        return false
    end
end

function all_pmc_naive(G::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW}
    Π = Set{Set{TL}}()
    for sets in combinations(collect(keys(G.l2v)))
        K = Set(sets)
        if is_pmc(G, K)
            push!(Π, K)
        end
    end
    return Π
end

function one_more_vertex(
    G_1::LabeledSimpleGraph{TG, TL, TW}, # graph of n + 1 vertices
    G_0::LabeledSimpleGraph{TG, TL, TW}, # G / {a}
    Π_0::Set{Set{TL}}, # p.m.c of G_0
    Δ_1::Set{Set{TL}}, # m.s of G_1
    Δ_0::Set{Set{TL}} # m.s of G_0
    ) where{TG, TL, TW}

    a = collect(setdiff(keys(G_1.l2v), keys(G_0.l2v)))[1]
    Π_1 = Set{Set{Int}}()

    for Ω_0 in Π_0
        if is_pmc(G_1, Ω_0)
            push!(Π_1, Ω_0)
        elseif is_pmc(G_1, Ω_0 ∪ a)
            push!(Π_1, Ω_0 ∪ a)
        end
    end

    for S in Δ_1
        if is_pmc(G_1, S ∪ a)
            push!(Π_1, S ∪ a)
        end
        # if (a ∉ S) && (S ∉ Δ_0)
        if (S ∉ Δ_0)
            fcs = full_components(G_1, S)
            for T in Δ_1
                for C in fcs
                    t = S ∪ (T ∩ C)
                    if is_pmc(G_1, t)
                        push!(Π_1, t)
                    end
                end
            end
        end
    end

    return Π_1
end

function all_pmc(G::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW}

    Π_G1 = Set([Set(one(TL))])
    Δ_G0 = Set{Set{TL}}()

    G0 = induced_subgraph(G, [1])
    for i in 2:nv(G)
        G1 = induced_subgraph(G, [1:i...])
        Δ_G1 = all_min_sep(G1)
        # @show Δ_G1
        Π_G1 = one_more_vertex(G1, G0, Π_G1, Δ_G1, Δ_G0)
        # @show Π_G1
        Δ_G0 = Δ_G1
        G0 = G1
    end

    return Π_G1
end