b.pathfinder.register("builtin", {
	func = function(def)
		return minetest.find_path(def.from, def.to, def.search_distance, def.jump_height, def.drop_height)
	end,
	expense = 1,
	groups = b.set{
		"specify_vertical",
	},
})
