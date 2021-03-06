local S = aurum.get_translator()

doc.add_category("aurum_magic:spells", {
	name = S"Spells",
	build_formspec = doc.entry_builders.text,
})

doc.add_entry("basics", "aurum_magic:spells", {
	name = S"Spells",
	data = {
		text = table.concat({
			S"Spells are found within Spell Scrolls. There are various levels of each spell's power.",
			S"They can be produced through ritual or found in the world.",
			S"They can be applied to certain objects like rods for use.",
		}, "\n"),
	},
})

doc.add_category("aurum_magic:rituals", {
	name = S"Rituals",
	build_formspec = function(def)
		local x = doc.FORMSPEC.ENTRY_START_X
		local y = doc.FORMSPEC.ENTRY_START_Y
		local w = doc.FORMSPEC.ENTRY_WIDTH
		local h = doc.FORMSPEC.ENTRY_HEIGHT
		local fs = ""

		local text = {}
		if def.longdesc then
			table.insert(text, def.longdesc)
		end
		if def.type == "spell" then
			table.insert(text, S"Insert empty scrolls into the scroll hole. When the ritual is cast, a number of spell scrolls will be produced. Fewer scrolls means higher-level spells.")
		end
		table.insert(text, S"The recipe is to the right. Each section represents a slice in the vertical stack. The altar is the center, sections above the altar must be placed above it during the ritual.")
		fs = fs .. doc.widgets.text(table.concat(text, "\n\n"), nil, nil, w / 3)

		x = x + w / 3 + 0.5
		y = y + 0.25

		local total = vector.subtract(def.size.b, def.size.a)
		local scale = {
			x = math.min(1, 7 / (total.x + 1)),
			y = math.min(1, 3 / (total.y + 1), 2.5 / (total.z + 1))
		}

		for _,pos in ipairs(b.box.poses(def.size)) do
			local rpos = vector.subtract(pos, def.size.a)
			local hash = minetest.hash_node_position(pos)
			local node = vector.equals(pos, vector.new(0, 0, 0)) and "aurum_magic:altar" or def.hashed_recipe[hash] or ""
			local mod, name = node:match("([^:]*):(.*)")
			if mod == "group" then
				for k,v in pairs(minetest.registered_items) do
					if (v.groups[name] or 0) > 0 then
						node = k
						break
					end
				end
			end
			local image_name = ("%d_%d_%d"):format(pos.x, pos.y, pos.z)
			if node then
				fs = fs .. ("item_image_button[%f,%f;%f,%f;%s;%s;%d,%d,%d%s]"):format(
					x + rpos.x * scale.x, y + (rpos.z + (total.y - rpos.y) * (total.z + 2)) * scale.y,
					scale.x, scale.y,
					node,
					image_name,
					pos.x, pos.y, pos.z,
					(mod == "group") and "\nG" or "")
			end
			if mod == "group" then
				fs = fs .. ("tooltip[%s;%s]"):format(image_name, minetest.formspec_escape(S("Any node in group '@1'", name)))
			end
		end

		return fs
	end,
})

doc.add_entry("basics", "aurum_magic:rituals", {
	name = S"Rituals",
	data = {
		text = table.concat({
			S"Rituals are powerful invocations to perform certain magical actions.",
			S"All rituals are centered around an altar, but each ritual has its own rules.",
			S"Rituals and their setup are described in their own documentation category.",
		}, "\n"),
	},
})
