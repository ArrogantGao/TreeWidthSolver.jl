using TamakiTreeWidth, Test

@testset "maximum cliques" begin
    g = random_regular_graph(20, 3)
    lg = LabeledSimpleGraph(g)
    Δ, Π = all_pmc(lg)
    for S in Δ
        @test is_min_sep(lg, S)
    end
    for Ω in Π
        @test is_pmc(lg, Ω)
    end
end