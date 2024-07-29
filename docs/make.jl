using TreeWidthSolver
using Documenter

DocMeta.setdocmeta!(TreeWidthSolver, :DocTestSetup, :(using TreeWidthSolver); recursive=true)

makedocs(;
    modules=[TreeWidthSolver],
    authors="Xuanzhao Gao <gaoxuanzhao@gmail.com> and contributors",
    sitename="TreeWidthSolver.jl",
    format=Documenter.HTML(;
        canonical="https://ArrogantGao.github.io/TreeWidthSolver.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ArrogantGao/TreeWidthSolver.jl",
    devbranch="main",
)
