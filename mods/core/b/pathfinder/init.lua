b.pathfinder = {
	pathfinders = {},
}

function b.pathfinder.register(method, fdef)
	local fdef = b.t.combine({
		func = function(def) end,
	}, fdef)
	b.pathfinder.pathfinders[method] = fdef
end

-- Find a path.
-- Returns a table of positions or nil if no path could be found.
function b.pathfinder.path(def)
	local def = b.t.combine({
		-- Pathfinding method. Some methods may not support all features.
		method = "builtin",

		-- Pathfinding endpoints.
		-- Supported by all pathfinders.
		from = nil,
		to = nil,

		-- Distance to search.
		--- builtin: distance from both endpoints to search
		search_distance = 64,

		-- Maximum height differences to allow.
		--- builtin
		jump_height = 1,
		drop_height = 1,
	}, def)

	local pathfinder = assert(b.pathfinder.pathfinders[def.method])
	return pathfinder.func(def)
end
