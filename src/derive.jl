macro derive(type, interfaces...)
  return esc(derive(type, interfaces))
end

# TODO: Use `TupleTools.jl`.
tuple_cat(t1::Tuple, t2::Tuple) = (t1..., t2...)
tuple_cat(t1::Tuple, t2) = (t1..., t2)
tuple_cat(t1, t2::Tuple) = (t1, t2...)
tuple_cat(t1, t2) = (t1, t2)
tuple_flatten(t::Tuple) = reduce(tuple_cat, t)

function derive(type::Union{Symbol,Expr}, interfaces::Tuple{Vararg{Symbol}})
  return derive(eval(type), tuple_flatten(map(interface -> eval(interface)(), interfaces)))
end

function derive(types::Tuple{Vararg{Type}}, interfaces::Tuple)
  return derive(Union{types...}, interfaces::Tuple)
end

function derive(type_or_types::Union{Type,Tuple{Vararg{Type}}}, interfaces::Tuple)
  expr = Expr(:block)
  for interface in interfaces
    subexpr = derive(type_or_types, interface)
    expr = Expr(:block, expr.args..., subexpr.args...)
  end
  return expr
end
