# Like the equivalent `Base` functions but allow overloading
# by interface in the first argument.
# Overloading `Base` directly leads to too many method ambiguities.
# Maybe we can make `Interface.f` instead of `interface_f` in the future
# but that is tricky with namespacing issues.
# TODO: Define generic fallbacks that use `invoke`.
function interface_getindex end
function interface_setindex! end
function interface_similar end
function interface_map end
function interface_map! end
function interface_BroadcastStyle end

# TODO: Add `ndims` type parameter.
abstract type AbstractArrayInterface <: AbstractInterface end

function AbstractArrayOps()
  return (
    AbstractArrayGetIndex(),
    AbstractArraySetIndex(),
    AbstractArraySimilar(),
    AbstractArrayMap(),
    AbstractArrayBroadcast(),
  )
end

struct AbstractArrayGetIndex <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayGetIndex)
  return quote
    function Base.getindex(a::$type, I::Int...)
      return interface_getindex($AbstractInterface(a), a, I...)
    end
  end
end

struct AbstractArraySetIndex <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArraySetIndex)
  return quote
    function Base.setindex!(a::$type, value, I::Int...)
      interface_setindex!($AbstractInterface(a), a, value, I...)
      return a
    end
  end
end

struct AbstractArraySimilar <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArraySimilar)
  return quote
    # TODO: Generalize to axes.
    function Base.similar(a::$type, T::Type, I::Tuple{Vararg{Int}})
      return interface_similar($AbstractInterface(a), a, T, I)
    end
  end
end

struct AbstractArrayMap <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayMap)
  return quote
    function Base.map(f, as::$type...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      return interface_map($AbstractInterface($AbstractInterface.(as)...), f, as...)
    end
    function Base.map!(f, dest::$type, as::AbstractArray...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      interface_map!($AbstractInterface($AbstractInterface.(as)...), f, dest, as...)
      return dest
    end
  end
end

struct AbstractArrayBroadcast <: AbstractArrayInterface end

function derive(type::Type, ::AbstractArrayBroadcast)
  return quote
    function Base.BroadcastStyle(type::Type{<:$type})
      return interface_BroadcastStyle($AbstractInterface(type), type)
    end
  end
end
