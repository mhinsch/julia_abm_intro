# A short introduction to Julia and Agent-Based Modelling (ABM)

`intro_jupyter_julia` gives a quick beginner's overview of Jupyter and Julia
and a few links for additional information.

The remaining notebooks demonstrate how to program (simple) agent-based models
in Julia. 

All notebooks are generated from the `*.master.*` version. The `*.plain.*`
files can be read as a continuous text (with optional interactivity) while the
`*.quiz.*` files (only notbook 0 so far) leave some bits for the reader to fill
in.

* Notebook 0 shows the difference between an analytical, a simple and a spatial agent-based epidemiological model (SI). It comes with a "quiz" version with a few simple bits of code to fill in.
* In notebook 1 the spatial ABM is translated from discrete step-wise updates to event-based scheduling.
* In notebook 2 a few extensions to the model are introduced.
* Notebook 3 shows how to run and plot parameter sweeps.

If you just want to take a look without running the notebooks, these are (non-interactive) generated previews:
* [intro_jupyter_julia](intro_jupyter_julia.plain.md)
* [intro_abm_jl_0](intro_abm_jl_0.plain.md)
* [intro_abm_jl_1](intro_abm_jl_1.plain.md)
* [intro_abm_jl_2](intro_abm_jl_2.plain.md)
* [intro_abm_jl_3](intro_abm_jl_3.plain)


EDIT: Binder is deprecated for now until I find the time to check if the new versions of the notebooks still work.

Klicking on the badge [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/mhinsch/julia_abm_intro/master)  will start the notebook interface on [Binder](https://mybinder.org/). From there you can then open the individual notebooks (*.ipynb): 
* `intro_jupyter_julia` gives a very quick introduction to Jupyter and Julia
* `intro_abm_jl_1` introduce a simple agent-based [SIR model](http://mathworld.wolfram.com/SIRModel.html)
* `intro_abm_jl_2` adds a view things to the model to make it more interesting
* `intro_abm_jl_3` shows how to generate data and display the results
 
