@testset "minimum separators" begin
    for n in 6:2:14
        g = random_regular_graph(n, 3)
        bg = BitGraph(g)
        @test Set(all_min_sep(bg, false)) == Set(all_min_sep_naive(bg))
    end
end