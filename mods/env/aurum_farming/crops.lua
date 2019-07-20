local S = minetest.get_translator()

function aurum.farming.grow_plant(i, next_name, def, pos, node)
	local below = vector.add(pos, vector.new(0, -1, 0))
	local bnode = minetest.get_node(below)

	if minetest.get_item_group(bnode.name, "soil_wet") < def.level then
		return false
	end

	if minetest.get_node_light(pos) < def.light then
		return false
	end

	minetest.set_node(pos, {name = next_name})

	if (i + 1) == def.max then
		if math.random(4) == 1 then
			minetest.set_node(below, {name = "aurum_base:dirt"})
		end
	end

	return true
end

function aurum.farming.timer(def, pos, dtime)
	local d = dtime
	local n = {name = "ignore"}
	while d > 0 do
		n = minetest.get_node(pos)
		-- At end of growth.
		if minetest.get_item_group(n.name, "farming_plant") == 2 then
			return false
		end
		if minetest.registered_items[n.name]._on_grow_plant(pos, n) then
			local next_time = def.time()
			if d > next_time then
				d = d - next_time
				-- Try again on next loop around.
			else
				next_time = next_time - d
				minetest.get_node_timer(pos):start(next_time)
				return false
			end
		else
			return true
		end
	end
	return minetest.get_item_group(n.name, "farming_plant") < 2
end

function aurum.farming.register_crop(base_name, def, decodef)
	local def = table.combine({
		level = 1,
		max = 1,
		light = 12,
		node = {},
		time = function()
			return math.random(300, 900)
		end,
	}, def)
	local last_name = base_name .. "_" .. def.max

	for i=1,def.max do
		local name = (i == 1) and base_name or (base_name .. "_" .. i)
		local next_name = (i < def.max) and (base_name .. "_" .. (i + 1))

		aurum.flora.register(":" .. name, table.combine({
			description = S("@1 Plant", def.description),
			groups = {flora = 0, not_in_creative_inventory = (i ~= 1) and 1 or 0, farming_plant = next_name and 1 or 2},
			_doc_items_create_entry = (i == 1),
			_on_grow_plant = next_name and (function(...)
				return aurum.farming.grow_plant(i, next_name, def, ...)
			end),
			on_timer = function(...) return aurum.farming.timer(def, ...) end,
			on_construct = function(pos)
				if next_name then
					minetest.get_node_timer(pos):start(def.time())
				end
			end,
			selection_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			},
			drop = def.drops(i) or "",
			tiles = {def.texture .. "_" .. i .. ".png"},
		}, def.node or {}))

		if i ~= 1 then
			doc.add_entry_alias("nodes", base_name, "nodes", name)
		end
	end

	if def.seed then
		minetest.register_node(base_name .. "_seed", table.combine({
			description = S("@1 Seed", def.description),
			inventory_image = def.texture .. "_seed.png",
			wield_image = def.texture .. "_seed.png",
			node_placement_prediction = base_name,
			groups = {farming_seed = 1},
			on_construct = function(pos)
				minetest.set_node(pos, {name = base_name})
			end,
			on_place = function(itemstack, placer, pointed_thing)
				local pos = minetest.get_pointed_thing_position(pointed_thing)
				if minetest.get_item_group(minetest.get_node(pos).name, "soil_wet") < 1 then
					return itemstack
				else
					return minetest.item_place(itemstack, placer, pointed_thing)
				end
			end,
		}, def.seed))
	end

	if def.product then
		minetest.register_craftitem(base_name .. "_product", table.combine({
			description = def.description,
			inventory_image = def.texture .. "_product.png",
		}, def.product))
	end

	if decodef then
		minetest.register_decoration(table.combine({
			name = last_name,
			decoration = last_name,
			deco_type = "simple",
			sidelen = 16,
		}, decodef))
	end
end

aurum.dofile("default_crops.lua")
