b.pathfinder = {
	pathfinders = {},
}

function b.pathfinder.register(method, fdef)
	local fdef = b.t.combine({
		func = function(def) end,
		-- Relative expense.
		-- Starts at 1 for the C++ builtin pathfinder.
		expense = 1,
		-- Support groups set.
		groups = {},
	}, fdef)
	b.pathfinder.pathfinders[method] = fdef
end

-- Find a path.
-- Returns a table of positions or nil if no path could be found.
function b.pathfinder.path(def)
	local def = b.t.combine({
		-- Pathfinding method. Some methods may not support all features.
		-- Use support groups to detect which pathfinder has the features you need.
		method = "<no method specified>",

		-- Pathfinding endpoints.
		from = nil,
		to = nil,

		-- Distance to search.
		search_distance = 64,

		-- Resolution, lower values mean multiple path points may be in a single node.
		-- group: resolution
		resolution = 1,

		-- Maximum height differences to allow.
		--- group: specify_vertical
		jump_height = 1,
		drop_height = 1,

		-- Entity clearance, simply height.
		--- group: clearance_height
		clearance_height = 1,

		-- Entity clearance, collisionbox table.
		--- group: clearance_box
		clearance_box = nil,

		-- Detect node pathing properties.
		-- function(pos, node) -> boolean indicating if node has property.
		--- group: node_functions
		node_passable = nil,
		node_walkable = nil,
	}, def)

	return assert(b.pathfinder.pathfinders[def.method], "no such pathfinder: " .. def.method).func(def)
end

-- Get a pathfinder method that supports all the groups in the passed set.
-- Returns nil if no pathfinder sufficed.
function b.pathfinder.get_pathfinder(groups)
	for method,fdef in b.t.spairs(b.pathfinder.pathfinders, function(t, a, b) return t[a].expense < t[b].expense end) do
		local function acceptable()
			for group in b.set.iter(groups) do
				if not fdef.groups[group] then
					return false
				end
			end
			return true
		end
		if acceptable() then
			return method
		end
	end
end
