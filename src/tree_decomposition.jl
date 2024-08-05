using AbstractTrees

mutable struct DecompositionTreeNode{T}
    bag::Set{T}
    parent::Union{DecompositionTreeNode{T}, Nothing}
    children::Vector{DecompositionTreeNode{T}}

    function DecompositionTreeNode(bag::Set{T}, p = nothing, c = Vector{DecompositionTreeNode{T}}()) where T
        new{T}(bag, p, c)
    end
end

DecompositionTreeNode(bag::Vector{T}) where T = DecompositionTreeNode(Set(bag), nothing, Vector{DecompositionTreeNode{T}}())

Base.:(==)(n1::DecompositionTreeNode{T}, n2::DecompositionTreeNode{T}) where {T} = (n1.bag == n2.bag) && (n1.children == n2.children)

function add_child!(parent::DecompositionTreeNode{T}, bag::Union{Set{T}, Vector{T}}) where T
    node = DecompositionTreeNode(Set(bag), parent, Vector{DecompositionTreeNode{T}}())
    push!(parent.children, node)
    nothing
end

function AbstractTrees.children(node::DecompositionTreeNode{T}) where{T}
    return node.children
end

AbstractTrees.nodevalue(n::DecompositionTreeNode) = n.bag

AbstractTrees.ParentLinks(::Type{<:DecompositionTreeNode}) = StoredParents()
AbstractTrees.parent(n::DecompositionTreeNode) = n.parent

AbstractTrees.NodeType(::Type{<:DecompositionTreeNode{T}}) where {T} = HasNodeType()
AbstractTrees.nodetype(::Type{<:DecompositionTreeNode{T}}) where {T} = DecompositionTreeNode{T}
Base.show(io::IO, td::DecompositionTreeNode) = print_tree(io, td)

Base.copy(node::DecompositionTreeNode{T}) where T = DecompositionTreeNode(node.bag, node.parent, Vector{DecompositionTreeNode{T}}(copy.(node.children)))

isleaf(node::DecompositionTreeNode) = isempty(node.children)
function treewidth(tree::DecompositionTreeNode)
    tw = length(tree.bag) - 1
    return isleaf(tree) ? tw : max(tw, maximum(treewidth.(children(tree))))
end

struct EliminationOrder{T}
    order::Vector{Vector{T}} # elimination order of vertices, the first element is the first one to be eliminated. The vertices in the same vector are eliminated at the same time.
end

# Generate an elimination order from a tree decomposition
EliminationOrder(tree::DecompositionTreeNode{T}) where{T} = _elimination_order(tree)

function _elimination_order(tree::DecompositionTreeNode{T}) where{T}
    order = Vector{Vector{T}}()

    for node in PostOrderDFS(tree)
        parent = node.parent
        for v in node.bag
            temp = Vector{T}()
            if (isnothing(parent) || (!isnothing(parent) && !(v in parent.bag)))
                pushfirst!(temp, v)
            end
            !isempty(temp) && pushfirst!(order, temp)
        end
    end

    return EliminationOrder(order)
end

# recover the tree decomposition from an elimination order
function decomposition_tree(order::EliminationOrder{TL}, graph::LabeledSimpleGraph{TG, TL, TW}; root::TL = 1) where{TG, TL, TW}
    bags, tree = _tree_bags(order, graph)
    root_node = DecompositionTreeNode(bags[root])
    return _tree_decomposition!(root_node, bags, tree, root)
end

function _tree_bags(order::EliminationOrder{TL}, graph::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW}

    G = deepcopy(graph)
    B = Vector{Vector{TL}}() # bags
    T = SimpleGraph() # tree
    orphan_bags = Int[] # Array to hold parentless vertices of T

    order_vec = vcat(order.order...)

    for i in length(order_vec):-1:1
        u = order_vec[i]

        # Eliminate u from G: form a clique and remove u,
        # Take the clique formed by eliminating u as the next possible bag
        Nᵤ = neighbors(G, u)
        b = [u]
        ib = length(B) + 1
        if !isempty(Nᵤ) b = [Nᵤ; u] end
        G = eliminate(G, u)

        drop_bag = false
        # keep only maximal cliques
        for i in orphan_bags
            l = B[i]
            if Set(b) == Set(intersect(b, l))
                b = l
                ib = i
                drop_bag = true
                break
            end
        end

        # add a new vetex to the tree for the next bag
        # and append it to the parentless vertices.
        if !drop_bag
            push!(B, b)
            add_vertex!(T)
            push!(orphan_bags, ib)
        end

        # Check if the new bag is a parent of any of the
        # orphan vertices and update the list of orphans.
        for i in orphan_bags
            l = B[i]
            b∩l = intersect(b, l)
            if u in b∩l && !issubset(b, b∩l)
                orphan_bags = setdiff(orphan_bags, [i])
                add_edge!(T, i, ib)
            end
        end
    end
    
    return B, T
end

function _tree_decomposition!(node::DecompositionTreeNode{TL}, bags::Vector{Vector{TL}}, tree::SimpleGraph, i::Int) where{TL}
    pbag = isnothing(AbstractTrees.parent(node)) ? Set{TL}() : AbstractTrees.parent(node).bag
    for nᵢ in neighbors(tree, i)
        if Set(bags[nᵢ]) != pbag
            add_child!(node, bags[nᵢ])
            _tree_decomposition!(node.children[end], bags, tree, nᵢ)
        end
    end
    return node
end