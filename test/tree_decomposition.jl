using TamakiTreeWidth
using TamakiTreeWidth: isleaf
using Test

@testset "tree decompositions" begin
    b1 = TreeBag(Set([1, 2, 3]))
    b2 = TreeBag([1, 2, 3])
    @test b1 == b2

    b3 = TreeBag([1.0, 2.0, 3.0])
    @test b1 != b3

    t1 = TreeDecomposition(b1)
    @test isleaf(t1)

    t2 = TreeDecomposition(b1, [TreeDecomposition(b1), TreeDecomposition(b1)])
    t2c = copy(t2)

    @test t2 == t2c
end