-- Barrens

aurum.biomes.register("aurum:aurum", {
	name = "aurum_barrens",
	node_top = "aurum_base:gravel",
	depth_top = 1,
	heat_point = 30,
	humidity_point = 30,
})

-- Grassland

aurum.biomes.register("aurum:aurum", {
	name = "aurum_grassland",
	node_top = "aurum_base:grass",
	depth_top = 1,
	node_filler = "aurum_base:dirt",
	depth_filler = 4,
	heat_point = 40,
	humidity_point = 40,
})

aurum.biomes.register_tree_decoration({
	name = "aurum_trees:oak",
	biomes = {"aurum_grassland"},
	rarity = 0.01,
})

aurum.biomes.register_tree_decoration({
	name = "aurum_trees:birch",
	biomes = {"aurum_grassland"},
	rarity = 0.01,
})

-- Forest

aurum.biomes.register("aurum:aurum", {
	name = "aurum_forest",
	node_top = "aurum_base:grass",
	depth_top = 1,
	node_filler = "aurum_base:dirt",
	depth_filler = 4,
	heat_point = 50,
	humidity_point = 50,
})

aurum.biomes.register_tree_decoration({
	name = "aurum_trees:oak",
	biomes = {"aurum_forest"},
})

aurum.biomes.register_tree_decoration({
	name = "aurum_trees:birch",
	biomes = {"aurum_forest"},
})