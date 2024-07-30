# TreeWidthSolver.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ArrogantGao.github.io/TreeWidthSolver.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ArrogantGao.github.io/TreeWidthSolver.jl/dev/)
[![Build Status](https://github.com/ArrogantGao/TreeWidthSolver.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ArrogantGao/TreeWidthSolver.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ArrogantGao/TamakiTreeWidth.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ArrogantGao/TamakiTreeWidth.jl)


`TreeWidthSolver.jl` is a Julia package for solving the minimal treewidth and the corresponding tree decomposition of graphs. Currently we implemented the Bouchitte-Todinca algorithm[^Bouchitté][^Korhonen], which is a dynamic programming algorithm for solving the exact minimal treewidth problem of graphs.

Currently this package is under development, and the API is not stable, and the performance is not optimized.

## Getting Started

Open a Julia REPL and type `]` to enter the `pkg>` mode, and then install related packages with the following command:
```julia
pkg> add TreeWidthSolver
```
Then by `using TreeWidthSolver`, the package is loaded, and `Graphs.jl` is re-exported for convenience.

### Examples

Currently, this package provides the following functions:
* `all_min_sep(g::LabeledSimpleGraph)`: find all minimal separators of a graph.
* `all_pmc(g::LabeledSimpleGraph)`: find all potential maximal cliques of a graph.
* `exact_treewidth(g::LabeledSimpleGraph)`: solve the minimal treewidth of a graph.

Here is an example:

```julia
julia> using TreeWidthSolver, Graphs

julia> g = random_regular_graph(6, 3)
{6, 9} undirected simple Int64 graph

julia> lg = LabeledSimpleGraph(g)
LabeledSimpleGraph{Int64, Int64, Int64}, nv: 6, ne: 9

julia> all_min_sep(lg)
Set{Set{Int64}} with 6 elements:
  Set([5, 4, 2])
  Set([6, 2, 1])
  Set([6, 3, 1])
  Set([4, 2, 1])
  Set([5, 4, 3])
  Set([5, 6, 3])

julia> all_pmc(lg)
Set{Set{Int64}} with 12 elements:
  Set([5, 6, 3, 1])
  Set([4, 2, 3, 1])
  Set([4, 6, 3, 1])
  Set([5, 4, 6, 3])
  Set([5, 4, 2, 3])
  Set([5, 4, 6, 2])
  ⋮ 

julia> td = exact_treewidth(lg)
tree width: 3
tree decomposition:
Set([5, 6, 3, 1])
└─ Set([4, 6, 3, 1])
   └─ Set([4, 2, 3, 1])
```
It is shown that for the given graph the minimal treewidth is $3$, and the corresponding tree decomposition is shown, where each set represents a tree bag.

The solver can also solve the weighted treewidth problem, where the weight of each vertex is given. Here is an example:

```julia
julia> weights = [i for i in 1:6];

julia> lg = LabeledSimpleGraph(g, weights = weights)
LabeledSimpleGraph{Int64, Char, Int64}, nv: 6, ne: 6

julia> td = exact_treewidth(lg)
tree width: 13
tree decomposition:
Set([4, 2, 3, 1])
└─ Set([4, 6, 2, 1])
   └─ Set([5, 6, 2, 1])
```

## Questions and Contributions

Please open an [issue](https://github.com/ArrogantGao/TreeWidthSolver.jl/issues) if you encounter any problems, or have any feature requests.

It is also welcomed for any suggestions about the issues marked as `enhancement`, please let us know if you have any idea about them.

<!-- References -->

[^Bouchitté]: Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
[^Korhonen]: Korhonen, Tuukka, Jeremias Berg, and Matti Järvisalo. “Solving Graph Problems via Potential Maximal Cliques: An Experimental Evaluation of the Bouchitté--Todinca Algorithm.” ACM Journal of Experimental Algorithmics 24 (December 17, 2019): 1–19. https://doi.org/10.1145/3301297.