b.pathfinder.register("b:cheap", {
	metatable = {
		init = function(self)
			self.at = self.from
			return true
		end,

		next = function(self)
			local delta = vector.subtract(self.to, self.at)
			-- If jumping is enabled, then try not to go directly vertical.
			if self.def.jump_height >= 0 then
				delta.y = math.sign(delta.y)
			end
			local dir = vector.normalize(delta)
			local next_pos = vector.round(vector.add(self.at, dir))
			local original_next_pos = next_pos

			-- Jump if necessary to find clearance.
			if not (function()
				for i=-self:jump_down_height(self.at),self:jump_height(self.at) do
					if self:clearance(next_pos) then
						break
					end
					next_pos = vector.add(original_next_pos, vector.new(0, i, 0))
				end
				return self:clearance(next_pos)
			end)() then
				-- No clearance, return.
				return
			end

			-- Don't try to fly if impossible.
			if not self:can_walk(next_pos) and (next_pos.y - self.at.y) > 0 then
				return
			end

			-- Ensure we're going to walk on a safe place.
			if self.def.drop_height >= 0 and not (function()
				for i=1,self.def.drop_height do
					local pos = vector.subtract(next_pos, vector.new(0, i, 0))
					if self.def.node_walkable(pos, minetest.get_node(pos)) then
						return true
					elseif not self.def.node_passable(pos, minetest.get_node(pos)) then
						return false
					end
				end
				return false
			end)() then
				return
			end

			self.at = next_pos
			return self.at
		end,

		can_walk = function(self, pos)
			local below = vector.subtract(pos, vector.new(0, 1, 0))
			return self.def.node_walkable(below, minetest.get_node(below))
		end,

		jump_height = function(self, pos)
			local free_space = 0
			for i=0,math.abs(self.def.jump_height) do
				if self:clearance(vector.add(pos, vector.new(0, i, 0))) then
					free_space = i
				else
					break
				end
			end
			return free_space
		end,

		jump_down_height = function(self, pos)
			local free_space = 0
			if self.def.jump_height < 0 then
				for i=0,math.abs(self.def.jump_height) do
					if self:clearance(vector.add(pos, vector.new(0, -i, 0))) then
						free_space = i
					else
						break
					end
				end
			end
			return free_space
		end,

		clearance = function(self, pos)
			for i=0,self.def.clearance_height-1 do
				local ipos = (i == 0) and pos or vector.add(pos, vector.new(0, i, 0))
				if not self.def.node_passable(ipos, minetest.get_node(ipos)) then
					return false
				end
			end
			return true
		end,
	},
	expense = b.pathfinder.CHEAP + 20,
	groups = b.set{
		"cheap",
		"clearance_height",
		"specify_vertical",
		"node_functions_passable",
		"node_functions_walkable",
	},
})
