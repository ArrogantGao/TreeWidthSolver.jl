struct TreeBag{T}
    ids::Set{T}
    TreeBag(ids::Set{T}) where T = new{T}(ids)
    TreeBag(ids::Vector{T}) where T = new{T}(Set(ids))
end

Base.copy(bag::TreeBag) = TreeBag(copy(bag.ids))
Base.show(io::IO, bag::TreeBag{T}) where {T} = print(io, "TreeBag{$T} $([bag.ids...])")

mutable struct TreeDecomposition{T}
    bag::TreeBag{T}
    children::Vector{TreeDecomposition{T}}
    isleaf::Bool
    TreeDecomposition(bag::TreeBag{T}, children::Vector{TreeDecomposition{T}}) where T = new{T}(bag, children, isempty(children))
    TreeDecomposition(bag::TreeBag{T}) where T = new{T}(bag, Vector{TreeDecomposition{T}}[], true)
end

isleaf(tree::TreeDecomposition) = tree.isleaf
Base.copy(t::TreeDecomposition) = isleaf(t) ? TreeDecomposition(copy(t.bag)) : TreeDecomposition(copy(t.bag), copy.(t.children))

AbstractTrees.children(tree::TreeDecomposition) = tree.children
AbstractTrees.nodevalue(tree::TreeDecomposition) = tree.bag
Base.show(io::IO, td::TreeDecomposition) = print_tree(io, td)

Base.:(==)(b1::TreeBag{T1}, b2::TreeBag{T2}) where{T1, T2} = (T1 == T2) && (b1.ids == b2.ids)
Base.:(==)(t1::TreeDecomposition, t2::TreeDecomposition) = _equal(t1, t2)
Base.:(==)(t1::Set{TreeDecomposition}, t2::Set{TreeDecomposition}) = _equal(t1, t2)
function _equal(t1::Set{TreeDecomposition{T1}}, t2::Set{TreeDecomposition{T2}}) where{T1, T2}
    T1 != T2 && return false
    length(t1) != length(t2) && return false
    for t in t1
        !any(t == t2i for t2i in t2) && return false
    end
    for t in t2
        !any(t == t1i for t1i in t1) && return false
    end
    return true
end

function _equal(t1::TreeDecomposition{T1}, t2::TreeDecomposition{T2}) where{T1, T2}
    T1 != T2 && return false
    isleaf(t1) != isleaf(t2) && return false
    isleaf(t1) ? t1.bag == t2.bag :  t1.bag == t2.bag && _equal(Set(t1.children), Set(t2.children))
end