# Jupyter

Jupyter is a notebook interface originally built for JUlia, PYThon and R (and by now many more languages). It is not too different from other notebook-based environments such as Mathematica, RStudio or Maple. 

A few things to note:

* Code is input in cells like this (press Shift+Enter to execute):


```julia
variable = "a value"
```




    "a value"



* Cells can be executed independently
* in any order
* but *the effects (e.g. changes in values of variables) apply everywhere*


```julia
variable
```




    "a value"



* If you want to start from scratch, deleting all variables and functions, you have to restart the kernel (menu item 'Kernel')

# Julia vs. R, Python, C++

While Julia is generally not difficult to learn there are some noteworthy differences to other common languages. The manual has a [good overview](https://docs.julialang.org/en/v1/manual/noteworthy-differences/), but I will give a brief introduction in the following.


## Syntax

Julia's syntax is pretty straightforward in most parts. A good compact introduction can be found [here](https://learnxinyminutes.com/docs/julia/), in the following I will quickly summarize the basics.

### Assignment

Like Python, C++ and in fact most common languages, Julia uses a single equality sign `=` for assignments. Unlike C++ type declarations for new variables are optional (see semantics below):

C++
```C
int a = 42
```

Python
```Python
a = 42
```

R
```R
a <- 42
```

Julia


```julia
a = 42
```




    42



### Identifiers and member access

Julia follows the conventions of most modern languages in that names can contain letters (which are defined quite broadly in Julia), numbers and underscores and members of composite types are accessed with `.`.

C++
```C
x = my_data.first_firstcolumn
// or if my_data2 is a pointer
x = my_data<-first_firstcolumn
```

Python
```Python
x = my_data.first_column
```

R is the outlier again
```
x <- my.data$first.column
```

Julia
```Julia
x = my_data.first_column # this will not work in a code cell as my_data does not exist at this point
æ = 42
```

### Function declaration

This is where languages tend to differ a bit.

C++
```C
int fun(int x)
{
    return 2 * x;
}
```

Python
```Python
def fun(x):
    return 2 * x
```

R
```R
fun <- function(x) {
    2 * x
    }
```

Julia


```julia
function fun(x) # note that we again do not declare types
    2 * x
end

# shorter version:

fun2(x) = 2 * x
```




    fun2 (generic function with 1 method)



### Arrays

Similar to Fortran and Matlab but other than most other popular languages Julia's arrays *start with an index of 1*. This is one of the most complained about quirks of Julia, but in my experience you get used to it pretty quickly. 

As many other scripting languages Julia has array literals that allow for easy declaration.


```julia
a = [1, 2, 3]        # create an integer array 
println(typeof(a))   # type is inferred

a[1] = 10            # 1-based indexing!
println(a)

push!(a, 4)          # append; many more functions in the manual
println(a)
```

    Array{Int64,1}
    [10, 2, 3]
    [10, 2, 3, 4]


This is not even remotely scratching the surface as Julia's arrays are extremely versatile and powerful. If you want to know more, I recommend reading the [section on arrays in the manual](https://docs.julialang.org/en/v1/manual/arrays/).

### Structs

Julia's compund types are similar to `struct`s in C. 


```julia
struct Species
    common_name :: String     # struct members should always have an explicit type
    scientific_name :: String
    domesticated :: Bool
end

chicken = Species("chicken", "Gallus gallus domesticus", true)
```




    Species("chicken", "Gallus gallus domesticus", true)



Note, however that they are immutable by default (i.e. contents can not be changed):


```julia
chicken.common_name = "Huhn"
```


    setfield! immutable struct of type Species cannot be changed

    

    Stacktrace:

     [1] setproperty!(::Species, ::Symbol, ::String) at ./Base.jl:34

     [2] top-level scope at In[7]:1

     [3] include_string(::Function, ::Module, ::String, ::String) at ./loading.jl:1091

     [4] execute_code(::String, ::String) at /home/martin/.julia/packages/IJulia/a1SNk/src/execute_request.jl:27

     [5] execute_request(::ZMQ.Socket, ::IJulia.Msg) at /home/martin/.julia/packages/IJulia/a1SNk/src/execute_request.jl:86

     [6] #invokelatest#1 at ./essentials.jl:710 [inlined]

     [7] invokelatest at ./essentials.jl:709 [inlined]

     [8] eventloop(::ZMQ.Socket) at /home/martin/.julia/packages/IJulia/a1SNk/src/eventloop.jl:8

     [9] (::IJulia.var"#15#18")() at ./task.jl:356


If we want to change the contents we have to declare the struct `mutable`:


```julia
mutable struct Pet
    name :: String
    species :: Species
    age :: Int
    owner :: String
end

# every struct automatically has a default constructor
# if we need others we have to overload it (see next section)
Pet(name, species, owner) = Pet(name, species, 0, owner)

my_daughters_chicken = Pet("Karen", chicken, "Clara")
my_daughters_chicken.age = 1
```




    1



## Semantics

Semantically Julia combines properties of dynamic languages such as Python and R with those of static languages such as C or C++. 

For a comprehensive understanding of Julia's semantics I recommend the [official manual](https://docs.julialang.org/en/v1/). Here I will give a quick overview of the main points needed to start implementing simple simulations.

### Function parameters

Function parameters in Julia are treated in a similar way to languages such as Java, R or Python but different to C or C++. This is not difficult to understand in practice but takes a bit of an effort to explain properly.

A variable in Julia is a tag that refers to a value somewhere in memory. Assigning a variable (with `=`) changes which piece of data a variable refers to. If a variable's data is immutable (e.g. if it's an `Int` or a `struct`) having *two variables* refer to the same piece of data is effectively undistinguishable from having two copies of the data. The data can not be changed and reassigning one variable (= making it refer to different data) does not affect the other.


