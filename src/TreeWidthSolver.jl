module TreeWidthSolver

using SparseArrays, AbstractTrees, Bijections, Combinatorics
using Reexport
@reexport using Graphs

export line_graph, simple_graph, adjacency_mat, graph_from_tuples
export LabeledSimpleGraph

export is_min_sep, all_min_sep
export is_pmc, all_pmc, all_pmc_naive, all_pmc_ub
export BTDP_exact_tw, TreeDecomposition, is_treedecomposition
export exact_treewidth, iterative_exact_treewidth

export DecompositionTreeNode, treewidth, EliminationOrder

# the data structure
include("types.jl")

# the graph operations
include("graphs.jl")
include("tree_decomposition.jl")

# the BT algorithm
include("min_separator.jl")
include("max_clique.jl")
include("bt_dp.jl")

end
