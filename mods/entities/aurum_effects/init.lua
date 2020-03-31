local S = minetest.get_translator()
aurum.effects = {
	effects = {},
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
		max_level = 1,
		description = "?",
		icon = nil,
		repeat_interval = nil,
		hidden = false,
		cancel_on_death = true,
		repeat_interval = nil,
		apply = function(object, level) end,
		cancel = function(object, level) end,
	}, def)

	for level=1,def.max_level do
		playereffects.register_effect_type(name .. "_" .. level, S("@1 @2", def.description, tostring(level)), def.icon, {name, "aurum_effects"},
			function(object)
				def.apply(object, level)
			end,
			function(effect, object, level)
				def.cancel(object, level)
			end, def.hidden, def.cancel_on_death, def.repeat_interval)
	end

	aurum.effects.effects[name] = def
end

b.dodir("effects")
