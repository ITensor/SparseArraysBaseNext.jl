# TODO: Add `ndims` type parameter.
struct DefaultArrayInterface <: AbstractArrayInterface end

using TypeParameterAccessors: parenttype
function AbstractInterface(a::Type{<:AbstractArray})
  parenttype(a) === a && return DefaultArrayInterface()
  return AbstractInterface(parenttype(a))
end
