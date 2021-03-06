local S = minetest.get_translator("xmana")

xmana = {}

-- Exponential level growth.
xmana.EXPONENT = tonumber(minetest.settings:get("xmana.exponent")) or 2.5

function xmana.level_to_mana(level)
	return level ^ xmana.EXPONENT
end

function xmana.mana_to_level(mana)
	return math.floor(mana ^ (1 / xmana.EXPONENT))
end

-- Maximum mana possible.
xmana.MAX_LEVEL = tonumber(minetest.settings:get("xmana.max_level")) or 30
xmana.MAX = math.ceil(xmana.level_to_mana(xmana.MAX_LEVEL))

-- Follow trigger distance.
xmana.TRIGGER = tonumber(minetest.settings:get("xmana.trigger")) or 5

-- Callback function to be overridden.
-- Called whenever mana changes.
-- See xmana.mana() for a description of the reason.
xmana.callback = function(player, old, new, reason) end

-- Access a player object's mana. If set is false, return current value. If set is a number, set to that. If relative is true, add the current value to the set.
-- Reason is an optional parameter to describe what changed it.
-- Current values include: nil by default, "command" if changed by command, "spark" if from mana sparks.
function xmana.mana(player, set, relative, reason)
	if set then
		local old = xmana.mana(player)
		-- Actual amount set when relative is true is current + set.
		local set = relative and (set + old) or set
		-- Clamp to reasonable values.
		set = math.max(0, math.min(set, xmana.MAX))

		player:get_meta():set_float("xmana:mana", set)
		hb.change_hudbar(player, "xmana", xmana.mana_to_level(set), xmana.MAX_LEVEL, nil, nil, nil, S("Mana: @1 (@2)", xmana.mana_to_level(set), set))

		xmana.callback(player, old, set, reason)
	else
		return player:get_meta():get_float("xmana:mana", set)
	end
end

minetest.register_on_respawnplayer(function(player)
	xmana.mana(player, 0)
end)

local timer = 0

minetest.register_on_joinplayer(function(player)
	hb.init_hudbar(player, "xmana", xmana.mana_to_level(xmana.mana(player)), xmana.MAX_LEVEL)
	timer = 10
end)

minetest.register_globalstep(function(dtime)
	if timer > 0 then
		timer = timer - dtime
		for _,player in ipairs(minetest.get_connected_players()) do
			xmana.mana(player, 0, true)
		end
	end
end)

hb.register_hudbar("xmana", 0xFFFFFF, S"Mana", {
	bar = "xmana_bg.png",
	icon = "xmana_icon.png",
	bgicon = "xmana_bgicon.png"
}, 0, xmana.MAX_LEVEL, false, "@1", {order = {"label"}})

minetest.register_privilege("mana", {
	description = S"Can modify player mana.",
	give_to_singleplayer = false
})

minetest.register_chatcommand("mana", {
	params = S"<amount> [<username or self>] [<absolute boolean>]",
	description = S"Set player mana.",
	privs = {mana = true},
	func = function(caller, param)
		local split = param:split(" ")

		local amount = tonumber(split[1])
		local target = split[2] and minetest.get_player_by_name(split[1]) or minetest.get_player_by_name(caller)
		local relative = not minetest.is_yes(split[3])

		if not amount then
			return false, S"Invalid amount."
		end

		if not target then
			return false, S"Invalid target."
		end

		xmana.mana(target, amount, relative, "command")
		return true, S("@1 now has @2 levels (@3 mana)", target:get_player_name(), xmana.mana_to_level(xmana.mana(target)), xmana.mana(target))
	end,
})

if minetest.get_modpath("doc_basics") then
	doc.add_entry("basics", "xmana", {
		name = S"Mana",
		data = {
			text = table.concat({
				S"Mana is the measure of energy gathered within you.\n",
				S"Mana is organized into levels, with higher levels consisting of exponentially more mana.",
				S"You may gain mana through various means.",
				S"You may spend mana on special effects or items.",
			}, "\n"),
		},
	})
end

xmana.spark_values = {1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683}

for i,v in ipairs(xmana.spark_values) do
	minetest.register_entity("xmana:spark_" .. i, {
		physical = true,
		collide_with_objects = false,
		hp_max = 1,
		visual = "sprite",
		visual_size = {x = 0.5 + i / 5, y = 0.5 + i / 10},
		textures = {"xmana_spark.png"},
		collisionbox = {-0.3,-0.3,-0.3,0.3,-0.3,0.3},

		on_activate = function(self, staticdata)
			local d = (staticdata and #staticdata > 0) and minetest.deserialize(staticdata) or {}
			self.owner = d.owner
			self.age = d.age
			self.triggered = d.triggered
		end,

		get_staticdata = function(self)
			return minetest.serialize{
				owner = self.owner,
				age = self.age,
				triggered = self.triggered,
			}
		end,

		on_step = function(self, dtime)
			if not self.owner or not self.age then
				self.object:remove()
				return
			end

			self.age = self.age + dtime
			if self.age > 300 then
				self.object:remove()
				return
			end

			if self.age < 1 then
				return
			end

			local prop = self.object:get_properties()
			prop.physical = true
			self.object:set_acceleration(vector.new(0, -9.81, 0))

			if self.age > 3 and not self.triggered then
				self.object:set_velocity(vector.multiply(self.object:get_velocity(), vector.new(0, 1, 0)))
			end

			local player = minetest.get_player_by_name(self.owner)
			if player then
				local dist = vector.distance(player:get_pos(), self.object:get_pos())
				if dist <= xmana.TRIGGER then
					self.triggered = true
				end
				if self.triggered then
					if dist <= 2 then
						if minetest.get_modpath("item_drop") then
							minetest.sound_play("item_drop_pickup", {
								pos = self.object:get_pos(),
								gain = 0.2,
							})
						end
						xmana.mana(player, v, true, "spark")
						self.object:remove()
						return
					else
						local norm = vector.normalize(vector.subtract(player:get_pos(), self.object:get_pos()))
						self.object:set_velocity(vector.multiply(norm, 4 * math.max(1, dist / 2)))
						prop.physical = false
						self.object:set_acceleration(vector.new(0, 0, 0))
					end
				end
			end

			self.object:set_properties(prop)
		end,
	})
end

function xmana.sparks(pos, value, owner)
	local function best(n)
		for i=#xmana.spark_values,1,-1 do
			local v = xmana.spark_values[i]
			if v <= value then
				return i,v
			end
		end
		error("invalid value")
	end
	while value > 0 do
		local i,v = best(value)
		value = value - v

		local function r(c)
			return c - 0.5 + math.random()
		end
		local obj = minetest.add_entity(vector.apply(pos, r), "xmana:spark_" .. i, minetest.serialize({owner = owner, age = 0, triggered = false}))
		if obj then
			obj:set_velocity(vector.multiply(vector.apply(vector.new(0, 1, 0), r), 3))
			obj:set_acceleration(vector.new(0, -9.81, 0))
		end
	end
end

minetest.register_chatcommand("manasparks", {
	params = S"<amount>",
	description = S"Spawn mana sparks.",
	privs = {mana = true},
	func = function(caller, param)
		local amount = tonumber(param)
		local player = minetest.get_player_by_name(caller)

		if not amount then
			return false, S"Invalid amount."
		end

		if not player then
			return false, S"Cannot get position."
		end

		xmana.sparks(player:get_pos(), amount, caller)

		return true, "Spawned sparks."
	end,
})
