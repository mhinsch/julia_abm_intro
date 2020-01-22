
# Jupyter

Jupyter is a notebook interface originally built for JUlia, PYThon and R (and by now many more languages). It is not too different from RStudio. A few things to note:
* Code is input in cells like this:


```julia
variable = "a value"
```




    "a value"



* Cells can be executed independently
* in any order
* but *the effects (e.g. changes in values of variables) apply every*


```julia
variable
```




    "a value"



* If you want to start from scratch you have to restart the kernel (menu item 'Kernel')

# Julia vs. R

For our intents we can largely treat Julia as a "fast R". There are a few syntactic differences to be aware of, however:

### Assignment

```R
a <- 42
```

becomes


```julia
a = 42
```




    42



### . vs. \$ vs. _

R uses . to separate words in names and \$ to access components:

```
x <- my.data$first.column
```

Julia uses _ for word separation and . to access components:

```Julia
x = my_data.first_column # this will not work as my_data does not exist at this point
```

### Function declaration

In R:
```R
fun <- function(x) {
    2 * x
    }
```

In Julia:


```julia
function fun(x)
    2 * x
end

# shorter version:

fun2(x) = 2 * x
```




    fun2 (generic function with 1 method)



### Types

Types are sorts of objects in programming languages (think number versus text string). Most languages have them to some degree, but how they deal with them differs a lot.

Generally speaking, R's type system is an unwieldy mess. R itself doesn't really care about types, so any checking (e.g. if that list your function received really is the sort it can operate on) has to be done manually.

Julia in contrast has a sophisticated type system that allows for much safer code. At the same time typing is optional, so in many situations types can be left out and Julia will figure them out when needed.


```julia
# this function will only work on Integers
mult(x::Int, y::Int) = x * y

# in most situations, however generic functions are totally fine
mult2(x, y) = x * y

# Julia sees Integers and adds the types accordingly
a = mult2(2, 3)
println("a: ", typeof(a))

# but we can now use the same function with float
b = mult2(2.0, 3.0)
println("b: ", typeof(b))

# Note that for each combination of types a separate version 
# of mult2 will be generated internally and compiled to fast machine code. 
```

    a: Int64
    b: Float64


The huge advantage of this system and one the major pros of Julia is that it makes it possible to write programs without caring (too much) about types, similar to R or Python, while at the same time most (well-written) code can be compiled with type information and thus be made nearly as efficient as C or C++.

# More information

* [Julia homepage](https://julialang.org)
* [official documentation](https://docs.julialang.org/en/v1/)
* [Discourse forum](https://discourse.julialang.org/) (active and friendly)
* [some benchmarks](https://julialang.org/benchmarks/) (R does not fare well there...)
* and of course [the source](https://github.com/JuliaLang/julia)


```julia

```
