"""
	exact_treewidth(g::SimpleGraph{TG}; weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW}

Compute the exact treewidth of a given graph `g` using the BT algorithm.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `weights::Vector{TW} = ones(nv(g))`: The weights of the vertices in the graph. Default is equal weights for all vertices.
- `verbose::Bool = false`: Whether to print verbose output. Default is `false`.

# Returns
- `tw`: The treewidth of the graph.

"""
function exact_treewidth(g::SimpleGraph{TG}; weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW}
	bg = MaskedBitGraph(g)
	Π = all_pmc_enmu(bg, verbose)
	td = bt_algorithm(bg, Π, weights, verbose, false)
	return td.tw
end

"""
	decomposition_tree(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW, TL}

Constructs a decomposition tree for a given simple graph `g`.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `labels::Vector{TL}`: (optional) The labels for the vertices of the graph. Default is `collect(1:nv(g))`.
- `weights::Vector{TW}`: (optional) The weights for the vertices of the graph. Default is `ones(nv(g))`.
- `verbose::Bool`: (optional) Whether to print verbose output. Default is `false`.

# Returns
- `TreeDecomposition`: The resulting decomposition tree, where treewidht is stored in `td.tw` and the tree is stored in `td.tree`.

"""
function decomposition_tree(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW, TL}
	bg = MaskedBitGraph(g)
	Π = all_pmc_enmu(bg, verbose)
	td = bt_algorithm(bg, Π, weights, verbose, true)
	labeled_tree = tree_labeling(td.tree, labels)
	return TreeDecomposition(td.tw, labeled_tree)
end

"""
    decomposition_tree(g::SimpleGraph{TG}, orders::Union{Vector{Vector{TE}}, Vector{TE}}; labels::Vector{TL} = [1:length(vertices(g))...]) where {TG, TE, TL}

Constructs a decomposition tree for a given simple graph `g` based on the provided orders.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `orders::Union{Vector{Vector{TE}}, Vector{TE}}`: The orders for constructing the decomposition tree. Can be a vector of vectors or a single vector.
- `labels::Vector{TL}`: (optional) The labels for the vertices of the graph. Default is `collect(1:nv(g))`.

# Returns
- `TreeDecomposition`: The resulting decomposition tree, where the tree is labeled according to the provided labels.

# Raises
- `AssertionError`: If the length of `new_orders` does not match the number of vertices in `g`, if `new_orders` contains duplicates, or if the length of `labels` does not match the length of `new_orders`.

"""
function decomposition_tree(g::SimpleGraph{TG}, orders::Union{Vector{Vector{TE}}, Vector{TE}}; labels::Vector{TL} = [1:length(vertices(g))...]) where {TG, TE, TL}

	new_orders = (orders isa Vector{Vector{TE}}) ? vcat(orders...) : orders
	@assert length(new_orders) == nv(g)
	@assert unique(new_orders) == new_orders
	@assert length(labels) == length(new_orders)

	labels_dict = Dict(labels[i] => i for i in 1:length(labels))
	int_orders = [labels_dict[i] for i in new_orders]

	tree = order2tree(int_orders, g)

	return tree_labeling(tree, labels)
end

"""
	elimination_order(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TL, TW}

Compute the elimination order of a graph `g` using the BT algorithm.

# Arguments
- `g::SimpleGraph{TG}`: The input graph.
- `labels::Vector{TL}`: (optional) Labels for the vertices of `g`. Default is `collect(1:nv(g))`.
- `weights::Vector{TW}`: (optional) Weights for the vertices of `g`. Default is `ones(nv(g))`.
- `verbose::Bool`: (optional) Whether to print verbose output. Default is `false`.

# Returns
- `labeled_eo::Vector{Vector{TL}}`: The elimination order of the graph `g`, where each vertex is labeled according to `labels`.

"""
function elimination_order(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TL, TW}
	td = decomposition_tree(g, labels = labels, weights = weights, verbose = verbose)
	eo = EliminationOrder(td.tree)
	return eo.order
end
