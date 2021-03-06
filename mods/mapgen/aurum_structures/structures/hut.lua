local op = "aurum_trees:oak_planks"
local air = "air"

aurum.features.register_decoration{
	place_on = {"group:soil"},
	rarity = 0.000065,
	biomes = aurum.biomes.get_all_group("aurum:aurum", {"base"}),
	schematic = aurum.features.schematic(vector.new(5, 4, 6), {
		{
			{op, op, op, op, op},
			{op, op, op, op, op},
			{op, op, op, op, op},
			{op, op, op, op, op},
			{op, op, op, op, op},
			{air, air, air, air, air},
		},
		{
			{op, op, op, op, op},
			{op, air, air, air, op},
			{op, air, air, air, op},
			{op, air, air, air, op},
			{op, op, air, op, op},
			{air, air, air, air, air},
		},
		{
			{op, op, op, op, op},
			{op, "aurum_features:ph_1", air, "aurum_features:ph_1", op},
			{op, air, air, air, op},
			{op, "aurum_features:ph_1", air, "aurum_features:ph_1", op},
			{op, op, air, op, op},
			{air, air, air, air, air},
		},
		{
			{op, op, op, op, op},
			{op, op, op, op, op},
			{op, op, "aurum_features:ph_2", op, op},
			{op, op, op, op, op},
			{op, op, op, op, op},
			{op, op, op, op, op},
		},
	}),

	on_generated = function(c)
		local ph = c:ph(1)

		if #ph > 0 then
			minetest.set_node(ph[1], {name = "aurum_storage:box"})
			c:treasures(ph[1], "main", c:random(2, 4), {
				{
					count = c:random(1, 3),
					preciousness = {0, 2},
					groups = {"building_block", "crafting_component"},
				},
				{
					count = c:random(-2, 1),
					groups = {"lorebook_aurum", "lorebook_general"},
				},
			})
		end

		for _,pos in ipairs(c:ph(2)) do
			minetest.set_node(pos, {name = "aurum_mobs:spawner"})
			aurum.mobs.set_spawner(pos, {
				mob = "aurum_npcs:nomad_hermit",
				limit = -1,
				replace = {name = op},
			})
		end
	end,
}
