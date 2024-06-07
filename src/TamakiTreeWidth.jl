module TamakiTreeWidth

using Graphs, SparseArrays, AbstractTrees

export line_graph, simple_graph, adjacency_mat
export DecompositionTreeNode, treewidth, EliminationOrder

include("graphs.jl")
include("tree_decomposition.jl")
include("LuxorGraphPlot.jl")

end
