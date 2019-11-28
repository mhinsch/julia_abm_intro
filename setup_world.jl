
function setup_grid(xs, ys)
	pop = [ Person(x, y) for y=1:ys, x=1:xs ]

	pop[1, 1] = Person(infected, 1, 1)

	ret = Person[]

	for x in 1:xs, y in 1:ys
		p = pop[y, x]
		if x > 1
			push!(p.contacts, pop[y, x-1])
		end
		if y > 1
			push!(p.contacts, pop[y-1, x])
		end
		if x < xs
			push!(p.contacts, pop[y, x+1])
		end
		if y < ys
			push!(p.contacts, pop[y+1, x])
		end

		push!(ret, p)
	end


	ret
end


