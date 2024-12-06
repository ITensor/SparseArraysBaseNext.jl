module SparseArraysBaseNext

include("lib/Derive/Derive.jl")
using .Derive: Derive
include("sparsearrayinterface.jl")
include("wrappers.jl")
include("sparsearraydok.jl")

end
