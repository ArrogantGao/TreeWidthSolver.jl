function graph_from_tuples(n::Int, edgs)
    g = SimpleGraph(n)
    for (i, j) in edgs
        add_edge!(g, i, j)
    end
    g
end

"""
    graph_from_gr(filename)

Reads a graph from a file in the .gr format (PACE format) and returns a `SimpleGraph` object.

# Arguments
- `filename`: The path to the input file.

# Returns
- `graph`: A `SimpleGraph` object representing the graph.

"""
function graph_from_gr(filename)
    open(filename, "r") do file
        line = readline(file)
        first_str, second_str, first_num, second_num = split(line)
        n = parse(Int64, first_num)
        graph = SimpleGraph(n)

        for line in eachline(file)
            v1, v2 = split(line)
            add_edge!(graph, parse(Int64, v1), parse(Int64, v2))
        end
        return graph
    end
end

"""
    function save_graph(g::SimpleGraph, filename)

The graph will be saved as .gr format, in PACE format, where the first line is `p tw nv ne`, and the following lines are the edges `src dst`
"""
function save_graph(g::SimpleGraph, filename)
    open(filename, "w") do file
        println(file, "p tw $(nv(g)) $(ne(g))")
        for e in edges(g)
            println(file, "$(src(e)) $(dst(e))")
        end
    end
    nothing
end
    
function adjacency_mat(graph::SimpleGraph)
    rows = Int[]
    cols = Int[]
    for (i,edge) in enumerate(edges(graph))
        push!(rows, edge.src, edge.dst)
        push!(cols, i, i)
    end
    return sparse(rows, cols, ones(Int, length(rows)))
end

"""
    line_graph(adjacency_mat::SparseMatrixCSC)

Constructs the line graph of a given graph represented by its adjacency matrix.

# Arguments
- `adjacency_mat::SparseMatrixCSC`: The adjacency matrix of the input graph, where the columns represent the vertices and the rows represent the edges. The value is `true` if the edge is connected to the vertex.

# Returns
- `g::SimpleGraph`: The line graph of the input graph.

"""
function line_graph(adjacency_mat::SparseMatrixCSC)
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

    return g
end
function line_graph(g::SimpleGraph)
    return line_graph(adjacency_mat(g))
end


"""
    simple_graph(adjacency_mat::SparseMatrixCSC)

Constructs a simple undirected graph from a sparse adjacency matrix.

# Arguments
- `adjacency_mat::SparseMatrixCSC`: The sparse adjacency matrix representing the graph.

# Returns
- `g::SimpleGraph`: The constructed simple undirected graph.

"""
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