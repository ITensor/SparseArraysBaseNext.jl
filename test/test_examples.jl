@eval module $(gensym())
using SparseArraysBaseNext: SparseArraysBaseNext
using Test: @test, @testset

@testset "examples" begin
  include(joinpath(pkgdir(SparseArraysBaseNext), "examples", "README.jl"))
end
end
