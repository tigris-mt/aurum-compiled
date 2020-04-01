b.pathfinder = {
	CHEAP = 1000,
	pathfinders = {},
}

function b.pathfinder.register(method, fdef)
	local fdef = b.t.combine({
		func = function(def) end,
		-- Priority, least expensive and most accurate implementations have priority.
		-- Lower is better.
		-- 1 for the builtin C++ pathfinder.
		-- b.pathfinder.CHEAP + x for "cheap" inaccurate pathfinders.
		priority = 1,
		-- Support groups set.
		groups = {},

		metadata = {},
	}, fdef)

	fdef.metatable = b.t.combine({
		init = function(self) return true end,
		next = function(self) end,
	}, fdef.metatable)

	-- Ensure the "any" group is set.
	fdef.groups = b.set._or(fdef.groups, b.set{"any"})
	b.pathfinder.pathfinders[method] = fdef
end

function b.pathfinder.default_passable(pos, node) return not minetest.registered_nodes[node.name].walkable and minetest.get_item_group(node.name, "liquid") == 0 end
function b.pathfinder.default_walkable(pos, node) return minetest.registered_nodes[node.name].walkable end
function b.pathfinder.default_climbable(pos, node) return minetest.registered_nodes[node.name].climbable end

-- Find a path.
-- Returns a table of positions or nil if no path could be found.
function b.pathfinder.path(def)
	local def = b.t.combine({
		-- Pathfinding method. Some methods may not support all features.
		-- Use support groups to detect which pathfinder has the features you need.
		-- The special group "any" contains all pathfinders.
		-- The special group "cheap" contains pathfinders which are inexpensive but may be quite inaccurate.
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
		--- groups: node_functions_X
		node_passable = b.pathfinder.default_passable, -- Can walk through?
		node_walkable = b.pathfinder.default_walkable, -- Can walk over?
		node_climbable = b.pathfinder.default_climbable, -- Can climb in (ladders, vines)?
		node_climbable_against = nil, -- Can climb against (perhaps spiders on walls)?
	}, def)

	local path = setmetatable({
		from = def.from,
		to = def.to,
		def = def,
	}, {__index = assert(b.pathfinder.pathfinders[def.method], "no such pathfinder: " .. def.method).metatable})
	return path:init() and path or nil
end

-- Get a pathfinder method that supports all the groups in the passed set.
-- Returns nil if no pathfinder sufficed.
function b.pathfinder.get_pathfinder(groups)
	for method,fdef in b.t.spairs(b.pathfinder.pathfinders, function(t, a, b) return t[a].priority < t[b].priority end) do
		if (function()
			for group in b.set.iter(groups) do
				if not fdef.groups[group] then
					return false
				end
			end
			return true
		end)() then
			return method
		end
	end
end

function b.pathfinder.require_pathfinder(groups)
	local gns = b.set.to_array(groups)
	table.sort(gns)
	return assert(b.pathfinder.get_pathfinder(groups), "could not find required pathfinder: " .. table.concat(gns, ", "))
end
