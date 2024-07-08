# listing all potentail maximal cliques in a graph

function is_pmc(G::LabeledSimpleGraph{TG, TL, TW}, K::Set{TL}) where{TG, TL, TW}
    cs = components(G, K)
    for C in cs
        if is_full_component(G, K, C)
            return false
        end
    end

    GSK
    if is_clique(GSΩ, K)
        return false
    end

    return true
end

function one_more_vetrex(
    G_1::LabeledSimpleGraph{TG, TL, TW}, # graph of n + 1 vertices
    # G_0::SimpleGraph{Int}, # graph of n vertices
    Π_0::Set{Set{TL}}, # p.m.c of G_0
    Δ_1::Set{Set{TL}}, # m.s of G_1
    Δ_0::Set{Set{TL}} # m.s of G_0
    ) where{TG, TL, TW}

    a = nv(G_1)
    Π_1 = Set{Set{Int}}()

    for Ω_0 in Π_0
        if is_pmc(Ω_0, G_1)
            push!(Π_1, Ω_0)
        elseif is_pmc(Ω_0 ∪ a, G_1)
            push!(Π_1, Ω_0 ∪ a)
        end
    end

    for S in Δ_1
        if is_pmc(S ∪ a, G_1)
            push!(Π_1, S ∪ a)
        end
        if (a ∉ S) && (S ∉ Δ_0)
            full_components = full_component(S, G_1)
            for C in full_components, T in Δ_1
                t = S ∪ (T ∩ C)
                if is_pmc(t, G_1)
                    push!(Π_1, t)
                end
            end
        end
    end

    return Π_1
end

function all_pmc(G::SimpleGraph{Int})

    Π_Gi = Set([Set(One(Int))])
    Δ_G0 = Set(Set{T})()
    for i in 2:nv(G)
        Gi = induced_subgraph(G, [1:i...])
        Δ_Gi = all_min_sep(Gi)
        Π_Gi = one_more_vetrex(Gi, Π_Gi, Δ_G0, Δ_Gi)
        Δ_G0 = Δ_Gi
    end

    return Δ_G0, Π_Gi
end