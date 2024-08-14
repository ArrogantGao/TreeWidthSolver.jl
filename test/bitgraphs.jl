using TreeWidthSolver: bit_neighbors, open_neighbors, closed_neighbors, is_clique

@testset "MaskedBitGraphs" begin
    g = random_regular_graph(10, 3)
    bg = MaskedBitGraph(g)
    @test nv(bg) == 10

    g = random_regular_graph(120, 3)
    bg = MaskedBitGraph(g)
    @test nv(bg) == 120

    sg = induced_subgraph(bg, bmask(LongLongUInt{2}, 1:10))
    @test nv(sg) == 10
end

@testset "neighbors" begin
    g = smallgraph(:petersen)
    bg = MaskedBitGraph(g)
    for i in 1:10
        @test bit_neighbors(bg, i) == bmask(LongLongUInt{1}, g.fadjlist[i])
    end
    sub_bg = induced_subgraph(bg, bmask(LongLongUInt{1}, 1:5))
    sub_g = induced_subgraph(g, 1:5)[1]

    for i in 1:5
        @test bit_neighbors(sub_bg, i) == bmask(LongLongUInt{1}, sub_g.fadjlist[i])
    end

    @test closed_neighbors(bg, bmask(LongLongUInt{1}, 1:2)) == bmask(LongLongUInt{1}, [1, 2, 3, 5, 6, 7])
    @test open_neighbors(bg, bmask(LongLongUInt{1}, 1:2)) == bmask(LongLongUInt{1}, [3, 5, 6, 7])
    @test closed_neighbors(sub_bg, bmask(LongLongUInt{1}, 1:2)) == bmask(LongLongUInt{1}, [1, 2, 3, 5])
    @test open_neighbors(sub_bg, bmask(LongLongUInt{1}, 1:2)) == bmask(LongLongUInt{1}, [3, 5])
end

@testset "connected component" begin
    g = graph_from_tuples(6, [(1, 2), (2, 3), (1, 3), (4, 5), (5, 6), (4, 6)])
    bg = MaskedBitGraph(g)
    
    @test has_edge(bg, 1, 2)
    @test !has_edge(bg, 1, 4)

    @test connected_components(bg) == [bmask(LongLongUInt{1}, 1:3), bmask(LongLongUInt{1}, 4:6)]

    add_edge!(bg, 3, 4)
    @test connected_components(bg) == [bmask(LongLongUInt{1}, 1:6)]

    @test connected_components(bg, mask = bmask(LongLongUInt{1}, [1, 2, 4, 5, 6])) == [bmask(LongLongUInt{1}, 1:2), bmask(LongLongUInt{1}, 4:6)]
end

@testset "clique" begin
    g = graph_from_tuples(4, [(1, 2), (2, 3), (1, 3), (1, 4), (2, 4)])
    bg = MaskedBitGraph(g)
    @test is_clique(bg, bmask(LongLongUInt{1}, 1:3))
    @test !is_clique(bg, bmask(LongLongUInt{1}, 1:4))
    add_edge!(bg, 3, 4)
    @test is_clique(bg, bmask(LongLongUInt{1}, 1:4))
end