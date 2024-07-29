using TamakiTreeWidth, Test
using TamakiTreeWidth: all_min_sep_naive

@testset "minimum separators" begin
    g = graph_from_tuples(6, [(1, 2), (1, 3), (2, 4), (3, 4), (3, 5), (4, 6), (5, 6)])
    lg = LabeledSimpleGraph(g)
    @test is_min_sep(lg, Set([3, 4]))

    for n in 4:2:16
        g = random_regular_graph(n, 3)
        lg = LabeledSimpleGraph(g)
        Δ = all_min_sep(lg)
        Δ_naive = all_min_sep_naive(lg)
        @test Δ == Δ_naive
        for S in Δ
            @test is_min_sep(lg, S)
        end
    end
end