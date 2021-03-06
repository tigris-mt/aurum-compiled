local S = aurum.get_translator()

local function make_headstone(pos, random)
	local name = aurum.flavor.generate_name(random)
	local age = random(16, 110)
	for _=1,4 do
		if age > 50 then
			age = age - math.max(0, random(-30, 35))
		end
	end
	gtextitems.set_node(pos, {
		title = S("Grave of @1", name),
		text = S("They lived @1 years before @2 took them. I buried them @3. In life, they were @4. That is all I know.\n\nRequiescat in pace, @5.",
			age,
			b.t.weighted_choice({
				{(age > 60) and S"old age" or S"sudden disease", age / 70 * 5},
				{S"battle", 1},
				{S"magical battle", 0.25},
				{S"a lightning strike", 0.01},
				{S"a simultaneous lightning strike and cobra bite", 0.001},
				{S"corruption from the Loom", 1},
				{S"wild animals", 1},
				{S"a murderer", 1},
				{S"a gang of murderers", 0.1},
				{S"monsters", 1},
				{S"an accident", 1},
				{S"disease", 1},
				{S"an injury", 1},
				{S"an archon", 0.1},
				{S"Hyperion", 0.1},
				{S"inexplicable circumstances", 1},
				{S"a trap", 1},
				{S"paranoia", 0.25},
				{S"a magical mishap", 0.25},
				{S"divine judgement", 0.1},
				{S"their lack of immortality", 0.1},
				{S"their great pride", 0.25},
				{S"extreme sport", 0.5},
				{S"fire", 0.5},
				{S"five tall men", 0.05},
			}, random),
			b.t.weighted_choice({
				{S"quickly", 1},
				{S"after some time", 1},
				{S"respectfully", 1},
				{S"with scorn", 1},
				{S"carelessly", 1},
				{S"lovingly", 1},
				{S"hatefully", 1},
				{S"where they wanted to be", 1},
				{S"far from home", 1},
				{S"at the site of their death", 0.1},
				{S"sadly", 1},
				{S"joyfully", 1},
				{S"solemnly", 1},
				{S"gently", 1},
				{S"as if they were my own child", 0.01},
				{S"with family", 1},
				{S"while people watched", 1},
				{S"with nobody around", 1},
				{S"under the watchful night", 1},
				{S"in the uncaring earth", 1},
				{S"in memory of five tall men", 0.05},
			}, random),
			b.t.weighted_choice({
				{S"humble", 1},
				{S"filled with pride", 1},
				{S"kind", 1},
				{S"ruthless", 1},
				{S"a ruler", 1},
				{S"a servant", 1},
				{S"a slave", 0.1},
				{S"beautiful", 1},
				{S"ugly", 1},
				{S"knowledgable", 1},
				{S"ignorant", 1},
				{S"fun", 1},
				{S"bitter", 1},
				{S"caring", 1},
				{S"incompetent", 1},
				{S"reverent", 1},
				{S"profane", 1},
				{S"a wizard", 0.25},
				{S"a great wizard", 0.1},
				{S"a holy person, dedicated to me", 0.01},
				{S"someone I wish was still alive", 0.01},
				{S"valiant", 1},
				{S"brave", 1},
				{S"a true warrior", 1},
				{S"lazy", 1},
				{S"a coward", 1},
				{S"one who killed others", 1},
				{S"sadistic", 1},
				{S"remarkable", 1},
				{S"glorious", 1},
				{S"sickly", 1},
				{S"mundane", 1},
				{S"glamorous", 1},
				{S"attractive", 1},
				{S"one of five tall men", 0.05},
			}, random),
			name
		),
		author = S"the Headstoner",
		author_type = "npc",
		id = "aurum_structures:gravestone",
	})
end

aurum.structures.GRAVEYARD_NOISE = {
	offset = -0.095,
	scale = 0.1,
	spread = vector.new(150, 150, 150),
	seed = 537,
	octaves = 3,
	persist = 0.5,
}

minetest.register_decoration{
	name = "aurum_structures:graveyard",
	deco_type = "schematic",
	schematic = aurum.features.schematic(vector.new(1, 4, 1), {
		{{"aurum_books:stone_tablet_written"}},
		{{"aurum_base:dirt"}},
		{{"aurum_farming:fertilizer"}},
		{{"aurum_farming:fertilizer"}},
	}),
	rotation = "random",
	flags = {force_placement = true},
	place_offset_y = -2,
	place_on = {"group:soil", "aurum_base:gravel", "aurum_base:sand", "aurum_base:snow"},
	noise_params = aurum.structures.GRAVEYARD_NOISE,
	biomes = aurum.biomes.get_all_group("aurum:aurum", {"base"}),
}

local did = minetest.get_decoration_id("aurum_structures:graveyard")

minetest.set_gen_notify("decoration", {did})
minetest.register_on_generated(function(_, _, seed)
	local g = minetest.get_mapgen_object("gennotify")
	local d = g["decoration#" .. did]
	if d then
		local random = b.seed_random(seed + aurum.structures.GRAVEYARD_NOISE.seed)
		for _,pos in ipairs(d) do
			pos.y = pos.y + 1
			if minetest.get_node(pos).name == "aurum_books:stone_tablet_written" then
				make_headstone(pos, random)
			end
		end
	end
end)
