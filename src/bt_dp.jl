# The Bouchitte-Todinca algorithm for computing the exact tree width of a given graph.
# References:
# Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
# Master thesis by Tuukka Korhonen: http://tuukkakorhonen.com/papers/msc-thesis.pdf

function clique_f(G::LabeledSimpleGraph{TG, TL, TW}, W::Set{TL}) where {TG, TL, TW}
    fw = zero(TW)
    for l in W
        fw += G.l2w[l]
    end
    return fw - one(TW)
end

# the Bouchitte-Todinca dynamic programing algorithm for computing the exact tree width of a given graph
function BTDP_exact_tw(G::LabeledSimpleGraph{TG, TL, TW}, Π::Set{Set{TL}}) where{TG, TL, TW}

    # precomputation phase
    B = Block{TL}[]
    push!(B, Block(Set{TL}(), Set{TL}(vertices(G))))
    AΩ = Dict{Set{TL}, Vector{Block{TL}}}()
    for Ω in Π
        AΩ[Ω] = Block{TL}[]
        for C in components(G, Ω)
            S = Set{TL}(open_neighbors(G, C))
            push!(AΩ[Ω], Block(S, C))
            push!(B, Block(S, C))
        end
    end

    # it seems that the Block type can not be used as a key in a dictionary, use tuple instead
    ΠSC = Dict{Tuple{Set{TL}, Set{TL}}, Vector{Set{TL}}}()

    b0 = Block(Set{TL}(), Set{TL}(vertices(G)))
    tb0 = block2tuple(b0)
    ΠSC[tb0] = Vector{Set{TL}}()

    for Ω in Π
        push!(ΠSC[tb0], Ω)
        for D in components(G, Ω)
            for C in full_components(G, open_neighbors(G, D))
                if !isempty(intersect(C, Ω))
                    b = Block(Set{TL}(open_neighbors(G, C)), C)
                    tb = block2tuple(b)
                    if haskey(ΠSC, tb)
                        push!(ΠSC[tb], Ω)
                    else
                        ΠSC[tb] = Vector{Set{TL}}()
                        push!(ΠSC[tb], Ω)
                    end
                end
            end
        end
    end

    # Dynamic programing phase
    sort!(B, by = x -> total_length(x))

    dp = Dict{Tuple{Set{TL}, Set{TL}}, TW}()
    optChoice = Dict{Tuple{Set{TL}, Set{TL}}, Set{TL}}()
    for b in B
        tb = block2tuple(b)
        dp[tb] = typemax(TW) # use typemax to represent infinity
        for Ω in ΠSC[tb]
            cost = clique_f(G, Ω)
            for bi in AΩ[Ω]
                if (bi.component ⊆ b.component) && (b ≠ bi)
                    tbi = block2tuple(bi)
                    cost = max(cost, dp[tbi])
                end
            end
            if cost < dp[tb]
                dp[tb] = cost
                optChoice[tb] = Ω
            end
        end
    end

    # the construction phase
    tree_bags = Vector{Set{TL}}()
    Q = [b0]
    while !isempty(Q)
        b = popfirst!(Q)
        tb = block2tuple(b)
        Ω = optChoice[tb]
        push!(tree_bags, Ω)
        for bi in AΩ[Ω]
            if (bi.component ⊆ b.component) && (b ≠ bi)
                push!(Q, bi)
            end
        end
    end

    return dp[tb0], tree_bags
end