using TreeWidthSolver: bit2id

@testset "LongLongUInt bit2id" begin
    b = bmask(LongLongUInt{1}, 1:10)
    @test bit2id(b, 64) == collect(1:10)

    b = bmask(LongLongUInt{2}, 1:65)
    @test bit2id(b, 128) == collect(1:65)
end

@testset "LongLongUInt hash" begin
    b1 = bmask(LongLongUInt{1}, 1)
    b2 = bmask(LongLongUInt{1}, 2)
    b3 = bmask(LongLongUInt{1}, 3)

    @test hash((b1, b2, b3)) == hash((b1, b2, b3))
end