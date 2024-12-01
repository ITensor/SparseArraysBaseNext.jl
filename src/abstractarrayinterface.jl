# Like the equivalent `Base` functions but allow overloading
# by interface in the first argument.
# Overloading `Base` directly leads to too many method ambiguities.
# TODO: Define generic fallbacks that use `invoke`.
function getindex end
function setindex! end
function similar end
function map end
function map! end
function BroadcastStyle end
function MemoryLayout end
function mul! end

# TODO: Add `ndims` type parameter.
abstract type AbstractArrayInterface <: AbstractInterface end

function AbstractArrayOps()
  return (
    AbstractArrayGetIndex(),
    AbstractArraySetIndex(),
    AbstractArraySimilar(),
    AbstractArrayMap(),
    AbstractArrayBroadcast(),
    AbstractArrayMemoryLayout(),
    AbstractArrayMul(),
  )
end

struct AbstractArrayGetIndex <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayGetIndex)
  return quote
    # TODO: Use `ArrayLayouts.layout_getindex`, `ArrayLayouts.sub_materialize`
    # to handle slicing (implemented by copying SubArray).
    function Base.getindex(a::$type, I::Int...)
      return $getindex($AbstractInterface(a), a, I...)
    end
  end
end

struct AbstractArraySetIndex <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArraySetIndex)
  return quote
    function Base.setindex!(a::$type, value, I::Int...)
      $setindex!($AbstractInterface(a), a, value, I...)
      return a
    end
  end
end

struct AbstractArraySimilar <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArraySimilar)
  return quote
    # TODO: Generalize to axes.
    function Base.similar(a::$type, T::Type, I::Tuple{Vararg{Int}})
      return $similar($AbstractInterface(a), a, T, I)
    end
  end
end

struct AbstractArrayMap <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayMap)
  return quote
    function Base.map(f, as::$type...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      return $map($AbstractInterface($AbstractInterface.(as)...), f, as...)
    end
    function Base.map!(f, dest::$type, as::AbstractArray...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      $map!($AbstractInterface($AbstractInterface.(as)...), f, dest, as...)
      return dest
    end
  end
end

struct AbstractArrayBroadcast <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayBroadcast)
  return quote
    function Base.BroadcastStyle(type::Type{<:$type})
      return $BroadcastStyle($AbstractInterface(type), type)
    end
  end
end

struct AbstractArrayMemoryLayout <: AbstractArrayInterface end

using ArrayLayouts: ArrayLayouts
function derive(type::Type, ::AbstractArrayMemoryLayout)
  return quote
    function $ArrayLayouts.MemoryLayout(type::Type{<:$type})
      return $MemoryLayout($AbstractInterface(type), type)
    end
  end
end

struct AbstractArrayMul <: AbstractArrayInterface end

using LinearAlgebra: LinearAlgebra
function derive(type::Type, ::AbstractArrayMul)
  return quote
    function $LinearAlgebra.mul!(dest::$type, a::$type, b::$type, α::Number, β::Number)
      return $mul!($AbstractInterface(a), dest, a, b, α, β)
    end
  end
end
