module TreeWidthSolver

using SparseArrays, AbstractTrees, Bijections, Combinatorics, Graphs, BitBasis, DataStructures

export line_graph, simple_graph, adjacency_mat, graph_from_tuples
export LabeledSimpleGraph, BitGraph

# io for graphs
export graph_from_gr, graph_from_tuples

export is_min_sep, all_min_sep, all_min_sep_naive
export is_pmc, all_pmc_naive, all_pmc_enmu
export BTDP_exact_tw, TreeDecomposition, is_treedecomposition
export exact_treewidth

export DecompositionTreeNode, treewidth, EliminationOrder, decomposition_tree

# the data structure
include("types.jl")
include("bitbasis.jl")

# the graph operations
include("graphs.jl")
include("bitgraphs.jl")
include("tree_decomposition.jl")

# the BT algorithm
include("min_separator.jl")
include("max_clique.jl")
include("bt_dp.jl")

end
