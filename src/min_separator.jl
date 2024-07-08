function is_min_sep(G::LabeledSimpleGraph{TG, TL, TW}, S::Set{TL}) where{TG, TL, TW}
    flag = 0
    for C in components(G, S)
        if is_full_component(G, S, C)
            flag += 1
        end
    end
    return flag ≥ 2
end

function all_min_sep(G::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW}
    # initialization
    ΔT = Set{Set{TL}}()
    for v in vertices(G)
        close_neibs = closed_neighbors(G, [v])
        for C in components(G, close_neibs)
            ons = open_neighbors(G, C)
            if !isempty(ons)
                push!(ΔT, Set(ons))
            end
        end
    end

    # generation
    ΔS = Vector{Set{TL}}()
    while !isempty(setdiff(ΔT, ΔS))
        sd = setdiff(ΔT, ΔS)
        for S in sd
            for x in S
                for C in components(G, S ∪ neighbors(G, x))
                    push!(ΔT, Set(open_neighbors(G, C)))
                end
            end
            push!(ΔS, S)
        end
    end

    return ΔS
end
