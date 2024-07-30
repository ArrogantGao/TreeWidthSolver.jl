# listing all potential maximal cliques in a graph
# following the method provided in BouchitteÃ, Vincent, and Ioan Todinca. “Listing All Potential Maximal Cliques of a Graph.” Theoretical Computer Science, 2002.

function is_pmc(G::LabeledSimpleGraph{TG, TL, TW}, K::Set{TL}) where{TG, TL, TW}
    cs = components(G, K)
    if has_full_component(G, K, cs)
        return false
    end
    if !is_cliquish(G, K, cs)
        return false
    end
    return true
end

function has_full_component(G::LabeledSimpleGraph{TG, TL, TW}, K::Set{TL}, cs::Set{Set{TL}}) where{TG, TL, TW}
    for C in cs
        if is_full_component(G, K, C)
            return true
        end
    end
    return false
end

function is_cliquish(G::LabeledSimpleGraph{TG, TL, TW}, K::Set{TL}, cs::Set{Set{TL}}) where{TG, TL, TW}
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
    Π_1 = Set{Set{TL}}()

    for Ω_0 in Π_0
        cs_Ω = components(G_1, Ω_0)
        if has_full_component(G_1, Ω_0, cs_Ω)
            push!(Π_1, Ω_0 ∪ a)
        else
            push!(Π_1, Ω_0)
        end
    end

    for S in Δ_1
        if is_pmc(G_1, S ∪ a)
            push!(Π_1, S ∪ a)
        end
        if (a ∉ S) && (S ∉ Δ_0)
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

    vlist = [G.v2l[1]]
    G0 = induced_subgraph(G, vlist)

    Π_G1 = Set([Set(vlist[1])])
    Δ_G0 = Set{Set{TL}}()

    for i in 2:nv(G)
        a = collect(open_neighbors(G, vlist))[1]
        push!(vlist, a)
        G1 = induced_subgraph(G, vlist)
        Δ_G1 = all_min_sep(G1)
        Π_G1 = one_more_vertex(G1, G0, Π_G1, Δ_G1, Δ_G0)
        Δ_G0 = Δ_G1
        G0 = G1
    end

    return Π_G1
end

function push_new_pmc!(G::LabeledSimpleGraph{TG, TL, TW}, Π::Set{Set{TL}}, Ω::Set{TL}, ub::TW) where{TG, TL, TW}
    if clique_max(G, Ω) <= ub
        push!(Π, Ω)
    end
    nothing
end

function one_more_vertex_ub(
    G_1::LabeledSimpleGraph{TG, TL, TW}, # graph of n + 1 vertices
    G_0::LabeledSimpleGraph{TG, TL, TW}, # G / {a}
    Π_0::Set{Set{TL}}, # p.m.c of G_0
    Δ_1::Set{Set{TL}}, # m.s of G_1
    Δ_0::Set{Set{TL}}, # m.s of G_0
    ub::TW
    ) where{TG, TL, TW}

    a = collect(setdiff(keys(G_1.l2v), keys(G_0.l2v)))[1]
    Π_1 = Set{Set{TL}}()

    for Ω_0 in Π_0
        cs_Ω = components(G_1, Ω_0)
        if has_full_component(G_1, Ω_0, cs_Ω)
            push_new_pmc!(G_1, Π_1, Ω_0 ∪ a, ub)
        else
            push!(Π_1, Ω_0)
        end
    end

    for S in Δ_1
        Sa = S ∪ a
        if clique_max(G_1, Sa) <= ub
            if is_pmc(G_1, Sa)
                push!(Π_1, Sa)
            end
        end
        if (a ∉ S) && (S ∉ Δ_0)
            fcs = full_components(G_1, S)
            for T in Δ_1
                for C in fcs
                    t = S ∪ (T ∩ C)
                    if clique_max(G_1, t) <= ub
                        if is_pmc(G_1, t)
                            push!(Π_1, t)
                        end
                    end
                end
            end
        end
    end

    return Π_1
end

# ub is an given upper bound of the weight of a maximal clique
function all_pmc_ub(G::LabeledSimpleGraph{TG, TL, TW}, ub::TW) where{TG, TL, TW}

    vlist = [G.v2l[1]]
    G0 = induced_subgraph(G, vlist)

    Π_G1 = Set([Set(vlist[1])])
    Δ_G0 = Set{Set{TL}}()

    for i in 2:nv(G)
        @show ub, i, length(Π_G1)
        a = collect(open_neighbors(G, vlist))[1]
        push!(vlist, a)
        G1 = induced_subgraph(G, vlist)
        Δ_G1 = all_min_sep(G1)
        Π_G1 = one_more_vertex_ub(G1, G0, Π_G1, Δ_G1, Δ_G0, ub)
        Δ_G0 = Δ_G1
        G0 = G1
    end

    return Π_G1
end