```julia
struct Bla
    v :: Int
end

x = Bla(5)       # x now refers to an immutable Bla(5)
y = x
println(x)
x = Bla(7)       # x is reassigned to refer to a different value, the Bla(5) is unaffected
println(x, " ", y)
```

    Bla(5)
    Bla(7) Bla(5)


If two variables refer to the same *mutable* data (e.g. `Array` or `mutable struct`), however, the data can be changed and changes in one will be visible by the other.


```julia
x = [1, 2, 3]
y = x
println(x)
y[1] = 10
println(x)
```

    [1, 2, 3]
    [10, 2, 3]



```julia
mutable struct MBla
    v :: Int
end

x = MBla(5)
y = x
println(x)
y.v = 7
println(x)
```

    MBla(5)
    MBla(7)


This is important to keep in mind, as function calls simply create a new local variable for each parameter and make it refer to the same data as the parameter. This means:
* reassigning parameters in a function has no effect outside (redirect label to different data)
* functions can not change immutable variables (can't be changed directly and reassigning them doesn't affect the original)
* functions can change the content of mutable variables (changes to content are visible to other variables pointing to the same data)


```julia
triple(x) = (x = x*3)     # reassign local variable

simple = 14
triple(simple)
println(simple)           # function call did not change value
```

    14


The same holds actually true for any type of variable. Reassignment will never change the original:


```julia
complex = [14]            # reassigning a complex value similarly has no effect
triple(complex)           # as we again just change what the variable x *in the function*
println(complex)          # refers to
```

    [14]


What we can do instead is access the content of a complex variable and change its value:


```julia
triple_a(a) = (a[1] = a[1] * 3)
triple_a(complex)
println(complex)
```

    [42]


`triple_a` does not change which piece of data the local variable `a` refers to, but instead accesses the data itself (the first element of the array) and changes it. Since the global variable `complex` and the local variable `a` refer to the same piece of data the change is persistent.

This kind of behaviour is standard for languages such as Python or R, but can be a bit confusing at first for C/C++ programmers. The best way to understand it is maybe by imagining that function parameters are always pointers but that there is no way to directly dereference them, i.e. there is only member access.

### Types

Types are sorts of values in programming languages (think number versus text string). Most languages have them to some degree, but how they deal with them differs a lot.

Statically typed languages such as C or C++ assign a fixed type to every variable that can't be changed. This holds for function parameters as well. Therefore calling a function that expects an `int` using a variable that is of type `vector` will produce an error at compile time. This can make it a lot easier to find or avoid mistakes and - as a bonus - makes it easier for the compiler to produce optimized code. On the flip side it can be cumbersome to have to decide ahead of time and declare the type of each and every variable and function parameter.

In contrast to that Python and R sit on the dynamic end of the range. Variables don't have a fixed type and can change it during their lifetime by assigning different things to them. This means that programmer don't have to bother with type declarations but also that functions have no easy, builtin mechanism to make sure that a parameter they receive contains a type of data they can handle.

