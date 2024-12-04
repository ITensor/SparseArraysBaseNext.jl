# Rewrite `f(args...)` to `Derive.call(::AbstractInterface, f, args...)`.
# Similar to `Cassette.overdub`.
function call end

abstract type AbstractInterface end

AbstractInterface(interface::AbstractInterface) = interface
AbstractInterface(x) = AbstractInterface(typeof(x))
AbstractInterface(type::Type) = throw(MethodError(AbstractInterface, (type,)))

# TODO: Define interface promotion, maybe just use `BroadcastStyle` directly.
# https://docs.julialang.org/en/v1/manual/interfaces/#writing-binary-broadcasting-rules
AbstractInterface(::AbstractInterface, ::AbstractInterface) = error("Not implemented")

function AbstractInterface(::Interface, ::Interface) where {Interface<:AbstractInterface}
  return Interface()
end

function AbstractInterface(
  interface1::AbstractInterface,
  interface2::AbstractInterface,
  interface_rest::AbstractInterface...,
)
  return AbstractInterface(AbstractInterface(interface1, interface2), interface_rest...)
end
