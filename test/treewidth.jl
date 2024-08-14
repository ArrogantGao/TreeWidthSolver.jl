@testset "BT-DP algorithm" begin

    g = graph_from_tuples(5, [(1, 2), (2, 3), (3, 4), (1, 4), (4, 5)])
    @test exact_treewidth(g) ≈ 2

    # 1d line
    g = graph_from_tuples(6, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)])
    @test exact_treewidth(g) ≈ 1

    # square
    g = graph_from_tuples(4, [(1, 2), (2, 3), (3, 4), (4, 1)])
    @test exact_treewidth(g) ≈ 2

    # small graphs

    graph_names = [:bull, :chvatal, :cubical, :desargues, :diamond, :dodecahedral, :frucht, :heawood, :house, :housex, :icosahedral, :karate, :krackhardtkite, :moebiuskantor, :octahedral, :pappus, :petersen, :sedgewickmaze, :tetrahedral, :truncatedtetrahedron]
    # these results are calculated by C++ package triangulator for tree width
    # see https://github.com/Laakeri/triangulator-msc
    tws = [2, 6, 3, 6, 2, 6, 3, 5, 2, 3, 6, 5, 3, 5, 4, 6, 4, 2, 3, 4]
    for (i, graph_name) in enumerate(graph_names)
        g = smallgraph(graph_name)
        tw = exact_treewidth(g)
        @test tw ≈ tws[i]

        Π = all_pmc_enmu(MaskedBitGraph(g), false)
        td = bt_algorithm(MaskedBitGraph(g), Π, ones(ne(g)), false)

        @test td.tw == tw
        @test width(td.tree) == tw

        order = elimination_order(g)
        @test Set(unique!(vcat(order...))) == Set(1:nv(g))
    end
end