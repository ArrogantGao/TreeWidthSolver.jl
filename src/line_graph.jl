# contruct line graph from a sparse adjoint martix
# cols represents the vertices, rows represent the edges, true for connected
function line_graph(adj::SparseMatrixCSC)
    nv = size(adj, 1)
    ne = size(adj, 2)

    g = SimpleGraph(ne)
    for v in 1:nv
        ecv = adj[v, :].nzind # edges connected to v
        for i in 1:length(ecv)
            for j in i+1:length(ecv)
                add_edge!(g, ecv[i], ecv[j])
            end
        end
    end

    return g
end

# contruct a simple graph from the adjoint martix
function simple_graph(adj::SparseMatrixCSC)
    ne = size(adj, 2)
    nv = size(adj, 1)
    g = SimpleGraph(nv)

    for e in 1:ne
        vce = adj[:, e].nzind # vertices connected to e
        for i in 1:length(vce)
            for j in i+1:length(vce)
                add_edge!(g, vce[i], vce[j])
            end
        end
    end

    return g
end

# contruct a sparse adjoint matrix from a simple graph
function sparse_adj(graph::SimpleGraph)
    rows = Int[]
    cols = Int[]
    for (i,edge) in enumerate(edges(graph))
        push!(rows, edge.src, edge.dst)
        push!(cols, i, i)
    end
    return sparse(rows, cols, ones(Int, length(rows)))
end