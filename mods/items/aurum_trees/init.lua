local S = aurum.get_translator()
-- Schematic parameter delimiter.
local SCHEMATIC_DELIM = ","
local m = {}
aurum.trees = m

m.types = {}

b.dofile("defaults.lua")

-- Map names to more generic schematics.
m.translation = {
	simple = "tree,5,2",
	wide = "tree,6,4,0.3,0.25",
	tall = "tree,8,2",
	very_tall = "tree,14,5",
	huge = "tree,14,7",
	giant = "tree,26,12",
	double = "tree,7,5",
}

local function remove_force_place(schematic)
	local ret = table.copy(schematic)
	for _,v in ipairs(ret.data) do
		v.force_place = nil
	end
	return ret
end

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Returns a decoration for tree according to decoration schematic n.
aurum.trees.generate_decoration = b.cache.simple(function(tree, n)
	local t_begin = minetest.get_us_time()

	n = m.translation[n] or n

	-- Split up decoration name by delimiter.
	local split = n:split(SCHEMATIC_DELIM, true)
	local name = split[1]
	local params = {}
	for i=2,#split do
		table.insert(params, split[i])
	end

	-- Execute decoration schematic generator according to def and params.
	local schematic, offset = dofile(modpath .. "/decorations/" .. name .. ".lua")(m.types[tree], unpack(params))
	offset = offset or 0

	-- Warn if elapsed time was lengthy.
	local t_sec = (minetest.get_us_time() - t_begin) / 1000000
	if t_sec > 0.1 then
		minetest.log("warning", ("Registering tree decoration %s (%s) took %.4f seconds."):format(tree, n, t_sec))
	end

	return {
		schematic = schematic,
		rotation = "random",
		flags = {place_center_x = true, place_center_y = false, place_center_z = true},
		place_offset_y = offset,
	}
end, function(tree, n) return tree .. " " .. (m.translation[n] or n) end)

-- Add decoration schematic n to tree's default.
local function add_decoration(tree, n)
	m.types[tree].decodefs[n] = aurum.trees.generate_decoration(tree, n)
end

