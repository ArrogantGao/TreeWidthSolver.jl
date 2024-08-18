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