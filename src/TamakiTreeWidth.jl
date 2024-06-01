module TamakiTreeWidth

using Graphs, SparseArrays, AbstractTrees

export line_graph, simple_graph, sparse_adj
export TreeBag, TreeDecomposition

include("Core.jl")
include("line_graph.jl")
include("tree_decomposition.jl")

end
