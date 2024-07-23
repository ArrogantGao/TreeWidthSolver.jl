# generating all minimum separators of a given simple graph
# following the method provided in Berry, Anne, Jean-Paul Bordat, and Olivier Cogis. “Generating All the Minimal Separators of a Graph.” In Graph-Theoretic Concepts in Computer Science, edited by Peter Widmayer, Gabriele Neyer, and Stephan Eidenbenz, 1665:167–72. Lecture Notes in Computer Science. Berlin, Heidelberg: Springer Berlin Heidelberg, 1999. https://doi.org/10.1007/3-540-46784-X_17.

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
    for S in ΔT
        push!(ΔS, S)
    end

    while !isempty(ΔS)
        S = pop!(ΔS)
        RS = Set{TL}[]
        for x in S
            for C in components(G, S ∪ neighbors(G, x))
                push!(RS, Set(open_neighbors(G, C)))
            end
        end

        for rs in RS
            if rs ∉ ΔT
                push!(ΔT, rs)
                push!(ΔS, rs)
            end
        end
    end

    return ΔT
end
