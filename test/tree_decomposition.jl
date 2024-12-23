using TreeWidthSolver: isleaf, add_child!

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

    @test width(tree) == 3
end

@testset "order2tree" begin
    g = smallgraph(:petersen)
    eo = elimination_order(g)
    td = decomposition_tree(g, eo)
    td_2 = decomposition_tree(g, vcat(eo...))
    tree = decomposition_tree(g).tree
    @test td == tree
    @test td == td_2

    @test is_treedecomposition(g, td)
    @test is_treedecomposition(g, td_2)
end
