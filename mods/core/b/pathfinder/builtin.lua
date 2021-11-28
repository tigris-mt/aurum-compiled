b.pathfinder.register("b:builtin", {
	metatable = {
		init = function(self)
			self.path = minetest.find_path(self.from, self.to, self.def.search_distance, self.def.jump_height, self.def.drop_height)
			self.i = 1
			return not not self.path
		end,
		next = function(self)
			self.i = self.i + 1
			return self.path[self.i]
		end,
	},
	priority = 1,
	groups = b.set{
		"specify_vertical",
	},
})
