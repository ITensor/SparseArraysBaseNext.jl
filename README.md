# SparseArraysBaseNext.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ITensor.github.io/SparseArraysBaseNext.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ITensor.github.io/SparseArraysBaseNext.jl/dev/)
[![Build Status](https://github.com/ITensor/SparseArraysBaseNext.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ITensor/SparseArraysBaseNext.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ITensor/SparseArraysBaseNext.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ITensor/SparseArraysBaseNext.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Installation instructions

```julia
julia> using Pkg: Pkg

julia> Pkg.add(url="https://github.com/ITensor/SparseArraysBaseNext.jl")
```

## Examples

````julia
using SparseArraysBaseNext:
  AnySparseArrayDOK,
  SparseArrayDOK,
  eachstoredindex,
  isstored,
  storedlength,
  storedpairs,
  storedvalues
using Test: @test

using Derive: @derive, @interface
using SparseArraysBaseNext: SparseArrayInterface

# @derive SparseArrayInterface() begin
#   Base.getindex(::SparseArrayDOK, ::Int...)
#   Base.setindex!(::SparseArrayDOK, ::Any, ::Int...)
# end

# @derive SparseArrayInterface() begin
#   Base.getindex(::SparseArrayDOK, ::Int...)
#   Base.setindex!(::SparseArrayDOK, ::Any, ::Int...)
# end

# @derive SparseArrayInterface() Base.getindex(::SparseArrayDOK, ::Int...)
# @derive SparseArrayInterface() Base.setindex!(::SparseArrayDOK, ::Any, ::Int...)

# @derive (T=SparseArrayDOK,) begin
#   Base.getindex(::T, ::Int...)
#   Base.setindex!(::T, ::Any, ::Int...)
# end

# @derive (T=SparseArrayDOK,) Base.getindex(::T, ::Int...)
# @derive (T=SparseArrayDOK,) Base.setindex!(::T, ::Any, ::Int...)

# @derive SparseArrayInterface() (T=SparseArrayDOK,) begin
#   Base.getindex(::T, ::Int...)
#   Base.setindex!(::T, ::Any, ::Int...)
# end

# @derive SparseArrayInterface() (T=SparseArrayDOK,) Base.getindex(::T, ::Int...)
# @derive SparseArrayInterface() (T=SparseArrayDOK,) Base.setindex!(::T, ::Any, ::Int...)
````

TODO: Pre-defined sets of overloads. To implement.

````julia
# @derive SparseArrayInterface() AnySparseArrayDOK AbstractArrayOps

@derive AnySparseArrayDOK AbstractArrayOps

a = SparseArrayDOK{Float64}(2, 2)

@show @interface SparseArrayInterface() a[1, 1]
@show SparseArrayInterface()(getindex)(a, 1, 1)

@show a[1, 1]

a[1, 2] = 12
a[2, 1] = 21
@test a[1, 1] == 0
@test a[2, 1] == 21
@test a[1, 2] == 12
@test a[2, 2] == 0

b = a .+ 2 .* a'
@test b[1, 1] == 0
@test b[2, 1] == 21 + 2 * 12
@test b[1, 2] == 12 + 2 * 21
@test b[2, 2] == 0
@test issetequal(storedvalues(b), [21 + 2 * 12, 12 + 2 * 21])
@test issetequal(eachstoredindex(b), [CartesianIndex(2, 1), CartesianIndex(1, 2)])
@test storedpairs(b) ==
  Dict(CartesianIndex(2, 1) => 21 + 2 * 12, CartesianIndex(1, 2) => 12 + 2 * 21)
@test !isstored(b, 1, 1)
@test isstored(b, 2, 1)
@test isstored(b, 1, 2)
@test !isstored(b, 2, 2)
@test storedlength(b) == 2

c = a * a'
@test storedlength(c) == 2
@test c == [12*12 0; 0 21*21]
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

