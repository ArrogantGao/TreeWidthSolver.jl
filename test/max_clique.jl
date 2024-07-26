using TamakiTreeWidth, Test

@testset "maximum cliques" begin
    for n in 4:2:12
        g = random_regular_graph(n, 3)
        lg = LabeledSimpleGraph(g)
        Π = all_pmc(lg)
        Π_naive = all_pmc_naive(lg)
        for Ω in Π
            @test is_pmc(lg, Ω)
        end
        @test length(Π) == length(Π_naive)
        @test Π == Π_naive
    end
end

@testset "all pmc on small graphs" begin
    smallgraphs = [:bull, :chvatal, :cubical, :desargues, :diamond, :dodecahedral, :frucht, :heawood, :house, :housex, :icosahedral, :krackhardtkite, :moebiuskantor, :octahedral, :pappus, :petersen, :sedgewickmaze, :tetrahedral, :truncatedtetrahedron]
    for name_smallgraph in smallgraphs
        g = smallgraph(name_smallgraph)
        lg = LabeledSimpleGraph(g)
        Π = all_pmc(lg)
        Πn = all_pmc_naive(lg)
        @test length(Π) == length(Πn)
    end
end