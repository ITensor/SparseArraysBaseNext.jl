# Minimal interface for `SparseArrayInterface`.
storedvalues(a) = error()
isstored(a, I::Int...) = error()
eachstoredindex(a) = error()
getstoredindex(a, I::Int...) = error()
getunstoredindex(a, I::Int...) = error()
setstoredindex!(a, value, I::Int...) = error()
setunstoredindex!(a, value, I::Int...) = error()

# Derived interface.
storedlength(a) = length(storedvalues(a))

function eachstoredindex(a1, a2, a_rest...)
  # TODO: Make this more customizable, say with a function
  # `combine/promote_storedindices(a1, a2)`.
  return union(eachstoredindex.((a1, a2, a_rest...))...)
end

# TODO: Add `ndims` type parameter.
struct SparseArrayInterface <: AbstractArrayInterface end

function interface_getindex(::SparseArrayInterface, a, I::Int...)
  !isstored(a, I...) && return getunstoredindex(a, I...)
  return getstoredindex(a, I...)
end

function interface_setindex!(::SparseArrayInterface, a, value, I::Int...)
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
function interface_similar(::SparseArrayInterface, a, T::Type, size::Tuple{Vararg{Int}})
  return SparseArrayDOK{T}(size...)
end

## TODO: Make this more general, handle mixtures of integers and ranges.
## TODO: Make this logic generic to all `similar(::AbstractInterface, ...)`.
## function interface_similar(interface::SparseArrayInterface, a, T::Type, dims::Tuple{Vararg{Base.OneTo}})
##   return similar(interface, a, T, Base.to_shape(dims))
## end

function interface_map(::SparseArrayInterface, f, as...)
  # This is defined in this way so we can rely on the Broadcast logic
  # for determining the destination of the operation (element type, shape, etc.).
  return f.(as...)
end

function interface_map!(::SparseArrayInterface, f, dest, as...)
  # Check `f` preserves zeros.
  # Define as `map_stored!`.
  # Define `eachstoredindex` promotion.
  for I in eachstoredindex(as...)
    dest[I] = f(map(a -> a[I], as)...)
  end
  return dest
end

struct SparseArrayStyle{N} <: Broadcast.AbstractArrayStyle{N} end

SparseArrayStyle{M}(::Val{N}) where {M,N} = SparseArrayStyle{N}()

function interface_BroadcastStyle(::SparseArrayInterface, type::Type)
  return SparseArrayStyle{ndims(type)}()
end

function Base.similar(bc::Broadcast.Broadcasted{<:SparseArrayStyle}, T::Type, axes::Tuple)
  # TODO: Allow `similar` to accept `axes` directly.
  return interface_similar(SparseArrayInterface(), bc, T, Int.(length.(axes)))
end

using BroadcastMapConversion: map_function, map_args
# TODO: Look into `SparseArrays.capturescalars`:
# https://github.com/JuliaSparse/SparseArrays.jl/blob/1beb0e4a4618b0399907b0000c43d9f66d34accc/src/higherorderfns.jl#L1092-L1102
function Base.copyto!(dest::AbstractArray, bc::Broadcast.Broadcasted{<:SparseArrayStyle})
  interface_map!(SparseArrayInterface(), map_function(bc), dest, map_args(bc)...)
  return dest
end