function m.register(name, def)
	assert(not m.types[name], "tree type already exists")

	def = b.t.combine({
		-- Basic description of tree type.
		description = "Generic",

		-- Base texture, will add subnames to it.
		texture_base = "aurum_trees_generic_%s.png",

		-- Translator.
		S = S,

		-- Distance leaves can be from the trunk.
		leafdistance = 4,
		-- Shall leaves decay?
		leafdecay = true,

		-- Growth terrain.
		terrain = {"group:soil"},
		-- Description of what this tree grows on.
		terrain_desc = S"any dirt or soil",

		-- What decoration schematics should be included, and at what weight?
		decorations = m.defaults.ALL,
	}, def, {
		name = name,

		decodefs = {},
	})

	-- Register and set a part of the tree.
	-- Will set def[sub] to the new node's name.
	local function subnode(sub, default)
		-- If a string is specified, just use that for the part.
		-- An empty string indicates that the tree does not use this part.
		if type(def[sub]) == "string" then
			return (#def[sub] > 0) and def[sub] or nil
		end

		-- Combine the defs.
		local spec = b.t.combine(default, {
			-- Builds a translatable description according to the tree's S parameter.
			description = def.S("@1 @2", def.description, default.description or ""),
		}, def.all or {}, def[sub] or {}, {
			groups = b.t.combine(default.groups, (def[sub] or {}).groups or {}),
		})

		-- Create the final part def.
		local ndef = b.t.combine({
			name = name .. "_" .. sub,
			tiles = {def.texture_base:format(sub)},
			_tree = def,
			is_ground_content = false,
		}, spec)

		-- Register and set name in tree's table.
		minetest.register_node(":" .. ndef.name, ndef)
		def[sub] = ndef.name
		return ndef
	end

	subnode("trunk", {
		description = S"Trunk",
		_doc_items_longdesc = S"The trunk of a tree.",
		sounds = aurum.sounds.wood(),
		groups = {dig_chop = 3, tree = 1, flammable = 1, shapable = 1},
		tiles = {def.texture_base:format("trunk_top"), def.texture_base:format("trunk_top"), def.texture_base:format("trunk")},

		paramtype2 = "facedir",
		on_place = minetest.rotate_node,
	})

	subnode("planks", {
		description = S"Planks",
		_doc_items_longdesc = S"Wood cut into planks. Firm and useful.",
		sounds = aurum.sounds.wood(),
		groups = {dig_chop = 3, wood = 1, flammable = 1, shapable = 1},
	})

	if def.planks and def.trunk then
		minetest.register_craft{
			output = def.planks .. " 4",
			recipe = {{def.trunk}},
		}
	end

	subnode("sapling", {
		description = S"Sapling",
		_doc_items_longdesc = S"A young tree.",
		sounds = aurum.sounds.leaves(),
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "plantlike",
		selection_box = {
			type = "fixed",
			fixed = {-4 / 16, -8 / 16, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
		},
		walkable = false,
		groups = {dig_snap = 3, flammable = 1, sapling = 1, attached_node = 1, grow_plant = 1},

		_on_grow_plant = function(pos, node)
			local meta = minetest.get_meta(pos)

			-- Ensure there's at least some room above the sapling.
			for y=1,3 do
				if not aurum.is_air(minetest.get_node(vector.add(pos, vector.new(0, y, 0))).name) then
					return false
				end
			end

			local all_terrain = meta:get_int("sapling_all_terrain") == 1

			-- Ensure we're on valid terrain.
			local below = vector.add(pos, vector.new(0, -1, 0))
			if #minetest.find_nodes_in_area(below, below, def.terrain) == 0 and not all_terrain then
				return false
			end

			local replace = meta:get_int("sapling_replace") == 1
			local allow_rare = meta:get_int("sapling_rare") == 1

			-- Select and place a random schematic.
			local dkp = {}
			for k,v in pairs(def.decorations) do
				-- Disable growing the rarest trees from saplings by default.
				-- Rare trees can be huge.
				if v >= 0.1 or allow_rare then
					table.insert(dkp, {k, v})
				end
			end
			local dk = b.t.weighted_choice(dkp)
			local d = def.decodefs[dk]
			minetest.remove_node(pos)
			minetest.place_schematic(pos, replace and d.schematic or remove_force_place(d.schematic), d.rotation, {}, replace, d.flags)
			return true
		end,

		on_construct = function(pos)
			minetest.get_node_timer(pos):start(math.random(60 * 4, 60 * 20))
		end,

		on_timer = function(pos)
			local node = minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			if def._on_grow_plant then
				-- Restart the timer if growth was not successful.
				return not def._on_grow_plant(pos, node)
			end
		end,
	})

	subnode("leaves", b.t.combine({
		description = S"Leaves",
		_doc_items_longdesc = S"A bundle of leaves.",
		sounds = aurum.sounds.leaves(),

		drawtype = "allfaces_optional",
		waving = 2,
		paramtype = "light",
		groups = {dig_snap = 3, leaves = 1, flammable = 1},

		drop = {
			max_items = 1,
			items = {
				{rarity = 20, items = {def.sapling}},
				{rarity = 1, items = {name .. "_leaves"}},
			},
		},
	}, minetest.settings:get_bool("aurum.trees.plantlike_leaves", true) and {
		drawtype = "plantlike",
		visual_scale = 1.4,
	} or {},
	minetest.settings:get_bool("aurum.trees.climbable_leaves", true) and {
		walkable = false,
		climbable = true,
	} or {}))

	if def.leafdecay and def.trunk and def.leaves then
		aurum.trees.leafdecay.register(def)
	end

	m.types[name] = def

	for n in pairs(b.t.map(def.decorations, function(v) return (v > 0) and v or nil end)) do
		add_decoration(name, n)
	end
end

minetest.register_chatcommand("growtree", {
	params = S"<type> <decoration>",
	description = S"Grows a tree at your location.",
	privs = {give = true},
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S"No player."
		end

		local pos = vector.round(player:get_pos())

		if aurum.is_protected(pos, player, true) then
			return false, S"Position protected."
		end

		local split = params:split(" ")
		local type = split[1]
		local decoration = split[2]

		if not type or not decoration or not m.types[type] then
			return false, S"Invalid parameters."
		end

		local err, emsg = pcall(add_decoration, type, decoration)

		if not err then
			return false, emsg
		end

		local d = m.types[type].decodefs[decoration]
		minetest.place_schematic(pos, remove_force_place(d.schematic), d.rotation, {}, false, d.flags)

		return true, "Tree grown."
	end,
})

doc.sub.items.register_factoid("nodes", "use", function(itemstring, def)
	if minetest.get_item_group(itemstring, "sapling") > 0 then
		if def._tree then
			return S("This sapling will grow into a tree when left for some time on @1.", def._tree.terrain_desc)
		end
	end
	return ""
end)

b.dofile("leafdecay.lua")

b.dofile("decorations/init.lua")
b.dodir("trees")
b.dofile("fuel.lua")
