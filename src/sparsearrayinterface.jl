# Minimal interface for `SparseArrayInterface`.
# TODO: Define default definitions for these based
# on the dense case.
storedvalues(a) = error()
isstored(a, I::Int...) = error()
eachstoredindex(a) = error()
getstoredindex(a, I::Int...) = error()
getunstoredindex(a, I::Int...) = error()
setstoredindex!(a, value, I::Int...) = error()
setunstoredindex!(a, value, I::Int...) = error()

# Derived interface.
storedlength(a) = length(storedvalues(a))
storedpairs(a) = map(I -> I => getstoredindex(a, I), eachstoredindex(a))

function eachstoredindex(a1, a2, a_rest...)
  # TODO: Make this more customizable, say with a function
  # `combine/promote_storedindices(a1, a2)`.
  return union(eachstoredindex.((a1, a2, a_rest...))...)
end

# TODO: Add `ndims` type parameter.
# TODO: Define `AbstractSparseArrayInterface`, make this a subtype.
using .Derive: AbstractArrayInterface
struct SparseArrayInterface <: AbstractArrayInterface end

# TODO: Use `ArrayLayouts.layout_getindex`, `ArrayLayouts.sub_materialize`
# to handle slicing (implemented by copying SubArray).
function Derive.getindex(::SparseArrayInterface, a, I::Int...)
  !isstored(a, I...) && return getunstoredindex(a, I...)
  return getstoredindex(a, I...)
end

function Derive.setindex!(::SparseArrayInterface, a, value, I::Int...)
  iszero(value) && return a
  if !isstored(a, I...)
    setunstoredindex!(a, value, I...)
    return a
  end
  setstoredindex!(a, value, I...)
  return a
end

# TODO: This may need to be defined in `sparsearraydok.jl`, after `SparseArrayDOK`
# is defined. And/or define `default_type(::SparseArrayStyle, T::Type) = SparseArrayDOK{T}`.
function Derive.similar(
  ::SparseArrayInterface, a, T::Type, size::Tuple{Vararg{Int}}
)
  return SparseArrayDOK{T}(size...)
end

## TODO: Make this more general, handle mixtures of integers and ranges.
## TODO: Make this logic generic to all `similar(::AbstractInterface, ...)`.
## function Derive.similar(interface::SparseArrayInterface, a, T::Type, dims::Tuple{Vararg{Base.OneTo}})
##   return Derive.similar(interface, a, T, Base.to_shape(dims))
## end

function Derive.map(::SparseArrayInterface, f, as...)
  # This is defined in this way so we can rely on the Broadcast logic
  # for determining the destination of the operation (element type, shape, etc.).
  return f.(as...)
end

function Derive.map!(::SparseArrayInterface, f, dest, as...)
  # Check `f` preserves zeros.
  # Define as `map_stored!`.
  # Define `eachstoredindex` promotion.
  for I in eachstoredindex(as...)
    dest[I] = f(Base.map(a -> a[I], as)...)
  end
  return dest
end

# TODO: Define `AbstractSparseArrayStyle`, make this a subtype.
struct SparseArrayStyle{N} <: Broadcast.AbstractArrayStyle{N} end

SparseArrayStyle{M}(::Val{N}) where {M,N} = SparseArrayStyle{N}()

function Derive.BroadcastStyle(::SparseArrayInterface, type::Type)
  return SparseArrayStyle{ndims(type)}()
end

function Base.similar(bc::Broadcast.Broadcasted{<:SparseArrayStyle}, T::Type, axes::Tuple)
  # TODO: Allow `similar` to accept `axes` directly.
  return Derive.similar(
    SparseArrayInterface(), bc, T, Int.(length.(axes))
  )
end

using BroadcastMapConversion: map_function, map_args
# TODO: Look into `SparseArrays.capturescalars`:
# https://github.com/JuliaSparse/SparseArrays.jl/blob/1beb0e4a4618b0399907b0000c43d9f66d34accc/src/higherorderfns.jl#L1092-L1102
function Base.copyto!(dest::AbstractArray, bc::Broadcast.Broadcasted{<:SparseArrayStyle})
  Derive.map!(
    SparseArrayInterface(), map_function(bc), dest, map_args(bc)...
  )
  return dest
end

using ArrayLayouts: ArrayLayouts, MatMulMatAdd

abstract type AbstractSparseLayout <: ArrayLayouts.MemoryLayout end

struct SparseLayout <: AbstractSparseLayout end

Derive.MemoryLayout(::SparseArrayInterface, type::Type) = SparseLayout()

function Derive.mul!(::SparseArrayInterface, a_dest, a1, a2, α, β)
  return ArrayLayouts.mul!(a_dest, a1, a2, α, β)
end

function mul_indices(I1::CartesianIndex{2}, I2::CartesianIndex{2})
  if I1[2] ≠ I2[1]
    return nothing
  end
  return CartesianIndex(I1[1], I2[2])
end

function default_mul!!(
  a_dest::AbstractMatrix,
  a1::AbstractMatrix,
  a2::AbstractMatrix,
  α::Number=true,
  β::Number=false,
)
  mul!(a_dest, a1, a2, α, β)
  return a_dest
end

function default_mul!!(
  a_dest::Number, a1::Number, a2::Number, α::Number=true, β::Number=false
)
  return a1 * a2 * α + a_dest * β
end

# a1 * a2 * α + a_dest * β
function sparse_mul!(
  a_dest::AbstractArray,
  a1::AbstractArray,
  a2::AbstractArray,
  α::Number=true,
  β::Number=false;
  (mul!!)=(default_mul!!),
)
  for I1 in eachstoredindex(a1)
    for I2 in eachstoredindex(a2)
      I_dest = mul_indices(I1, I2)
      if !isnothing(I_dest)
        a_dest[I_dest] = mul!!(a_dest[I_dest], a1[I1], a2[I2], α, β)
      end
    end
  end
  return a_dest
end

function ArrayLayouts.materialize!(
  m::MatMulMatAdd{<:AbstractSparseLayout,<:AbstractSparseLayout,<:AbstractSparseLayout}
)
  sparse_mul!(m.C, m.A, m.B, m.α, m.β)
  return m.C
end
