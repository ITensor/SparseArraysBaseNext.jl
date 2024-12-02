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
    Base.getindex,
    Base.setindex!,
    Base.similar,
    Base.map,
    Base.map!,
    Base.Broadcast.BroadcastStyle,
    ArrayLayouts.MemoryLayout,
    LinearAlgebra.mul!,
  )
end

function derive(op::typeof(Base.getindex), interface::AbstractArrayInterface, type::Type)
  return quote
    # TODO: Use `ArrayLayouts.layout_getindex`, `ArrayLayouts.sub_materialize`
    # to handle slicing (implemented by copying SubArray).
    function Base.getindex(a::$type, I::Int...)
      return $getindex($interface, a, I...)
    end
  end
end
function derive(op::typeof(Base.getindex), type::Type)
  return quote
    function Base.getindex(a::$type, I::Int...)
      return $getindex($AbstractInterface(a), a, I...)
    end
  end
end

function derive(op::typeof(Base.setindex!), interface::AbstractArrayInterface, type::Type)
  return quote
    function Base.setindex!(a::$type, value, I::Int...)
      $setindex!($interface, a, value, I...)
      return a
    end
  end
end
function derive(op::typeof(Base.setindex!), type::Type)
  return quote
    function Base.setindex!(a::$type, value, I::Int...)
      $setindex!($AbstractInterface(a), a, value, I...)
      return a
    end
  end
end

function derive(op::typeof(Base.similar), interface::AbstractArrayInterface, type::Type)
  return quote
    # TODO: Generalize to axes.
    function Base.similar(a::$type, T::Type, I::Tuple{Vararg{Int}})
      return $similar($interface, a, T, I)
    end
  end
end
function derive(op::typeof(Base.similar), type::Type)
  return quote
    # TODO: Generalize to axes.
    function Base.similar(a::$type, T::Type, I::Tuple{Vararg{Int}})
      return $similar($AbstractInterface(a), a, T, I)
    end
  end
end

function derive(op::typeof(Base.map), interface::AbstractArrayInterface, type::Type)
  return quote
    function Base.map(f, as::$type...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      return $map($interface, f, as...)
    end
  end
end
function derive(op::typeof(Base.map), type::Type)
  return quote
    function Base.map(f, as::$type...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      return $map($AbstractInterface(AbstractInterface.(as)...), f, as...)
    end
  end
end

function derive(op::typeof(Base.map!), interface::AbstractArrayInterface, type::Type)
  return quote
    function Base.map!(f, dest::$type, as::AbstractArray...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      $map!($interface, f, dest, as...)
      return dest
    end
  end
end
function derive(op::typeof(Base.map!), type::Type)
  return quote
    function Base.map!(f, dest::$type, as::AbstractArray...)
      # TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
      # https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
      $map!($AbstractInterface(AbstractInterface.(as)...), f, dest, as...)
      return dest
    end
  end
end

function derive(
  op::Type{Base.Broadcast.BroadcastStyle}, interface::AbstractArrayInterface, type::Type
)
  return quote
    function Base.Broadcast.BroadcastStyle(type::Type{<:$type})
      return $BroadcastStyle($interface, type)
    end
  end
end
function derive(op::Type{Base.Broadcast.BroadcastStyle}, type::Type)
  return quote
    function Base.Broadcast.BroadcastStyle(type::Type{<:$type})
      return $BroadcastStyle($AbstractInterface(type), type)
    end
  end
end

using ArrayLayouts: ArrayLayouts
function derive(
  op::Type{ArrayLayouts.MemoryLayout}, interface::AbstractArrayInterface, type::Type
)
  return quote
    function $ArrayLayouts.MemoryLayout(type::Type{<:$type})
      return $MemoryLayout($interface, type)
    end
  end
end
function derive(op::Type{ArrayLayouts.MemoryLayout}, type::Type)
  return quote
    function $ArrayLayouts.MemoryLayout(type::Type{<:$type})
      return $MemoryLayout($AbstractInterface(type), type)
    end
  end
end

using LinearAlgebra: LinearAlgebra
function derive(
  op::typeof(LinearAlgebra.mul!), interface::AbstractArrayInterface, type::Type
)
  return quote
    function $LinearAlgebra.mul!(dest::$type, a::$type, b::$type, α::Number, β::Number)
      # TODO: Determine from `a` and `b`.
      return $mul!($interface, dest, a, b, α, β)
    end
  end
end
function derive(op::typeof(LinearAlgebra.mul!), type::Type)
  return quote
    function $LinearAlgebra.mul!(dest::$type, a::$type, b::$type, α::Number, β::Number)
      # TODO: Determine from `a` and `b`.
      return $mul!(
        $AbstractInterface(
          $AbstractInterface(dest), $AbstractInterface(a), $AbstractInterface(b)
        ),
        dest,
        a,
        b,
        α,
        β,
      )
    end
  end
end
