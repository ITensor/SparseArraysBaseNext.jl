struct SparseArrayDOK{T,N} <: AbstractArray{T,N}
  storedvalues::Dict{CartesianIndex{N},T}
  size::NTuple{N,Int}
end

function SparseArrayDOK{T}(size::Int...) where {T}
  N = length(size)
  return SparseArrayDOK{T,N}(Dict{CartesianIndex{N},T}(), size)
end

AbstractInterface(::Type{<:SparseArrayDOK}) = SparseArrayInterface()

@derive AnyArrays(SparseArrayDOK) AbstractArrayOps

Base.size(a::SparseArrayDOK) = a.size

storedvalues(a::SparseArrayDOK) = a.storedvalues
function isstored(a::SparseArrayDOK, I::Int...)
  return CartesianIndex(I) in keys(storedvalues(a))
end
function eachstoredindex(a::SparseArrayDOK)
  return keys(storedvalues(a))
end
function getstoredindex(a::SparseArrayDOK, I::Int...)
  return storedvalues(a)[CartesianIndex(I)]
end
function getunstoredindex(a::SparseArrayDOK, I::Int...)
  return zero(eltype(a))
end
function setstoredindex!(a::SparseArrayDOK, value, I::Int...)
  storedvalues(a)[CartesianIndex(I)] = value
  return a
end
function setunstoredindex!(a::SparseArrayDOK, value, I::Int...)
  storedvalues(a)[CartesianIndex(I)] = value
  return a
end

using LinearAlgebra: Adjoint
storedvalues(a::Adjoint) = storedvalues(parent(a))
function isstored(a::Adjoint, i::Int, j::Int)
  return isstored(parent(a), j, i)
end
function eachstoredindex(a::Adjoint)
  # TODO: Make lazy with `Iterators.map`.
  return map(CartesianIndex ∘ reverse ∘ Tuple, collect(eachstoredindex(parent(a))))
end
function getstoredindex(a::Adjoint, i::Int, j::Int)
  return getstoredindex(parent(a), j, i)'
end
function getunstoredindex(a::Adjoint, i::Int, j::Int)
  return getunstoredindex(parent(a), j, i)'
end
function setstoredindex!(a::Adjoint, value, i::Int, j::Int)
  setstoredindex!(parent(a), value', j, i)
  return a
end
function setunstoredindex!(a::Adjoint, value, i::Int, j::Int)
  setunstoredindex!(parent(a), value', j, i)
  return a
end
