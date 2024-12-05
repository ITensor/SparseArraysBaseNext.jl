using ExproniconLite: JLFunction, codegen_ast, split_function, split_function_head
using MLStyle: @λ, @match

# Remove lines from a block.
# See: https://thautwarm.github.io/MLStyle.jl/stable/syntax/pattern/#Ast-Pattern-1
# TODO: Use this type of function to replace `Derive.f` with `GlobalRef(Derive, f)`
# and also replace `T` with `SparseArrayDOK`.
function rmlines(expr)
  return @match expr begin
    e::Expr => Expr(e.head, filter(!isnothing, map(rmlines, e.args))...)
    _::LineNumberNode => nothing
    a => a
  end
end

function globalref_derive(expr)
  return @match expr begin
    :(Derive.$f) => :($(GlobalRef(Derive, :($f))))
    e::Expr => Expr(e.head, map(globalref_derive, e.args)...)
    a => a
  end
end

macro derive(interface, funcs)
  return esc(derive_expr(interface, funcs))
end

function derive_trait(interface::Symbol, trait::Symbol)
  trait isa Symbol || error("Must be a Symbol.")
  funcs = Expr(:block, derive(Val(trait)))
  @show interface
  @show funcs
  error("Not implemented.")
  return derive_funcs(interface, funcs)
end

#==
```julia
@derive SparseArrayInterface Base.getindex(::SparseArrayDOK, ::Int...)

@derive SparseArrayInterface begin
  Base.getindex(::SparseArrayDOK, ::Int...)
  Base.setindex!(::SparseArrayDOK, ::Any, ::Int...)
end

@derive (T=SparseArrayDOK,) Base.getindex(::T, ::Int...)

@derive (T=SparseArrayDOK,) begin
  Base.getindex(::T, ::Int...)
  Base.setindex!(::T, ::Any, ::Int...)
end
```
==#
function derive_expr(interface_or_types::Union{Symbol,Expr}, funcs::Expr)
  return @match funcs begin
    Expr(:call, _...) => derive_func(interface_or_types, funcs)
    Expr(:block, _...) => derive_funcs(interface_or_types, funcs)
  end
end

#==
```julia
@derive SparseArrayDOK AbstractArrayOps
```
==#
function derive_expr(type::Union{Symbol,Expr}, trait::Symbol)
  return derive_trait(type, trait)
end

#==
```julia
@derive SparseArrayInterface SparseArrayDOK AbstractArrayOps
```
==#
function derive_expr(interface::Symbol, type::Union{Symbol,Expr}, trait::Symbol)
  return derive_trait(interface, type, trait)
end

function derive_funcs(interface_or_types::Union{Symbol,Expr}, funcs::Expr)
  Meta.isexpr(funcs, :block) || error("Expected a block.")
  funcs = rmlines(funcs)
  return Expr(:block, map(func -> derive_func(interface_or_types, func), funcs.args)...)
end

#==
```julia
@derive SparseArrayInterface Base.getindex(::SparseArrayDOK, ::Int...)
```
==#
function derive_func(interface::Symbol, func::Expr)
  return derive_interface_func(:($(interface)()), func)
end

argname(i::Int) = Symbol(:arg, i)

function derive_interface_func(interface::Union{Symbol,Expr}, func::Expr)
  name, args, kwargs, whereparams, rettype = split_function_head(func)
  argnames = map(argname, 1:length(args))
  named_args = map(1:length(args)) do i
    argname, arg = argnames[i], args[i]
    return @match arg begin
      :(::$T) => :($argname::$T)
      :(::$T...) => :($argname::$T...)
    end
  end
  # TODO: Insert `interface` as first argument.
  body_args = map(1:length(args)) do i
    argname, arg = argnames[i], args[i]
    return @match arg begin
      :(::$T) => :($argname)
      :(::$T...) => :($argname...)
    end
  end
  body_args = [interface; name; body_args...]
  body_name = @match name begin
    :($M.$f) => :(Derive.call)
  end
  # TODO: Remove defaults from `kwargs`.
  _, body, _ = split_function(
    codegen_ast(JLFunction(; name=body_name, args=body_args, kwargs))
  )
  jlfn = JLFunction(; name, args=named_args, kwargs, whereparams, rettype, body)
  # Use `globalref_derive` to not require having `Derive` in the
  # namespace when `@derive` is called.
  return globalref_derive(codegen_ast(jlfn))
end

function derive_func(types::Expr, func::Expr)
  Meta.isexpr(types, :tuple) && all(arg -> Meta.isexpr(arg, :(=)), types.args) ||
    error("Wrong types format.")
  name, args, kwargs, whereparams, rettype = split_function_head(func)
  new_args = args
  for type_expr in types.args
    typevar, type = @match type_expr begin
      :($x = $y) => (x, y)
    end
    new_args = map(args) do arg
      return @match arg begin
        :(::$T) => T == typevar ? :(::$type) : :(::$T)
        :(::$T...) => T == typevar ? :(::$type...) : :(::$T...)
      end
    end
  end
  active_argnames = map(argname, findall(args .≠ new_args))
  interface = globalref_derive(:(Derive.AbstractInterface(Derive.AbstractInterface.(($(active_argnames...),))...)))
  _, func, _ = split_function(
    codegen_ast(JLFunction(; name, args=new_args, kwargs, whereparams, rettype))
  )
  return derive_interface_func(interface, func)
end

function derive(::Val{:AbstractArrayOps})
  return quote
    Base.getindex(::T, ::Int...)
    Base.setindex!(::T, ::Any, ::Int...)
  end
end
