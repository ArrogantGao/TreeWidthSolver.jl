module TamakiTreeWidth

using Graphs, SparseArrays, AbstractTrees

export line_graph, simple_graph, sparse_adj
export DecompositionTreeNode, treewidth

include("Core.jl")
include("line_graph.jl")
include("tree_decomposition.jl")

end
