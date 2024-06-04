using Graphs, SparseArrays

# define a new structure called for labeled simple graph, where all vertices of the graph have unique labels    
mutable struct LabeledSimpleGraph{TG, TL}
    graph::SimpleGraph{TG}
    labels::Vector{TL}

    function LabeledSimpleGraph(graph::SimpleGraph{TG}, labels::Vector{TL}) where {TG, TL}
        if length(unique(labels)) != nv(graph)
            throw(ArgumentError("The number of labels should be equal to the number of vertices"))
        end
        new{TG, TL}(graph, labels)
    end

    function LabeledSimpleGraph(graph::SimpleGraph{TG}) where {TG}
        new{TG, Int}(graph, 1:nv(graph))
    end
end

LabeledSimpleGraph(nv::Int) = LabeledSimpleGraph(SimpleGraph(nv))
LabeledSimpleGraph(adj::SparseMatrixCSC) = LabeledSimpleGraph(simple_graph(adj))

function label2vec(g::LabeledSimpleGraph{TG, TL}, l::TL) where{TG, TL}
    if l in g.labels
        return findfirst(isequal(l), g.labels)
    else
        throw(ArgumentError("The label $l is not in the graph"))
    end
end

Graphs.nv(g::LabeledSimpleGraph) = nv(g.graph)
Graphs.ne(g::LabeledSimpleGraph) = ne(g.graph)
Graphs.edges(g::LabeledSimpleGraph) = edges(g.graph)

function Graphs.add_edge!(g::LabeledSimpleGraph, src::Int, dst::Int)
    add_edge!(g.graph, src, dst)
    return g
end

function Graphs.add_vertex!(g::LabeledSimpleGraph{TG, TL}, label::TL) where{TG, TL}
    add_vertex!(g.graph)
    push!(g.labels, label)
    return g
end

Base.show(io::IO, g::LabeledSimpleGraph{TG, TL}) where{TG, TL} = print(io,"LabeledSimpleGraph{$TG, $TL}, {$(nv(g)), $(ne(g))}, labels ", g.labels)
Base.copy(g::LabeledSimpleGraph{TG, TL}) where{TG, TL} = LabeledSimpleGraph(copy(g.graph), copy(g.labels))
Base.:(==)(g1::LabeledSimpleGraph{TG, TL}, g2::LabeledSimpleGraph{TG, TL}) where{TG, TL} = (g1.graph == g2.graph) && (g1.labels == g2.labels)

# contruct line graph from a sparse adjoint martix
# cols represents the vertices, rows represent the edges, true for connected
function line_graph(adjacency_mat::SparseMatrixCSC; labels::Vector{TL}=[1:size(adjacency_mat, 2)...]) where{TL}
    nv = size(adjacency_mat, 1)
    ne = size(adjacency_mat, 2)

    g = SimpleGraph(ne)
    for v in 1:nv
        ecv = adjacency_mat[v, :].nzind # edges connected to v
        for i in 1:length(ecv)
            for j in i+1:length(ecv)
                add_edge!(g, ecv[i], ecv[j])
            end
        end
    end

    return LabeledSimpleGraph(g, labels)
end

# contruct a simple graph from the adjoint martix
function simple_graph(adjacency_mat::SparseMatrixCSC)
    ne = size(adjacency_mat, 2)
    nv = size(adjacency_mat, 1)
    g = SimpleGraph(nv)

    for e in 1:ne
        vce = adjacency_mat[:, e].nzind # vertices connected to e
        for i in 1:length(vce)
            for j in i+1:length(vce)
                add_edge!(g, vce[i], vce[j])
            end
        end
    end

    return g
end

# contruct the adjacency matrix from a simple graph
function adjacency_mat(graph::Union{SimpleGraph, LabeledSimpleGraph})
    rows = Int[]
    cols = Int[]
    for (i,edge) in enumerate(edges(graph))
        push!(rows, edge.src, edge.dst)
        push!(cols, i, i)
    end
    return sparse(rows, cols, ones(Int, length(rows)))
end