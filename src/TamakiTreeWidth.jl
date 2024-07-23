module TamakiTreeWidth

using SparseArrays, AbstractTrees, Bijections, Combinatorics
using Reexport
@reexport using Graphs

export line_graph, simple_graph, adjacency_mat, graph_from_tuples
export LabeledSimpleGraph

export is_min_sep, all_min_sep
export is_pmc, all_pmc
export BTDP_exact_tw, TreeDecomposition, is_treedecomposition

# export DecompositionTreeNode, treewidth, EliminationOrder

# the data structure
include("types.jl")

# the graph operations
include("graphs.jl")

# the BT algorithm
include("min_separator.jl")
include("max_clique.jl")
include("bt_dp.jl")

# the tree decomposition is commented, since we need to fix the data structure of graphs
# include("tree_decomposition.jl")

# the visualization
# include("LuxorGraphPlot.jl")

end
