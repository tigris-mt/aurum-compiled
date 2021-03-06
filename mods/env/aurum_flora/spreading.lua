local S = aurum.get_translator()

-- Flora search in a radius to grow.
local RADIUS = 4
-- This much light is required for flora to grow.
local LIGHT = 10
-- There can only grow LIMIT + 1 flora in an area.
local LIMIT = 3

doc.sub.items.register_factoid("nodes", "use", function(itemstring, def)
	if minetest.get_item_group(itemstring, "flora") > 0 then
		return S("When this node is on {@1} and has a light level of @2 or greater, it may spread in a @3 radius cube with the same light level requirement as long as there is not already more than @4 flora there.", table.concat(def._flora_spread_node and ((type(def._flora_spread_node) == "table") and def._flora_spread_node or {def._flora_spread_node}) or {"group:soil"}, ", "), def._flora_light or LIGHT, RADIUS, LIMIT)
	end
	return ""
end)

-- Run flora spreading logic at pos for node.
function aurum.flora.spread(pos, node)
	local under = vector.add(pos, vector.new(0, -1, 0))
	local above = vector.add(pos, vector.new(0, 1, 0))
	local def = minetest.registered_nodes[node.name]

	local spread = def._flora_spread_node or "group:soil"
	if type(spread) ~= "table" then
		spread = {spread}
	end

	if #minetest.find_nodes_in_area(under, under, spread) == 0 then
		return false
	end

	if (minetest.get_node_light(pos) or 0) < (def._flora_light or LIGHT) then
		return false
	end

	-- Default to spreading the current node.
	local spread_node = node.name

	-- If the node has an _on_flora_spread callback, run that.
	if def._on_flora_spread then
		local cancel, cs = def._on_flora_spread(pos, node)
		-- The callback may have provided a new node to spread.
		spread_node = cs or spread_node
		if cancel == false then
			return true
		end
	end

	-- Ensure we won't go over the limit.
	if #minetest.find_nodes_in_area(vector.subtract(pos, RADIUS), vector.add(pos, RADIUS), "group:flora") > LIMIT then
		return false
	end

	-- Find and place at a suitable target.
	local targets = minetest.find_nodes_in_area_under_air(vector.subtract(pos, RADIUS), vector.add(pos, RADIUS), spread)
	for _,target in ipairs(b.t.shuffled(targets)) do
		local tabove = vector.add(target, vector.new(0, 1, 0))
		if (minetest.get_node_light(tabove) or 0) >= (def._flora_light or LIGHT) then
			minetest.set_node(tabove, {name = spread_node})
			return true
		end
	end
end

minetest.register_abm{
	label = "Flora Spread",
	nodenames = {"group:flora"},
	interval = 120,
	chance = 25,
	action = aurum.flora.spread,
}
