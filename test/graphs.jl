using TreeWidthSolver: LabeledSimpleGraph, line_graph, simple_graph, adjacency_mat
using Graphs, SparseArrays
using Test

@testset "line graph construct" begin
    g = random_regular_graph(10, 3)
    adj = adjacency_mat(g)

    lg1 = LabeledSimpleGraph(adj)
    lg2 = LabeledSimpleGraph(simple_graph(adj))
    lg3 = LabeledSimpleGraph(g)

    @test lg1 == lg2
    @test lg1 == lg3

    lgc = copy(lg1)
    @test lgc == lg1

    vecs = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
    lgchar = LabeledSimpleGraph(g, labels = vecs)
    @test lgchar.l2v['b'] == 2
end