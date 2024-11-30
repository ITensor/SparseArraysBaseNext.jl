using LinearAlgebra: Adjoint, Transpose
function WrappedArrays(type::Type)
  return (
    Adjoint{<:Any,<:type},
    PermutedDimsArray{<:Any,<:Any,<:Any,<:Any,<:type},
    SubArray{<:Any,<:Any,<:type},
    Transpose{<:Any,<:type},
  )
end

function AnyArrays(type::Type)
  return (type, WrappedArrays(type)...)
end

function AnyArrays(types::Tuple)
  return tuple_flatten(AnyArrays.(types))
end
