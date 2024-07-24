using TamakiTreeWidth, Test
using TamakiTreeWidth: all_pmc_naive

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