module TreeWidthSolver

using SparseArrays, AbstractTrees, Combinatorics, Graphs, BitBasis

export MaskedBitGraph

# interface for graphs
export line_graph, simple_graph, adjacency_mat
export graph_from_gr, graph_from_tuples, save_graph

# interface about the bt algorithm
export is_min_sep, all_min_sep, all_min_sep_naive
export is_pmc, all_pmc_naive, all_pmc_enmu, all_pmc_bt
export bt_algorithm

# highest level interface
export exact_treewidth, decomposition_tree, elimination_order
export is_treedecomposition

export DecompositionTreeNode, TreeDecomposition, EliminationOrder, width

# the data structure
include("bitbasis.jl")
include("bitgraphs.jl")

# the graph operations
include("graphs.jl")
include("tree_decomposition.jl")

# the BT algorithm
include("min_separator.jl")
include("max_clique.jl")
include("bt_algorithm.jl")

include("treewidth.jl")

end
