@eval module $(gensym())
using SparseArraysBaseNext: SparseArraysBaseNext
using Aqua: Aqua
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
  # TODO: Reenable once dependencies are registered.
  # Aqua.test_all(SparseArraysBaseNext)
end
end
