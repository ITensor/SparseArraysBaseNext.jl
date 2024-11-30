using Literate: Literate
using SparseArraysBaseNext: SparseArraysBaseNext

Literate.markdown(
  joinpath(pkgdir(SparseArraysBaseNext), "examples", "README.jl"),
  joinpath(pkgdir(SparseArraysBaseNext), "docs", "src");
  flavor=Literate.DocumenterFlavor(),
  name="index",
)
