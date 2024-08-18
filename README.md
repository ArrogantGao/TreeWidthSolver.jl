# TreeWidthSolver.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ArrogantGao.github.io/TreeWidthSolver.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ArrogantGao.github.io/TreeWidthSolver.jl/dev/)
[![Build Status](https://github.com/ArrogantGao/TreeWidthSolver.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ArrogantGao/TreeWidthSolver.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ArrogantGao/TamakiTreeWidth.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ArrogantGao/TamakiTreeWidth.jl)


`TreeWidthSolver.jl` is a Julia package for solving the minimal treewidth and the corresponding tree decomposition of graphs. Currently we implemented the Bouchitte-Todinca algorithm[^Bouchitté][^Korhonen], which is a dynamic programming algorithm for solving the exact minimal treewidth problem of graphs. This package is used as a bacakend of [OMEinsumContractionOrders.jl](https://github.com/TensorBFS/OMEinsumContractionOrders.jl) for finding the optimal tensor network contraction order.

For more details about this pacakage please see the [docs](https://ArrogantGao.github.io/TreeWidthSolver.jl/stable/), and please refer to this blog [https://arrogantgao.github.io/blogs/treewidth/](https://arrogantgao.github.io/blogs/treewidth/) for more about the algorithm we implemented.

<!-- References -->

[^Bouchitté]: Bouchitté, Vincent, and Ioan Todinca. “Treewidth and Minimum Fill-in: Grouping the Minimal Separators.” SIAM Journal on Computing 31, no. 1 (January 2001): 212–32. https://doi.org/10.1137/S0097539799359683
[^Korhonen]: Korhonen, Tuukka, Jeremias Berg, and Matti Järvisalo. “Solving Graph Problems via Potential Maximal Cliques: An Experimental Evaluation of the Bouchitté--Todinca Algorithm.” ACM Journal of Experimental Algorithmics 24 (December 17, 2019): 1–19. https://doi.org/10.1145/3301297.
