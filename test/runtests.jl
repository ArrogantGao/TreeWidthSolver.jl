using TamakiTreeWidth
using Test

@testset "TamakiTreeWidth.jl" begin
    include("graphs.jl")
    include("tree_decomposition.jl")
    include("min_separator.jl")
    include("max_clique.jl")
end
