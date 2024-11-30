abstract type AbstractInterface end

AbstractInterface(interface::AbstractInterface) = interface
AbstractInterface(x) = AbstractInterface(typeof(x))
# TODO: Throw a `MethodError` instead.
AbstractInterface(type::Type) = error("Not implemented")

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
