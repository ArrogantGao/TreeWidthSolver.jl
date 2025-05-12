using TreeWidthSolver: bit2id

@testset "LongLongUInt bit2id" begin
    b = bmask(LongLongUInt{1}, 1:10)
    @test bit2id(b, 64) == collect(1:10)

    b = bmask(LongLongUInt{2}, 1:65)
    @test bit2id(b, 128) == collect(1:65)
end
