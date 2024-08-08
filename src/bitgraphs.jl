using BitBasis, Graphs

struct VertexSet{N, T}
    set::BitStr{N, T} # information about vertices in the set
end

struct BitGraph{N, T}
    bitgraph::Vector{BitStr{N, T}} # store the adjacency matrix as vector of BitStr
    mask::BitStr{N, T} # mask for active vertices
end
Base.show(io::IO, bg::BitGraph{N, T}) where {N, T} = print(io, "BitGraph{$N, $T}, mask: $(bg.mask)")

BitGraph(g::SimpleGraph) = BitGraph{nv(g), Int}(BitStr{nv(g), Int}[], BitStr{nv(g), Int}(ones(Int, nv(g))))

# needed graph operations: neighbors, induced_subgraph, connected_components, 

function neighbors()

end

# consider induced subgraph with mask
function induced_subgraph()

end

# we actually need neighobors of connected components of the induced subgraph
function connected_components()

end

function nebis_of_components()

end