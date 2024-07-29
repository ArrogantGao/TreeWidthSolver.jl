using TreeWidthSolver
using Test

@testset "TreeWidthSolver.jl" begin
    include("graphs.jl")
    include("tree_decomposition.jl")
    include("min_separator.jl")
    include("max_clique.jl")
    include("bt_dp.jl")
end
