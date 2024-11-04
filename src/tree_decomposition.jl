using AbstractTrees

"""
    mutable struct DecompositionTreeNode{T}

A mutable struct representing a node in a tree decomposition.

# Fields
- `bag::Set{T}`: The bag of the node, which is a set of elements of type `T`.
- `parent::Union{DecompositionTreeNode{T}, Nothing}`: The parent node of the current node. It can be either a `DecompositionTreeNode{T}` or `Nothing` if the current node is the root.
- `children::Vector{DecompositionTreeNode{T}}`: The children nodes of the current node, stored in a vector.

"""
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
function width(tree::DecompositionTreeNode)
    tw = length(tree.bag) - 1
    return isleaf(tree) ? tw : max(tw, maximum(width.(children(tree))))
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
        temp = Vector{T}()
        for v in node.bag
            if (isnothing(parent) || (!isnothing(parent) && !(v in parent.bag)))
                pushfirst!(temp, v)
            end
        end
        !isempty(temp) && pushfirst!(order, temp)
    end

    return EliminationOrder(order)
end


# TreeDecomposition is a structure to store a treewidth and tree decomposition of a graph
"""
    struct TreeDecomposition{TW, TL}

A struct representing a tree decomposition.

# Fields
- `tw::TW`: The treewidth of the decomposition.
- `tree::DecompositionTreeNode{TL}`: The root node of the decomposition tree.

"""
struct TreeDecomposition{TW, TL}
    tw::TW
    tree::DecompositionTreeNode{TL}
end

function Base.show(io::IO, td::TreeDecomposition)
    print(io, "tree width: $(td.tw)\n", "tree decomposition:\n$(td.tree)")
end

function is_treedecomposition(G::SimpleGraph{TG}, td::TreeDecomposition{TW, TL}) where{TG, TW, TL}
    treebags = [node.bag for node in collect(PreOrderDFS(td.tree))]

    # all vertices in G are in some bag
    if Set(foldr(∪, collect.(treebags))) != Set(vertices(G))
        return false
    end

    # all edges in G are in some bag
    for (i, j) in edges(G)
        flag = false
        for Ω in treebags
            if (i in Ω && j in Ω)
                flag = true
            end
        end
        if !flag
            return false
        end
    end

    # all treebags containing the same vertex form a connected subtree
    eo = vcat(EliminationOrder(td.tree).order...)
    if (length(eo) != nv(G)) || (unique(eo) != eo)
        return false
    end

    return true
end

function tree_labeling(tree::DecompositionTreeNode{T}, labels::Vector{TL}) where{T, TL}
    new_tree = DecompositionTreeNode(Set{TL}(), nothing, Vector{DecompositionTreeNode{TL}}())
    _tree_labeling!(new_tree, tree, labels)
    return new_tree
end

function _tree_labeling!(new_tree::DecompositionTreeNode{TL}, tree::DecompositionTreeNode{T}, labels::Vector{TL}) where{T, TL}
    new_tree.bag = Set(labels[collect(tree.bag)])
    for child in children(tree)
        add_child!(new_tree, Set(labels[collect(child.bag)]))
        _tree_labeling!(new_tree.children[end], child, labels)
    end
    return nothing
end

function order2tree(eo::Vector{Int}, g::SimpleGraph{TG}) where {TG}
    bags, tree = _tree_bags(eo, g)
    nb = length(bags)
    d_tree = DecompositionTreeNode(Set(bags[nb]), nothing, Vector{DecompositionTreeNode{Int}}())
    return construct_tree!(d_tree, bags, [nb], tree, nb)
end

function _tree_bags(order::Vector{Int}, g::SimpleGraph{TG}) where{TG}

    G = deepcopy(g)
    B = Vector{Vector{Int}}() # bags
    T = SimpleGraph() # tree
    orphan_bags = Int[] # Array to hold parentless vertices of T

    for u in reverse(order)
        # Eliminate u from G: form a clique and remove u,
        # Take the clique formed by eliminating u as the next possible bag
        Nᵤ = neighbors(G, u)
        b = [u]
        ib = length(B) + 1
        if !isempty(Nᵤ) b = [Nᵤ; u] end
        G = eliminate!(G, u)

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

function construct_tree!(d_tree::DecompositionTreeNode{TE}, bags::Vector{Vector{TE}}, used_bags::Vector{Int}, tree::SimpleGraph{TE}, u::Int) where{TE}
    neibs = neighbors(tree, u)
    childs = setdiff(neibs, used_bags)
    used_bags = neibs ∪ used_bags

    for i in childs
        add_child!(d_tree, Set(bags[i]))
        construct_tree!(d_tree.children[end], bags, used_bags, tree, i)
    end

    return d_tree
end