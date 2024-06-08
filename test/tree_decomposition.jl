using TamakiTreeWidth
using TamakiTreeWidth: isleaf, add_child!, decomposition_tree
using Graphs
using Test

@testset "tree decompositions" begin
    n1 = DecompositionTreeNode([1, 2, 3])
    n2 = DecompositionTreeNode(Set([1, 2, 3]))
    @test isleaf(n1)
    @test n1 == n2
    n3 = DecompositionTreeNode([1.0, 2.0, 3.0])
    @test n1 != n3

    add_child!(n1, [4, 5, 6])
    n1c = copy(n1)
    @test n1 == n1c

    tree = DecompositionTreeNode([1, 2, 3])
    add_child!(tree, [2, 3, 4])
    add_child!(tree, [1, 3, 5, 6])
    add_child!(tree.children[1], [4, 7])
    add_child!(tree.children[1], [4, 8, 9])

    @test treewidth(tree) == 3

    edges = [(1, 2), (2, 3), (1, 3), (3, 4), (4, 5), (5, 6), (4, 6)]
    g = SimpleGraph(6)
    for (src, dst) in edges
        add_edge!(g, src, dst)
    end
    lg = LabeledSimpleGraph(g)
    elimi = EliminationOrder([1, 2, 5, 6, 3, 4])
    tree = decomposition_tree(elimi, lg, root = 3)

    tree_exact = DecompositionTreeNode([4, 3])
    add_child!(tree_exact, [1, 2, 3])
    add_child!(tree_exact, [4, 5, 6])
    @test tree == tree_exact
end