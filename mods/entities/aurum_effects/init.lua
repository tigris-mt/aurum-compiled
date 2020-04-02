local S = minetest.get_translator()
aurum.effects = {
	effects = {},
	enchants = {},
}

function aurum.effects.add(object, name, level, duration)
	local def = aurum.effects.effects[name]

	if object:is_player() then
		for i=level+1,def.max_level do
			if playereffects.has_effect_type(object:get_player_name(), name .. "_" .. i) then
				return false
			end
		end
		for i=1,level-1 do
			playereffects.cancel_effect_type(name .. "_" .. i, true, object:get_player_name())
		end
		return playereffects.apply_effect_type(name .. "_" .. level, duration, object, 0)
	else
		local mob = aurum.mobs.get_mob(object)
		if mob then
			if mob.data.status_effects[name] and mob.data.status_effects[name].level > level then
				return false
			end

			mob.data.status_effects[name] = {
				duration = duration,
				next = def.repeat_interval,
				level = level,
			}

			def.apply(object, level)
		end
	end
	return false
end

function aurum.effects.remove(object, name)
	if object:is_player() then
		playereffects.cancel_effect_group(name, object:get_player_name())
	else
		local mob = aurum.mobs.get_mob(object)
		if mob then
			if mob.data.status_effects[name] then
				aurum.effects.effects[name].cancel(object, mob.data.status_effects[name].level)
				mob.data.status_effects[name] = nil
			end
		end
	end
end

function aurum.effects.has(object, name)
	if object:is_player() then
		for level=1,aurum.effects.effects[name].maxlevel do
			if playereffects.has_effect_type(object:get_player_name(), name .. "_" .. level) then
				return level
			end
		end
	else
		local mob = aurum.mobs.get_mob(object)
		if mob then
			if mob.data.status_effects[name] then
				return mob.data.status_effects[name].level
			end
		end
	end
	return false
end

function aurum.effects.register(name, def)
	local def = b.t.combine({
		-- Maximum effect level.
		max_level = 1,
		-- Human readable description.
		description = "?",
		-- Optional icon for display in the HUD or elsewhere.
		icon = nil,
		-- If set, this effect will apply repeatedly every interval.
		repeat_interval = nil,
		-- Shall this effect be hidden from the player?
		hidden = false,
		-- Cancel the effect on the target's death?
		cancel_on_death = true,
		-- If set, create an enchantment for this effect that can be placed on the specified groups.
		enchant = b.set{"tool"},
		-- What should the duration of this effect be for a specific enchantment level?
		tool_duration = function(level)
			return 5
		end,
		-- Apply this level of effect to an object.
		apply = function(object, level) end,
		-- Cancel this level of effect to an object.
		cancel = function(object, level) end,
	}, def, {name = name})

	for level=1,def.max_level do
		playereffects.register_effect_type(name .. "_" .. level, S("@1 @2", def.description, tostring(level)), def.icon, {name, "aurum_effects"},
			function(object)
				def.apply(object, level)
			end,
			function(effect, object, level)
				def.cancel(object, level)
			end, def.hidden, def.cancel_on_death, def.repeat_interval)
	end

	if def.enchant then
		aurum.tools.register_enchant("effect_" .. name, {
			categories = def.enchant,
			max_level = def.max_level,
			description = S("@1 Essence", def.description),
			longdesc = S("Applies the @1 effect on a hit.", def.description),
		})
		aurum.effects.enchants["effect_" .. name] = def
	end

	aurum.effects.effects[name] = def
end

function aurum.effects.apply_tool_effects(stack, object)
	for k,v in pairs(aurum.tools.get_item_enchants(stack)) do
		local e = aurum.effects.enchants[k]
		if e then
			aurum.effects.add(object, e.name, v, e.tool_duration(v))
		end
	end
end

minetest.register_on_punchplayer(function(player, hitter)
	if player:get_hp() > 0 then
		aurum.effects.apply_tool_effects(hitter:get_wielded_item(), player)
	end
end)

b.dodir("effects")