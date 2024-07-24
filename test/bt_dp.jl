using TamakiTreeWidth, Test

@testset "BT-DP algorithm" begin

    g = graph_from_tuples(5, [(1, 2), (2, 3), (3, 4), (1, 4), (4, 5)])
    lg = LabeledSimpleGraph(g)
    Π = all_pmc(lg)
    td = BTDP_exact_tw(lg, Π)
    @test td.tw == 2

    # 1d line
    g = graph_from_tuples(6, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)])
    lg = LabeledSimpleGraph(g)
    Π = all_pmc(lg)
    td = BTDP_exact_tw(lg, Π)
    @test td.tw == 1

    # square
    g = graph_from_tuples(4, [(1, 2), (2, 3), (3, 4), (4, 1)])
    lg = LabeledSimpleGraph(g)
    Π = all_pmc(lg)
    td = BTDP_exact_tw(lg, Π)
    @test td.tw == 2

    for n in 4:2:12
        g = random_regular_graph(n, 3)
        lg = LabeledSimpleGraph(g)
        Π = all_pmc(lg)
        td = BTDP_exact_tw(lg, Π)
        @test is_treedecomposition(lg, td)
    end
end