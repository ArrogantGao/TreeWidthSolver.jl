using BitBasis
export bit2id

Base.show(io::IO, val::LongLongUInt{C}) where{C} = print(io, BitStr{64 * C}(val))

function Base.isless(val1::LongLongUInt{C}, val2::LongLongUInt{C}) where{C}
    for i in 1:C
        if val1.content[i] < val2.content[i]
            return true
        elseif val1.content[i] > val2.content[i]
            return false
        end
    end
    return false
end

function bit2id(bit::LongLongUInt{C}; N::Int = 64 * C) where{C}
    id = Vector{Int}()
    for i in 1:N
        if readbit(bit, i) == 1
            push!(id, i)
        end
    end
    return id
end