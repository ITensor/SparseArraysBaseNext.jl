macro derive(type, interface, ops)
  return esc(derive(__module__, ops, interface, type))
end

macro derive(type, ops)
  return esc(derive(__module__, ops, type))
end

function derive(mod::Module, ops::Union{Symbol,Expr}, type::Union{Symbol,Expr})
  return derive(Base.eval(mod, ops), Base.eval(mod, type))
end

function derive(
  mod::Module,
  ops::Union{Symbol,Expr},
  interface::Union{Symbol,Expr},
  type::Union{Symbol,Expr},
)
  return derive(Base.eval(mod, ops), Base.eval(mod, interface), Base.eval(mod, type))
end

function derive(ops::Tuple, args...)
  expr = Expr(:block)
  for op in ops
    subexpr = derive(op, args...)
    expr = Expr(:block, expr.args..., subexpr.args...)
  end
  return expr
end
