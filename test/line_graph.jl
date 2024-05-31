using TamakiTreeWidth: line_graph, simple_graph, sparse_adj
using Graphs, SparseArrays
using Test

@testset "line graph construct" begin
    g = random_regular_graph(10, 3)
    adj = sparse_adj(g)

    lg = line_graph(adj)
    sg = simple_graph(adj)

    @test sg == g
    @test length(edges(lg)) == 30
end