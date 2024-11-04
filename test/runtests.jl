using TreeWidthSolver
using Graphs, BitBasis
using Test
using Random

Random.seed!(1234)

@testset "TreeWidthSolver.jl" begin
    include("bitbasis.jl")
    include("graphs.jl")
    include("bitgraphs.jl")
    include("tree_decomposition.jl")
    include("min_separator.jl")
    include("max_clique.jl")
    include("treewidth.jl")
end
