all : plainfiles mdfiles htmlfiles quizfiles

plainfiles : intro_abm_jl_0.plain.ipynb intro_abm_jl_1.plain.ipynb intro_abm_jl_2.plain.ipynb  intro_abm_jl_3.plain.ipynb  intro_jupyter_julia.plain.ipynb

mdfiles : intro_abm_jl_0.plain.md intro_abm_jl_1.plain.md intro_abm_jl_2.plain.md  intro_abm_jl_3.plain.md  intro_jupyter_julia.plain.md

htmlfiles : intro_abm_jl_0.plain.html intro_abm_jl_1.plain.html intro_abm_jl_2.plain.html  intro_abm_jl_3.plain.html  intro_jupyter_julia.plain.html

quizfiles : intro_abm_jl_0.quiz.ipynb


%.md : %.ipynb
	jupyter nbconvert --to markdown --ExecutePreprocessor.timeout=120 --allow-errors --execute $< --output $@

%.html : %.ipynb
	jupyter nbconvert --to html --ExecutePreprocessor.timeout=120 --allow-errors --execute $< --output $@

%.quiz.ipynb : %.master.ipynb
	nb-filter-cells -i $< -o $@ -t solutions; jupyter nbconvert --clear-output $@

%.plain.ipynb : %.master.ipynb
	nb-filter-cells -i $< -o $@ -t questions; jupyter nbconvert --clear-output $@
