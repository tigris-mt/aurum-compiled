return function(def)
	local t = {name = def.trunk, force_place = true}
	local l = def.leaves
	local lp = {name = def.leaves, prob = 127}

	local trunk = {
		{"air", "air", "air", "air", "air"},
		{"air", "air", "air", "air", "air"},
		{"air", "air", t, "air", "air"},
		{"air", "air", "air", "air", "air"},
		{"air", "air", "air", "air", "air"},
	}

	return aurum.trees.schematic(vector.new(5, 6, 5), {
		{
			{lp, lp, lp, lp, lp},
			{lp, l, l, l, lp},
			{lp, l, l, l, lp},
			{lp, l, l, l, lp},
			{lp, lp, lp, lp, lp},
		},
		{
			{l, l, l, l, l},
			{l, lp, lp, lp, l},
			{l, lp, t, lp, l},
			{l, lp, lp, lp, l},
			{l, l, l, l, l},
		},
		{
			{l, l, l, l, l},
			{l, lp, t, lp, l},
			{l, t, t, t, l},
			{l, lp, t, lp, l},
			{l, l, l, l, l},
		},
		trunk,
		trunk,
		trunk
	})
end
