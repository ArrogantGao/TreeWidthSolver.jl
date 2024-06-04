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
    order::Vector{T} # elimination order of vertices, the first element is the first one to be eliminated
end

# Generate an elimination order from a tree decomposition
EliminationOrder(tree::DecompositionTreeNode{T}) where{T} = _elimination_order(tree)
function EliminationOrder(tree::DecompositionTreeNode{T}, graph::LabeledSimpleGraph{TL, TG}) where{T, TL, TG}
    order_native = _elimination_order(tree)
    order = [graph.labels[v] for v in order_native.order]
    return EliminationOrder(order)
end

function _elimination_order(tree::DecompositionTreeNode{T}) where{T}
    order = Vector{T}()

    for node in PostOrderDFS(tree)
        parent = node.parent
        for v in node.bag
            if !(v in order) && (isnothing(parent) || (!isnothing(parent) && !(v in parent.bag)))
                pushfirst!(order, v)
            end
        end
    end

    return EliminationOrder(order)
end

# recover the tree decomposition from an elimination order
DecompositionTreeNode(order::EliminationOrder{T}, graph::SimpleGraph) where{T} = _tree_decomposition(order, graph)

function _tree_decomposition(order::EliminationOrder{T}, graph::SimpleGraph) where{T}
    tree = DecompositionTreeNode(Set{T}())
    
    return tree
end