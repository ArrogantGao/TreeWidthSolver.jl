# listing all potential maximal cliques in a graph
# following the method provided in BouchitteÃ, Vincent, and Ioan Todinca. “Listing All Potential Maximal Cliques of a Graph.” Theoretical Computer Science, 2002.

function has_full_component(bg::BitGraph{INT}, S::INT, comps::Vector{INT}) where{INT}
    for comp in comps
        if is_full_component(bg, S, comp)
            return true
        end
    end
    return false
end

function is_cliquish(bg::BitGraph{INT}, S::INT, comps::Vector{INT}) where{INT}
    vs = bit2id(S, N = bg.N)
    new_bitgraph = copy(bg.bitgraph)
    for v in vs
        new_bitgraph[v] |= bmask(INT, v)
    end

    for comp in comps
        ons = open_neighbors(bg, comp)
        vons = bit2id(ons, N = bg.N)
        for i in vons
            new_bitgraph[i] |= ons
        end
    end
    new_S = reduce((x, y) -> x & y, new_bitgraph[vs], init = S)
    return (new_S == S)
end

function is_pmc(bg::BitGraph{INT}, S::INT) where{INT}
    comps = connected_components(bg, mask = (~S & bg.mask))
    if has_full_component(bg, S, comps)
        return false
    else
        return is_cliquish(bg, S, comps)
    end
end

function all_pmc_naive(bg::BitGraph{INT}) where{INT}
    Π = Vector{INT}()
    for sets in combinations(1:bg.N)
        S = bmask(INT, sets)
        is_pmc(bg, S) && push!(Π, S)
    end
    return Π
end

function vertex_order!(bg::BitGraph{INT}, vo::Vector{Int}) where{INT}
    nebis = open_neighbors(bg, bmask(INT, vo))
    for nebi in 1:bg.N
        iszero(readbit(nebis, nebi)) && continue
        if nebi ∉ vo
            push!(vo, nebi)
            return vertex_order!(bg, vo)
        end
    end
    return vo
end

function extend_Π!(Π::Vector{INT}, Πi::Vector{INT}, vo::Vector{Int}, bg::BitGraph{INT}) where{INT}
    cbg = copy(bg)
    for Ω in Πi
        for i in 1:length(vo)
            removed_vertex = length(vo) == i ? zero(INT) : bmask(INT, vo[i + 1:end])
            cbg.mask = ~removed_vertex & bg.mask
            comps = connected_components(cbg, mask = cbg.mask & ~Ω)
            has_full_component(cbg, Ω, comps) && (Ω |= bmask(INT, vo[i]))
        end
        push!(Π, Ω)
    end
    return Π
end

function all_pmc_enmu(bg::BitGraph{INT}; vo::Vector{Int} = vertex_order!(bg, Int[1])) where{INT}
    Δ = all_min_sep(bg)
    # @show bit2id.(Δ)
    # @show vo
    Π = Vector{INT}()

    bg0 = copy(bg)
    for i in 1:bg.N - 1
        Πi = Vector{INT}()
        a = vo[i]
        bmask_a = bmask(INT, a)
        ΔT = Vector{INT}()
        ΔN = Vector{INT}()
        ΔS = Vector{INT}()
        for S in Δ
            if readbit(S, a) == 1
                push!(ΔT, S & ~bmask_a)
            elseif is_min_sep(bg0, S, mask = bg.mask & ~bmask(INT, vo[1:i]))
                push!(ΔN, S)
            else
                push!(ΔS, S)
            end
        end

        # println("vertices: $(bg.N - i), ΔT: $(length(ΔT)), ΔN: $(length(ΔN)), ΔS: $(length(ΔS))")

        for S in ΔN ∪ ΔS
            is_pmc(bg0, S | bmask_a) && push!(Πi, S | bmask_a)
        end

        for S in ΔS, T in ΔT
            Sn = S | T
            is_pmc(bg0, Sn) && push!(Πi, Sn)
        end

        extend_Π!(Π, Πi, vo[i - 1:-1:1], bg)

        Δ = ΔT ∪ ΔN
        bg0.mask = bg.mask & ~bmask(INT, vo[1:i])
    end
    extend_Π!(Π, [bmask(INT, vo[end])], vo[end-1:-1:1], bg)
    return unique!(Π)
end

# the original version by bt
function one_more_vertex(G_1::BitGraph{INT}, G_0::BitGraph{INT}, Π_0::Vector{INT}, Δ_1::Vector{INT}, Δ_0::Vector{INT}) where{INT}
    bmask_a = G_1.mask & ~G_0.mask
    a = bit2id(bmask_a, N = bg.N)[1]

    Π_1 = Vector{INT}()
    SΔ_0 = Set(Δ_0)

    for Ω_0 in Π_0
        cs_Ω = connected_components(G_1, mask = ~Ω_0 & G_1.mask)
        if has_full_component(G_1, Ω_0, cs_Ω)
            push!(Π_1, Ω_0 | bmask_a)
        else
            push!(Π_1, Ω_0)
        end
    end

    for S in Δ_1
        if is_pmc(G_1, S | bmask_a)
            push!(Π_1, S | bmask_a)
        end
        if (readbit(S, a) == 0) && (S ∉ SΔ_0)
            fcs = connected_components(G_1, mask = ~S & G_1.mask)
            for T in Δ_1
                for C in fcs
                    t = S | (T & C)
                    if is_pmc(G_1, t)
                        push!(Π_1, t)
                    end
                end
            end
        end
    end

    return Π_1
end

function all_pmc_bt(bg::BitGraph{INT}) where{INT}
    vo = vertex_order!(bg, Int[1]) # order to remove vertices from the graph, starting from 1, keep the graph connected
    G0 = induced_subgraph(bg, bmask(INT, vo[1:1]))

    Π_G1 = [bmask(INT, vo[1])]
    Δ_G0 = Vector{INT}()

    for i in 2:bg.N
        G1 = induced_subgraph(bg, bmask(INT, vo[1:i]))
        Δ_G1 = all_min_sep(G1)
        Π_G1 = one_more_vertex(G1, G0, Π_G1, Δ_G1, Δ_G0)
        Δ_G0 = Δ_G1
        G0 = G1
    end

    return unique!(Π_G1)
end