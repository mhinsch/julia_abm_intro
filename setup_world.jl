
function setup_grid(xs, ys)
	pop = [ Person(x, y) for y=1:ys, x=1:xs ]

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


function create_random_geo_graph(nnodes :: Int64, thresh :: Float64)
	sq_thresh = thresh * thresh

	sq_dist(n1, n2) = (n1[1] - n2[1])^2 + (n1[2] - n2[2])^2

	nodes = Vector{Tuple{Float64, Float64}}()
	links = Vector{Tuple{Int64, Int64}}()

	for i in 1:nnodes
		new_node = (rand(), rand())
		for j in eachindex(nodes)
			if sq_dist(nodes[j], new_node) < sq_thresh
				push!(links, (i, j))
			end
		end
		push!(nodes, new_node)
	end

	(nodes, links)
end


function setup_geograph(n = 2500, thresh = 0.05, rand_cont = 0)
	nodes, links = create_random_geo_graph(n, thresh)

	pop = [Person(x, y) for (x, y) in nodes]

	for (p1, p2) in links
		push!(pop[p1].contacts, pop[p2])
		push!(pop[p2].contacts, pop[p1])
	end

	for i in 1:rand_cont
		p1 = rand(pop)

		while (p2 = rand(pop)) == p1 end

		push!(p1.contacts, p2)
		push!(p2.contacts, p1)
	end

	pop
end

