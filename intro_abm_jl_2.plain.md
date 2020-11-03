# Introduction

In this part we will look at a few extensions of the model and the effect of different world topologies.


```julia
using Random

include("SimpleAgentEvents/src/SimpleAgentEvents.jl")

using .SimpleAgentEvents
using .SimpleAgentEvents.Scheduler
```

Agents can now be `immune` and `dead` as well.


```julia
@enum Status susceptible infected immune dead

mutable struct Person
    status :: Status
    contacts :: Vector{Person}
    x :: Float64
    y :: Float64
end

Person(x, y) = Person(susceptible, [], x, y)
Person(state, x, y) = Person(state, [], x, y)
```




    Person




```julia
mutable struct Simulation
    scheduler :: PQScheduler{Float64}
    # infection rate
    inf :: Float64
    # recovery rate
    rec :: Float64
    # new parameters:
    # immunisation rate
    imm :: Float64
    # mortality rate
    mort :: Float64
    
    pop :: Vector{Person}
end

scheduler(sim :: Simulation) = sim.scheduler

Simulation(i, r, u, m) = Simulation(PQScheduler{Float64}(), i, r, u, m, [])
```




    Simulation



# Extension 1 - immunity

For the first extension I let infected agents become immune instead of susceptible again with a certain rate.


```julia
@processes SIR sim person::Person begin
    @poisson(sim.inf * count(p -> p.status == infected, person.contacts)) ~
        person.status == susceptible        => 
            begin
                person.status = infected
                [person; person.contacts]
            end

    @poisson(sim.rec)  ~
        person.status == infected           => 
            begin
                person.status = susceptible
                [person; person.contacts]
            end
    
    # now agents become immune after having been infected
    @poisson(sim.imm)  ~
        person.status == infected           => 
            begin
                person.status = immune
                # an immune agent effectively becomes inactive, so
                # only the contacts are returned to the scheduler
                person.contacts
            end
end

```




    spawn_SIR (generic function with 1 method)



We are including a second file here. It contains the visualisation code from the previous notebook as a function.


```julia
include("setup_world.jl")
include("draw.jl")
```




    draw_sim (generic function with 3 methods)




```julia
sim = Simulation(0.5, 0.1, 0.2, 0)
sim.pop = setup_grid(Person, 50, 50)
sim.pop[1].status = infected

for person in sim.pop
    spawn_SIR(person, sim)
end

Random.seed!(42);
```


```julia
for t in  1:10
    upto!(sim.scheduler, time_now(sim.scheduler) + 1.0)
    println(time_now(sim.scheduler), ", ", 
        count(p -> p.status == infected, sim.pop), ", ",
        count(p -> p.status == susceptible, sim.pop))
end
```

    1.0, 2, 2498
    2.0, 5, 2493
    3.0, 9, 2487
    4.0, 18, 2477
    5.0, 18, 2473
    6.0, 25, 2460
    7.0, 33, 2451
    8.0, 40, 2435
    9.0, 47, 2424
    10.0, 44, 2419


For convenience I have put the visualisation code into a function.


```julia
draw_sim(sim)
```




    
![svg](intro_abm_jl_2.plain_files/intro_abm_jl_2.plain_14_0.svg)
    



# Extension 2 - mortality

Now we also assume that the infected people can die. As we can see in the code immunity and death are formally identical as in both cases the individual is removed from the simulation.


```julia
@processes SIRm sim person::Person begin
    @poisson(sim.inf * count(p -> p.status == infected, person.contacts)) ~
        person.status == susceptible        => 
            begin
                person.status = infected
                [person; person.contacts]
            end

    @poisson(sim.rec)  ~
        person.status == infected           => 
            begin
                person.status = susceptible
                [person; person.contacts]
            end

    @poisson(sim.imm)  ~
        person.status == infected           => 
            begin
                person.status = immune
                person.contacts
            end
    
    # mortality
    @poisson(sim.mort)  ~
        person.status == infected           => 
            begin
                person.status = dead
                person.contacts
            end    
end

```




    spawn_SIRm (generic function with 1 method)




```julia
sim_m = Simulation(0.5, 0.1, 0.2, 0.1)
sim_m.pop = setup_grid(Person, 50, 50)
sim_m.pop[1].status = infected


for person in sim_m.pop
    spawn_SIRm(person, sim_m)
end

Random.seed!(42);
```


```julia
for t in  1:10
    upto!(sim_m.scheduler, time_now(sim_m.scheduler) + 1.0)
    println(time_now(sim_m.scheduler), ", ", 
        count(p -> p.status == infected, sim_m.pop), ", ",
        count(p -> p.status == susceptible, sim_m.pop))
end

```

    1.0, 2, 2498
    2.0, 3, 2497
    3.0, 7, 2489
    4.0, 11, 2482
    5.0, 14, 2477
    6.0, 14, 2472
    7.0, 15, 2461
    8.0, 18, 2454
    9.0, 22, 2445
    10.0, 25, 2436



```julia
draw_sim(sim_m)
```




    
![svg](intro_abm_jl_2.plain_files/intro_abm_jl_2.plain_20_0.svg)
    



# Extension 3 - topology

Now, instead of a regular grid, we place the agent on an irregular graph. The algorithm is called a [random geometric graph](https://en.wikipedia.org/wiki/Random_geometric_graph) and was used as one of the first (very simple) models of transport networks.

The function is declared as follows:
```Julia
function setup_geograph(n = 2500, near = 0.05, rand_cont = 0)
```
with number of nodes `n`, threshold to connect nodes `near` (don't set this much higher or it might crash your browser) and number of additional random connections `rand_cont` (the latter is not part of the original RGG).


```julia
Random.seed!(42);

sim_m2 = Simulation(0.2, 0.01, 0.06, 0.00143)
sim_m2.pop = setup_geograph(Person, 2500, 0.025, 50)
sim_m2.pop[1].status = infected

for person in sim_m2.pop
    spawn_SIRm(person, sim_m2)
end


```


```julia
for t in  1:7
    upto!(sim_m2.scheduler, time_now(sim_m2.scheduler) + 1.0)
    println(time_now(sim_m2.scheduler), ", ", 
        count(p -> p.status == infected, sim_m.pop), ", ",
        count(p -> p.status == susceptible, sim_m.pop))
end

```

    1.0, 25, 2436
    2.0, 25, 2436
    3.0, 25, 2436
    4.0, 25, 2436
    5.0, 25, 2436
    6.0, 25, 2436
    7.0, 25, 2436



```julia
draw_sim(sim_m2)
```




    
![svg](intro_abm_jl_2.plain_files/intro_abm_jl_2.plain_25_0.svg)
    



# Things to try

* Can you make the population go extinct?
* What happens if there are no additional contacts (parameter `rand_cont`) in geo graph?
* What happens for lower `near` in geo graph?
