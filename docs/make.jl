using TamakiTreeWidth
using Documenter

DocMeta.setdocmeta!(TamakiTreeWidth, :DocTestSetup, :(using TamakiTreeWidth); recursive=true)

makedocs(;
    modules=[TamakiTreeWidth],
    authors="Xuanzhao Gao <gaoxuanzhao@gmail.com> and contributors",
    sitename="TamakiTreeWidth.jl",
    format=Documenter.HTML(;
        canonical="https://ArrogantGao.github.io/TamakiTreeWidth.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ArrogantGao/TamakiTreeWidth.jl",
    devbranch="main",
)
