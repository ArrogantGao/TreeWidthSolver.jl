```@meta
CurrentModule = TreeWidthSolver
```

# TreeWidthSolver.jl

Documentation for [TreeWidthSolver](https://github.com/ArrogantGao/TreeWidthSolver.jl).

`TreeWidthSolver.jl` is a Julia package for solving the treewidth problem. It provides a simple interface for solving the treewidth problem and generating tree decompositions.
Currently we implemented the Bouchitté-Todinca algorithm for solving the treewidth problem, which is a exact algorithm for solving the treewidth problem.

For more details about the algorithms implemented in this package, please refer to the blog: [https://arrogantgao.github.io/blogs/treewidth/](https://arrogantgao.github.io/blogs/treewidth/).

This package is used as backend for finding the optimal tensor network contraction order in [OMEinsumContractionOrders.jl](https://github.com/TensorBFS/OMEinsumContractionOrders.jl), for more details please see the Contraction Order part.

## Installation

To install the package, enter the package manager by pressing `]` in the Julia REPL and run the following command:
```julia
pkg> add TreeWidthSolver
```
and everything should be set up.

## Usage

The user interface of this package is quite simple, three functions are provided:
* `exact_treewidth(g::SimpleGraph{TG}; weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW}`: Compute the exact treewidth of a given graph `g` using the BT algorithm.
* `decomposition_tree(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TW, TL}`: Compute the tree decomposition with minimal treewidth of a given graph `g` using the BT algorithm.
* `elimination_order(g::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(g)), weights::Vector{TW} = ones(nv(g)), verbose::Bool = false) where {TG, TL, TW}`: Compute the elimination order of a given graph `g` using the BT algorithm.

Here are some examples:
```julia
julia> using TreeWidthSolver, Graphs

julia> g = smallgraph(:petersen)
{10, 15} undirected simple Int64 graph

# calculate the exact treewidth of the graph
julia> exact_treewidth(g)
4.0

# show more information
julia> exact_treewidth(g, verbose = true)
[ Info: computing all minimal separators
[ Info: allminseps: 10, 15
[ Info: all minimal separators computed, total: 15
[ Info: computing all potential maximal cliques
[ Info: vertices: 9, Δ: 15, Π: 0
[ Info: vertices: 8, Δ: 14, Π: 9
[ Info: vertices: 7, Δ: 13, Π: 16
[ Info: vertices: 6, Δ: 9, Π: 24
[ Info: vertices: 5, Δ: 6, Π: 35
[ Info: vertices: 4, Δ: 5, Π: 36
[ Info: vertices: 3, Δ: 2, Π: 43
[ Info: vertices: 2, Δ: 1, Π: 44
[ Info: vertices: 1, Δ: 1, Π: 44
[ Info: computing all potential maximal cliques done, total: 45
[ Info: computing the exact treewidth using the Bouchitté-Todinca algorithm
[ Info: precomputation phase
[ Info: precomputation phase completed, total: 135
[ Info: computing the exact treewidth done, treewidth: 4.0
4.0

# construct the tree decomposition
julia> decomposition_tree(g)
tree width: 4.0
tree decomposition:
Set([5, 6, 7, 3, 1])
├─ Set([7, 2, 3, 1])
├─ Set([5, 4, 6, 7, 3])
│  └─ Set([4, 6, 7, 9])
└─ Set([5, 6, 7, 10, 3])
   └─ Set([6, 10, 8, 3])

# similar for the elimination order
julia> elimination_order(g)
6-element Vector{Vector{Int64}}:
 [1, 3, 7, 6, 5]
 [10]
 [8]
 [4]
 [9]
 [2]

# one can also assign labels to the vertices
julia> elimination_order(g, labels = ['a':'j'...])
6-element Vector{Vector{Char}}:
 ['a', 'c', 'g', 'f', 'e']
 ['j']
 ['h']
 ['d']
 ['i']
 ['b']
```

## Questions and Contributions

If you have any questions or suggestions, please feel free to open an issue.
It is also welcomed for any suggestions about the issues marked as `enhancement`, please let us know if you have any idea about them.