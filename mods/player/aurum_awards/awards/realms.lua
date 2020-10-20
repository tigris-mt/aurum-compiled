local S = aurum.get_translator()

awards.register_award("aurum_awards:loom", {
	title = S"Flame Seeker",
	description = S"Enter the Loom.",
	difficulty = 50,
	icon = "fire_basic_flame.png",
	trigger = {
		type = "realm_change",
		realm = "aurum:loom",
		target = 1,
	},
})

awards.register_award("aurum_awards:aether", {
	title = S"The Realm of Hyperion",
	description = S"Enter the Aether.",
	difficulty = 75,
	icon = "aurum_base_aether_shell.png",
	trigger = {
		type = "realm_change",
		realm = "aurum:aether",
		target = 1,
	},
})
