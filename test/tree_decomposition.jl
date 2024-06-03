using TamakiTreeWidth
using TamakiTreeWidth: isleaf, add_child!
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
    add_child!(tree, [4, 5, 6])
    add_child!(tree, [7, 8])
    add_child!(tree.children[1], [9, 10, 11, 12])

    @test treewidth(tree) == 1
end