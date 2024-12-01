macro derive(type, interface)
  return esc(derive(type, interface))
end

function derive(type::Union{Symbol,Expr}, interface::Union{Symbol,Expr})
  return derive(eval(type), eval(interface))
end

function derive(type::Type, interfaces::Tuple)
  expr = Expr(:block)
  for interface in interfaces
    subexpr = derive(type, interface)
    expr = Expr(:block, expr.args..., subexpr.args...)
  end
  return expr
end