Julia combines both approaches in a pretty clever way. In principle, everything in Julia has a well-defined type. However, in contrast to C/C++ the type is not attached to *expressions at compile-time* but instead to *objects at run-time*. But, similar to C/C++ and other than e.g. Python, Julia *does* use type information to select which function to call in a given situation and to optimize code. It does that by inferring the type of function parameters and re-compiling (if necessary) the function *with these types*.


```julia
# this function will only work on Integers
mult(x::Int, y::Int) = x * y

# in most situations, however, generic functions are totally fine
mult2(x, y) = x * y

# Julia sees Integers and adds the types accordingly
a = mult2(2, 3)
println("a: ", typeof(a))

# but we can still use the same function with float
b = mult2(2.0, 3.0)
println("b: ", typeof(b))

# Note that for each combination of types a separate version 
# of mult2 will be generated internally and compiled to fast machine code. 
```

    a: Int64
    b: Float64


The huge advantage of this system and one the major pros of Julia is that it makes it possible to write programs without caring (too much) about types, similar to R or Python, while at the same time most (well-written) code can be compiled with inferred type information and thus be made nearly as efficient as C or C++.

### OOP

This is probably one of the two most difficult to accept idiosyncrasies of Julia for people coming from mainstream languages (the other is 1-based array indexing...). Other than nearly every other widely used language Julia explicitly does not support object-oriented programming (OOP). There are deep philosophical reasons for this, but in practical terms it means:

* no object-level encapsulation - struct members can be accessed and modified freely
* no object-based polymorphism; Julia instead has multi-methods (see below)
* no inheritance

Julia's type system is rich enough to compensate for this, but it might require some getting used to for someone who grew up in an OOP tradition.

### Multi-methods, methods vs. functions

I am not going to explain Julia's type system in depth, but multi-methods and the terminology around them need some elaboration. This is going to get a bit technical, so if you are not interested in the details just remember the following points and skip the rest of the section:
* A *function* in Julia refers to an entire group of functions that have the same name but differ with respect to type and/or number of parameters.
* A specific implementation of a function for a given combination of parameters is called a *method*.
* In a given situation the method with the best match in terms of parameter types is executed.

That's the gist of it. Read on if you want to know the details.

In some languages functions can be "overloaded", by having several functions with the same name that only differ in number and/or type of parameters. Which function is called or compiled then depends on the number and/or type of parameters at the call site. This is very useful as it allows for generic programming where an algorithm is expressed in terms of general functions and the concrete implementation depends on the type of the objects involved.

Generally speaking there are two points at which the "function selection" can happen - at compile time or at runtime. In C++ for example where expressions have a type at compile time a lot of overloading can be resolved at this stage. C++ *can* do function selection at runtime, but then only based on the *first argument of a function* (for methods declared as virtual).

Julia generalizes this concept (following a long tradition of LISP-based languages). A `function` in Julia is an entire class of callable objects with the same name. Each specific implementation of a function is called a `method`:


```julia
blabla(x) = x*2
```




    blabla (generic function with 1 method)




```julia
blabla(x::Int) = x*3
```




    blabla (generic function with 2 methods)



Therefore "overloading" a function (in the C++ sense) in Julia just adds a new method to the function object.

As in Julia types are associated with objects (in the non-OOP sense) and not with expressions, which of the methods of a function is called in a given situation conceptually has to happen at run-time. Which method is selected then depends on the specificity of the type of *all* arguments, i.e. basically the best match wins (this is called multi-methods).

So, from a C++ perspective we could say that all functions in Julia are virtual, but with all arguments being used to select the implementation to call.

All the theory aside, what this means in practice is that we can for example write a generic version of a function without type information and then add specialized versions with concrete types if necessary. Or we can write one version for all numeric types and one version for everything else.

(As an aside - dynamically typed languages such as Python or R can do this as well, but they have to do it manually. R uses this extensively, which is great for library users but not so great for implementers...)

# More information

* [Julia homepage](https://julialang.org)
* [official documentation](https://docs.julialang.org/en/v1/)
* [Discourse forum](https://discourse.julialang.org/) (active and friendly)
* [some benchmarks](https://julialang.org/benchmarks/) (R does not fare well there...)
* and of course [the source](https://github.com/JuliaLang/julia)


```julia

```
