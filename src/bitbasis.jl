function bit2id(bit::INT, N::Int) where{INT}
    id = Vector{Int}()
    for i in 1:N
        if readbit(bit, i) == 1
            push!(id, i)
        end
    end
    return id
end
