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
    return isleaf(tree) ? tw : min(tw, minimum(treewidth.(children(tree))))
end

# struct EliminationOrder{T}
#     order::Vector{T}
# end

# function elimination_order(tree::DecompositionTree{T}) where{T}
#     order = Vector{T}()
#     _elimination_order!(tree, order)
#     return EliminationOrder(order)
# end