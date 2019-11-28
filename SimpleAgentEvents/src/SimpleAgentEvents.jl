module SimpleAgentEvents

export @processes, Scheduler


using MacroTools
using Distributions


# TODO
# useful return values in process_*
# include line numbers in error messages
# fixed waiting times (dirac)
# in which module should rand. println, etc. be executed?


macro processes(sim, agent_decl, decl)
	# some superficial sanity checks
	if ! isexpr(agent_decl, Symbol("::"))
		error("processes expects an agent declaration as 2nd argument")
	end

	if typeof(decl) != Expr || decl.head != :block
		error("processes expects a declaration block as 3rd argument")
	end

	agent_name = agent_decl.args[1]
	agent_type = agent_decl.args[2]

	pois = []
	dir = []

	# sort by distributions
	lines = decl.args
	for line in lines
		# filter out line numbers
		if typeof(line) == LineNumberNode
			continue
		end

		if ! iscall(line, :~) || length(line.args) < 2
			error("event declaration expected: @<DISTR>(<RATE>) ~ <COND> => <ACTION>")
		end

		args = rmlines(line.args)

		distr = args[2]
		distr_name = distr.args[1]
		action = args[3]

		if distr_name == Symbol("@poisson")
			push!(pois, (distr, action))
# TODO
#		elseif distr_name == Symbol("@dirac")
#			push!(dir, (distr, action))
		else
			error("unknown distribution $(distr_name)")
		end
	end


	# name functions by type so that objects of different type
	# can be used in parallel
	pois_func_name = :process_poisson

	# general bits of the function body
	pois_func = :(function $(esc(pois_func_name))($(esc(agent_decl)), $(esc(:sim)))
			rates = fill(0.0, $(length(pois)))
		end)
	
	pois_func_body = pois_func.args[2].args
	action_ifs = []

	# add all poisson events
	i = 1
	for (d, a) in pois
		rate = d.args[3]

		if !iscall(a, :(=>))
			error("event declaration expected: @<DISTR>(<RATE>) ~ COND => ACTION")
		end

		cond_act = rmlines(a.args)
		cond = cond_act[2]
		action = cond_act[3]

		# condition check
		check = :(if $(esc(cond))
				rates[$i] = $(esc(rate))
			end)
		push!(pois_func_body, check)

		# check if selected, execute
		ai = :(
			if rnd < rates[$i]
#				println("@ ", w_time, " -> ", $(string(action)))

				$(esc(:schedule_in!))($(esc(agent_name)), w_time, $(esc(:scheduler))($(esc(sim)))) do $(esc(agent_name))
					active = $(esc(action))

					for obj in active 
						# should not be needed as queue as well as actions are unique in 
						# agents
						# $(esc(:unschedule!))($(esc(:scheduler))($(esc(sim))), obj)
						$(esc(pois_func_name))(obj, $sim)
					end
				end

				return
			end;

			# we might want to check if this is optimal
			rnd -= rates[$i]
			)
		push!(action_ifs, ai)

		i += 1
	end

	# bits between conditions and selection
	push!(pois_func_body, :(rate = $(esc(:sum))(rates);
#		println("@@ ", rate);
#		w_time = rand(Exponential(1.0/rate));
# copy ML3
#		w_time = max(1e-5, log(1.0/rand())/rate);
		w_time = log(rand())/-rate;
		rnd = rand() * rate
		))

	append!(pois_func_body, action_ifs)

	# if we didn't select *any* action something went wrong
	push!(pois_func_body, :(println("No action selected! ", rnd, " ", rate)))


	# the entire bunch of code
	ret = Expr(:block)
	# and we also need a function to get an agent started
	push!(ret.args, :(function $(esc(:spawn))(agent::$(esc(agent_type)), sim)
			$(esc(pois_func_name))(agent, sim)
		end
		))

	push!(ret.args, pois_func)

	ret
end


include("Scheduler.jl")

end
