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
  SparseArrayDOK, eachstoredindex, isstored, storedlength, storedvalues

a = SparseArrayDOK{Float64}(2, 2)
a[1, 2] = 12
@show a[1, 1]
@show a[1, 2]
b = a .+ 2 .* a'
@show storedvalues(b)
@show eachstoredindex(b)
@show isstored(b, 1, 1)
@show isstored(b, 2, 1)
@show isstored(b, 1, 2)
@show isstored(b, 2, 2)
@show storedlength(b)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

