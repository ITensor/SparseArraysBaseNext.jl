#=
Rewrite `f(args...)` to `Derive.call(interface, f, args...)`.
Similar to `Cassette.overdub`.

This errors for debugging, but probably should be defined as:
```julia
call(interface, f, args...) = f(args...)
```
=#
call(interface, f, args...) = error("Not implemented")

# Change the behavior of a function to use a certain interface.
struct InterfaceFunction{Interface,F} <: Function
  interface::Interface
  f::F
end
(f::InterfaceFunction)(args...) = call(f.interface, f.f, args...)
