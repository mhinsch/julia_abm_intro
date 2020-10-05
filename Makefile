all : mdfiles htmlfiles


mdfiles : intro_abm_jl_1.md intro_abm_jl_2.md  intro_abm_jl_3.md  intro_jupyter_julia.md

htmlfiles : intro_abm_jl_1.html intro_abm_jl_2.html  intro_abm_jl_3.html  intro_jupyter_julia.html


%.md : %.ipynb
	jupyter nbconvert --to markdown --ExecutePreprocessor.timeout=60 --allow-errors --execute $< --output $@

%.html : %.ipynb
	jupyter nbconvert --to html --ExecutePreprocessor.timeout=60 --allow-errors --execute $< --output $@
