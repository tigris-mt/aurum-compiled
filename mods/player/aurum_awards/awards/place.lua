local S = minetest.get_translator()

awards.register_award("aurum_awards:fertilizer", {
	title = S"You Cannot Eat Money",
	description = S"Place 15 fertilizer.",
	trigger = {
		type = "place",
		node = "group:fertilizer",
		target = 15,
	},
})
