using TreeWidthSolver, Test

@testset "BT-DP algorithm" begin

    g = graph_from_tuples(5, [(1, 2), (2, 3), (3, 4), (1, 4), (4, 5)])
    lg = LabeledSimpleGraph(g)
    td = exact_treewidth(lg)
    @test td.tw == 2

    # 1d line
    g = graph_from_tuples(6, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)])
    lg = LabeledSimpleGraph(g)
    td = exact_treewidth(lg)
    @test td.tw == 1

    # square
    g = graph_from_tuples(4, [(1, 2), (2, 3), (3, 4), (4, 1)])
    lg = LabeledSimpleGraph(g)
    td = exact_treewidth(lg)
    @test td.tw == 2

    for n in 4:2:12
        g = random_regular_graph(n, 3)
        lg = LabeledSimpleGraph(g)
        td = exact_treewidth(lg)
        @test is_treedecomposition(lg, td)
    end
end

@testset "BT DP algorithm on small graphs" begin
    # for smallgraph(:truncatedcube) bt gives tw = 5, well TreeSA gives sc = 4
    for name_smallgraph in [:bull, :chvatal, :cubical, :desargues, :diamond, :dodecahedral, :frucht, :heawood, :house, :housex, :icosahedral, :karate, :krackhardtkite, :moebiuskantor, :octahedral, :pappus, :petersen, :sedgewickmaze, :tetrahedral, :truncatedtetrahedron]
        g = smallgraph(name_smallgraph)
        lg = LabeledSimpleGraph(g)
        td = exact_treewidth(lg)
        @test is_treedecomposition(lg, td)
    end
end