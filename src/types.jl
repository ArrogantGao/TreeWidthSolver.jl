using Graphs, SparseArrays, Bijections

# define a new structure called for labeled simple graph, where all vertices of the graph have unique labels    
mutable struct LabeledSimpleGraph{TG, TL, TW}
    graph::SimpleGraph{TG}
    l2v::Bijection{TL, TG} # dict from labels to vectors
    v2l::Bijection{TG, TL} # dict from vectors to labels, created from active_inv(l2v)
    l2w::Dict{TL, TW} # dict from labels to weights

    function LabeledSimpleGraph(graph::SimpleGraph{TG}, labels::Vector{TL}, weights::Vector{TW}) where {TG, TL, TW}
        if length(unique(labels)) != nv(graph)
            throw(ArgumentError("The number of labels should be equal to the number of vertices"))
        end
        if length(weights) != nv(graph)
            throw(ArgumentError("The number of weights should be equal to the number of vertices"))
        end

        b = Bijection(Dict(zip(labels, collect(vertices(graph)))))
        bb = active_inv(b)
        new{TG, TL, TW}(graph, b, bb, Dict(zip(labels, weights)))
    end

    function LabeledSimpleGraph(graph::SimpleGraph{TG}; labels::Vector{TL} = collect(1:nv(graph)), weights::Vector{TW} = ones(Int, nv(graph))) where {TG, TL, TW}
        LabeledSimpleGraph(graph, labels, weights)
    end
    function LabeledSimpleGraph(graph::SimpleGraph{TG}, l2v::Bijection{TL, TG}, l2w::Dict{TL, TW}) where {TG, TL, TW}
        return new{TG, TL, TW}(graph, l2v, active_inv(l2v), l2w)
    end
end

LabeledSimpleGraph(nv::Int) = LabeledSimpleGraph(SimpleGraph(nv))
LabeledSimpleGraph(adj::SparseMatrixCSC) = LabeledSimpleGraph(simple_graph(adj))

Base.show(io::IO, g::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW} = print(io,"LabeledSimpleGraph{$TG, $TL, $TW}, nv: $(nv(g)), ne: $(ne(g))")
Base.copy(g::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW} = LabeledSimpleGraph(copy(g.graph), [g.v2l[v] for v in 1:nv(g)], [g.l2w[g.v2l[v]] for v in 1:nv(g)])
Base.:(==)(g1::LabeledSimpleGraph{TG, TL, TW}, g2::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW} = (g1.graph == g2.graph) && (g1.l2v == g2.l2v) && (g1.l2w == g2.l2w)


# This part is not necessary for now, commented until data structure is stable
# contruct the adjacency matrix from a simple graph

function adjacency_mat(graph::SimpleGraph)
    rows = Int[]
    cols = Int[]
    for (i,edge) in enumerate(edges(graph))
        push!(rows, edge.src, edge.dst)
        push!(cols, i, i)
    end
    return sparse(rows, cols, ones(Int, length(rows)))
end