@testset "line graph" begin
    g = random_regular_graph(10, 3)
    adj_mat = adjacency_mat(g)
    g2 = simple_graph(adj_mat)
    @test g == g2

    lg1 = line_graph(g)
    lg2 = line_graph(adj_mat)
    @test lg1 == lg2
    @test nv(lg1) == ne(g)
end