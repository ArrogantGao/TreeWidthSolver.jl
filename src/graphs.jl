function graph_from_tuples(n::Int, edgs)
    g = SimpleGraph(n)
    for (i, j) in edgs
        add_edge!(g, i, j)
    end
    g
end

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

function line_graph(g::SimpleGraph, labels::Vector = [1:ne(g)...])
    return line_graph(adjacency_mat(g), labels=labels)
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

# the graphs operations defined on labeled graphs

Graphs.nv(g::LabeledSimpleGraph) = nv(g.graph)
Graphs.vertices(g::LabeledSimpleGraph) = [g.v2l[i] for i in vertices(g.graph)]
Graphs.ne(g::LabeledSimpleGraph) = ne(g.graph)
Graphs.edges(g::LabeledSimpleGraph) = [(g.v2l[src(i)], g.v2l[dst(i)]) for i in edges(g.graph)]
Graphs.neighbors(g::LabeledSimpleGraph{TG, TL, TW}, v::TL) where{TG, TL, TW} = [g.v2l[n] for n in neighbors(g.graph, g.l2v[v])]
Graphs.has_edge(g::LabeledSimpleGraph{TG, TL, TW}, src::TL, dst::TL) where{TG, TL, TW} = has_edge(g.graph, g.l2v[src], g.l2v[dst])

function Graphs.add_edge!(g::LabeledSimpleGraph{TG, TL, TW}, src::TL, dst::TL) where{TG, TL, TW}
    add_edge!(g.graph, g.l2v[src], g.l2v[dst])
    return g
end

function Graphs.add_vertex!(g::LabeledSimpleGraph{TG, TL, TW}, label::TL) where{TG, TL, TW}
    add_vertex!(g.graph)
    g.l2v[label] = nv(g.graph)
    return g
end

function is_clique(g::LabeledSimpleGraph{TG, TL, TW}) where{TG, TL, TW}
    vs = vertices(g)
    for i in vs, j in vs
        if i != j && !has_edge(g, i, j) return false end
    end
    return true
end


function is_clique(g::LabeledSimpleGraph{TG, TL, TW}, S::Union{Set{TL}, Vector{TL}}) where{TG, TL, TW}
    for i in S, j in S
        if i != j && !has_edge(g, i, j) return false end
    end
    return true
end

function Graphs.induced_subgraph(g::LabeledSimpleGraph{TG, TL, TW}, vertices::Vector{TL}) where{TG, TL, TW}
    
    g_new, vertices_old = induced_subgraph(g.graph, [g.l2v[v] for v in vertices])
    labels = [g.v2l[v] for v in vertices_old]
    weights = [g.l2w[l] for l in labels]

    return LabeledSimpleGraph(g_new, labels, weights)
end

function closed_neighbors(g::LabeledSimpleGraph{TG, TL, TW}, S::Union{Set{TL}, Vector{TL}}) where{TG, TL, TW}
    neibs = Set{TL}(S)
    for v in S, n in neighbors(g, v)
        push!(neibs, n)
    end
    return neibs
end

function open_neighbors(g::LabeledSimpleGraph{TG, TL, TW}, S::Union{Set{TL}, Vector{TL}}) where{TG, TL, TW}
    c_neibs = closed_neighbors(g, S)
    return setdiff(c_neibs, S)
end

function components(g::LabeledSimpleGraph{TG, TL, TW}, S::Union{Set{TL}, Vector{TL}}) where{TG, TL, TW}
    # remove S from graph
    g_new = induced_subgraph(g, collect(setdiff(Set(vertices(g)), S)))
    ccs = connected_components(g_new.graph)
    return Set([Set([g_new.v2l[v] for v in cc]) for cc in ccs])
end

function is_full_component(g::LabeledSimpleGraph{TG, TL, TW}, S::Union{Set{TL}, Vector{TL}}, C::Union{Set{TL}, Vector{TL}}) where{TG, TL, TW}
    nc = open_neighbors(g, C)
    @show nc
    return Set(S) == Set(nc)
end

function full_components(g::LabeledSimpleGraph{TG, TL, TW}, S::Set{TL}) where{TG, TL, TW}
    cs = components(g, S)
    fcs = Vector{Set{TL}}()
    for C in cs
        if is_full_component(g, S, C)
            push!(fcs, C)
        end
    end
    return Set(fcs)
end