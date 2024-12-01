using Adapt: WrappedArray

function WrappedArrayType(type::Type)
  return WrappedArray{<:Any,<:Any,type,type{<:Any,<:Any}}
end

function AnyArrayType(type::Type)
  return Union{type{<:Any,<:Any},WrappedArrayType(type)}
end
