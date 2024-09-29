Base.show(io::IO, val::LongLongUInt{C}) where{C} = print(io, BitStr{64 * C}(val))

function bit2id(bit::INT, N::Int) where{INT}
    id = Vector{Int}()
    for i in 1:N
        if readbit(bit, i) == 1
            push!(id, i)
        end
    end
    return id
end

function Base.hash(bits_tuple::Tuple{LongLongUInt{C}, Vararg{LongLongUInt{C}, M}}) where{M, C}
    N = M + 1
    hash0 = Base.hash(bits_tuple[1].content)
    for i in 2:N
        hash0 = Base.hash(bits_tuple[i].content, hash0)
    end
    return hash0
end
