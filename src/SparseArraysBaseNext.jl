module SparseArraysBaseNext

include("lib/InterfaceImplementations/InterfaceImplementations.jl")
using .InterfaceImplementations: InterfaceImplementations
include("sparsearrayinterface.jl")
include("sparsearraydok.jl")

end
