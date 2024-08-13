# generating all minimum separators of a given simple graph
# following the method provided in Berry, Anne, Jean-Paul Bordat, and Olivier Cogis. “Generating All the Minimal Separators of a Graph.” In Graph-Theoretic Concepts in Computer Science, edited by Peter Widmayer, Gabriele Neyer, and Stephan Eidenbenz, 1665:167–72. Lecture Notes in Computer Science. Berlin, Heidelberg: Springer Berlin Heidelberg, 1999. https://doi.org/10.1007/3-540-46784-X_17.

function is_min_sep(bg::BitGraph{INT}, S::INT; mask::INT = bg.mask) where{INT}
    flag = 0
    comps = connected_components(bg, mask = (mask & ~S))
    for comp in comps
        if is_full_component(bg, S, comp, mask = mask)
            flag += 1
        end
    end
    return flag ≥ 2
end

function all_min_sep_naive(bg::BitGraph{INT}) where{INT}
    Δ = Vector{INT}()
    for sets in combinations(1:bg.N)
        S = bmask(INT, sets)
        is_min_sep(bg, S) && push!(Δ, S)
    end
    return Δ
end

function all_min_sep(bg::BitGraph{INT}, verbose::Bool) where{INT}
    verbose && @info "computing all minimal separators"

    # initialization
    ΔT = Vector{INT}()

    for v in 1:bg.N
        (readbit(bg.mask, v) == 0) && continue
        close_neibs = neighbors(bg, v) | bmask(INT, v)
        for comp in connected_components(bg, mask = ~close_neibs)
            ons = open_neighbors(bg, comp)
            if (ons != 0) && (ons ∉ ΔT)
                push!(ΔT, ons)
            end
        end
    end

    # it seems that SortedSet is not as good as Set
    # ΔS = SortedSet(ΔT)
    ΔS = Set(ΔT)

    i = 1
    while i ≤ length(ΔT)

        (verbose && (i%10000 == 0 || (i < 10000 && i%1000 ==0) || (i < 1000 && i%100==0) || (i<100 && i%10==0))) && @info "allminseps: $i, $(length(ΔT))"

        S = ΔT[i]
        RS = Vector{INT}()
        for x in 1:bg.N
            iszero(readbit(S, x)) && continue
            for comp in connected_components(bg, mask = ~(S | neighbors(bg, x)))
                push!(RS, open_neighbors(bg, comp))
            end
        end

        for rs in RS
            if rs ∉ ΔS
                push!(ΔS, rs)
                push!(ΔT, rs)
            end
        end
        i += 1
    end

    verbose && @info "all minimal separators computed, total: $(length(ΔT))"

    return ΔT
end