mdfiles : intro_abm_jl_1.md intro_abm_jl_2.md  intro_abm_jl_3.md  intro_jupyter_julia.md


%.md : %.ipynb
	jupyter nbconvert --to markdown --ExecutePreprocessor.timeout=60 --execute $< --output $@
