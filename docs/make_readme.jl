using Literate: Literate
using SparseArraysBaseNext: SparseArraysBaseNext

Literate.markdown(
  joinpath(pkgdir(SparseArraysBaseNext), "examples", "README.jl"),
  joinpath(pkgdir(SparseArraysBaseNext));
  flavor=Literate.CommonMarkFlavor(),
  name="README",
)
