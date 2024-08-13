using TreeWidthSolver: all_pmc_bt

@testset "maximum cliques" begin
    for n in 6:2:14
        g = random_regular_graph(n, 3)
        bg = BitGraph(g)
        Π_enmu = all_pmc_enmu(bg, false)
        Π_bt = all_pmc_bt(bg)
        Π_naive = all_pmc_naive(bg)
        for Ω in Π_enmu
            @test is_pmc(bg, Ω)
        end
        @test length(Π_enmu) == length(Π_naive)
        @test Set(Π_enmu) == Set(Π_naive) == Set(Π_bt)
    end
end