using SparseArraysBaseNext: SparseArraysBaseNext
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
  SparseArraysBaseNext, :DocTestSetup, :(using SparseArraysBaseNext); recursive=true
)

include("make_index.jl")

makedocs(;
  modules=[SparseArraysBaseNext],
  authors="ITensor developers <support@itensor.org> and contributors",
  sitename="SparseArraysBaseNext.jl",
  format=Documenter.HTML(;
    canonical="https://ITensor.github.io/SparseArraysBaseNext.jl",
    edit_link="main",
    assets=String[],
  ),
  pages=["Home" => "index.md"],
)

deploydocs(;
  repo="github.com/ITensor/SparseArraysBaseNext.jl", devbranch="main", push_preview=true
)
