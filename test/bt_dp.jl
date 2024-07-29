using TamakiTreeWidth, Test
using OMEinsum, OMEinsumContractionOrders

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

@testset "BT DP algorithm on small graphs" begin
    # for smallgraph(:truncatedcube) bt gives tw = 5, well TreeSA gives sc = 4
    for name_smallgraph in [:bull, :chvatal, :cubical, :desargues, :diamond, :dodecahedral, :frucht, :heawood, :house, :housex, :icosahedral, :karate, :krackhardtkite, :moebiuskantor, :octahedral, :pappus, :petersen, :sedgewickmaze, :tetrahedral, :truncatedtetrahedron]
        g = smallgraph(name_smallgraph)
        lg = LabeledSimpleGraph(g)
        Π = all_pmc(lg)
        td = BTDP_exact_tw(lg, Π)
        @test is_treedecomposition(lg, td)

        function eincode_from_graph(g)
            ixs = [minmax(e.src,e.dst) for e in Graphs.edges(g)]
            return EinCode((ixs..., [(i,) for i in Graphs.vertices(g)]...), ())
        end
        code = eincode_from_graph(g)
        optimizer = TreeSA(ntrials=3)
        res = optimize_code(code,uniformsize(code, 2), optimizer)
        cc = OMEinsum.contraction_complexity(res, uniformsize(code, 2))
        @show name_smallgraph, nv(g), cc.sc, td.tw
        @test cc.sc >= td.tw
    end
end