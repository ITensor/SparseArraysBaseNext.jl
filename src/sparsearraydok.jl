# TODO: Define `AbstractSparseArray`, make this a subtype.
struct SparseArrayDOK{T,N} <: AbstractArray{T,N}
  storage::Dict{CartesianIndex{N},T}
  size::NTuple{N,Int}
end

function SparseArrayDOK{T}(size::Int...) where {T}
  N = length(size)
  return SparseArrayDOK{T,N}(Dict{CartesianIndex{N},T}(), size)
end

using .Derive: @wrappedtype
# Define `WrappedSparseArrayDOK` and `AnySparseArrayDOK`.
@wrappedtype SparseArrayDOK

using .Derive: Derive
function Derive.AbstractInterface(::Type{<:SparseArrayDOK})
  return SparseArrayInterface()
end

## using .Derive: AbstractArrayOps, @derive
## @derive AnySparseArrayDOK AbstractArrayOps()

storage(a::SparseArrayDOK) = a.storage
Base.size(a::SparseArrayDOK) = a.size

storedvalues(a::SparseArrayDOK) = values(storage(a))
function isstored(a::SparseArrayDOK, I::Int...)
  return CartesianIndex(I) in keys(storage(a))
end
function eachstoredindex(a::SparseArrayDOK)
  return keys(storage(a))
end
function getstoredindex(a::SparseArrayDOK, I::Int...)
  return storage(a)[CartesianIndex(I)]
end
function getunstoredindex(a::SparseArrayDOK, I::Int...)
  return zero(eltype(a))
end
function setstoredindex!(a::SparseArrayDOK, value, I::Int...)
  storage(a)[CartesianIndex(I)] = value
  return a
end
function setunstoredindex!(a::SparseArrayDOK, value, I::Int...)
  storage(a)[CartesianIndex(I)] = value
  return a
end

# Optional, but faster than the default.
storedpairs(a::SparseArrayDOK) = storage(a)

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
