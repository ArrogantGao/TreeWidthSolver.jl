# The Bouchitte-Todinca algorithm for computing the exact tree width of a given graph.
# References:
# Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
# Korhonen, Tuukka, Jeremias Berg, and Matti Järvisalo. “Solving Graph Problems via Potential Maximal Cliques: An Experimental Evaluation of the Bouchitté--Todinca Algorithm.” ACM Journal of Experimental Algorithmics 24 (December 17, 2019): 1–19. https://doi.org/10.1145/3301297.

# total weights of a tree bag
function clique_width(S::INT, weights::Vector{TW}) where {INT, TW}
    fw = zero(TW)
    for i in 1:length(weights)
        readbit(S, i) == 1 && (fw += weights[i])
    end
    return fw - one(TW)
end

# weights are the log2 dims of the indices
function bt_algorithm(bg::MaskedBitGraph{INT}, Π::Vector{INT}, weights::Vector{TW}, verbose::Bool, construct::Bool) where{INT, TW}

    verbose && @info "computing the exact treewidth using the Bouchitté-Todinca algorithm"
    verbose && @info "precomputation phase"
    # precomputation phase
    T = Vector{Tuple{INT, INT, INT}}()
    for Ω in Π
        push!(T, (Ω, zero(INT), bg.mask))
        for D in bit_connected_components(bg, mask = ~Ω & bg.mask)
            S = open_neighbors(bg, D)
            for C in full_components(bg, S)
                if ((Ω | (S | C)) == (S | C)) && ((S | Ω) == Ω) && (S ≠ Ω)
                    push!(T, (Ω, S, C))
                end
            end
        end
    end

    unique!(T)
    sort!(T, by = x -> count_ones(x[2]) + count_ones(x[3]))

    verbose && @info "precomputation phase completed, total: $(length(T))"

    # dynamic programing phase
    dp = Dict{Tuple{INT, INT}, TW}()
    optChoice = Dict{Tuple{INT, INT}, INT}()
    for t in T
        Ω, S, C = t
        dp[(S, C)] = typemax(TW)
    end

    lengthT = length(T)
    for (i, t) in enumerate(T)
        Ω, S, C = t
        cost = clique_width(Ω, weights)

        CS2 = res_components(bg, C, Ω)
        for C2 in CS2
            S2 = open_neighbors(bg, C2)
            cost = max(cost, dp[(S2, C2)])
        end
        if cost < dp[(S, C)]
            dp[(S, C)] = cost
            optChoice[(S, C)] = Ω
        end
    end

    tw = dp[(bmask(INT, 0), bg.mask)]

    verbose && @info "computing the exact treewidth done, treewidth: $tw"
    !construct && return TreeDecomposition(tw, DecompositionTreeNode(Set{Int}()))

    verbose && @info "reconstruction phase"
    # reconstrcution step
    tree = construct_tree(bg, optChoice)
    verbose && @info "reconstruction phase done"

    return TreeDecomposition(tw, tree)
end

function construct_tree(bg::MaskedBitGraph{INT}, optChoice::Dict{Tuple{INT, INT}, INT}) where{INT}
    Ω0 = optChoice[(bmask(INT, 0), bg.mask)]
    root_node = DecompositionTreeNode(bit2id(Ω0, N(bg)))
    _construct_tree!(root_node, Ω0, optChoice, bg, bg.mask)
    return root_node
end

function _construct_tree!(node::DecompositionTreeNode{Int}, bag::INT, optChoice::Dict{Tuple{INT, INT}, INT}, bg::MaskedBitGraph{INT}, C::INT) where{INT}
    Ω = bag
    CS2 = res_components(bg, C, Ω)
    for C2 in CS2
        S2 = open_neighbors(bg, C2)
        Ω2 = optChoice[(S2, C2)]
        add_child!(node, bit2id(Ω2, N(bg)))
        _construct_tree!(node.children[end], Ω2, optChoice, bg, C2)
    end
    return nothing
end