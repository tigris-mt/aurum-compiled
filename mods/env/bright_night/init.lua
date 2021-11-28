bright_night = {}

-- engine const
local SUNLIGHT = 15

-- mod config
local night_light = math.max(math.min(tonumber(minetest.settings:get("bright_night_light")) or 4, 15), 3)
local auto = minetest.settings:get_bool("bright_night_auto", true)
local dawn = ({0.1979, 0.2049, 0.2118, 0.2170, 0.2216, 0.2259, 0.2299, 0.2339, 0.2374, 0.2409, 0.2443, 0.2497, 0.25})[night_light-2]
local dusk = ({0.7952, 0.7882, 0.7831, 0.7784, 0.7741, 0.7702, 0.7662, 0.7626, 0.7592, 0.7557, 0.7503, 0.7402, 0.74})[night_light-2]

-- mod active values
local night_mode = false

local function set_night(player)
	player:override_day_night_ratio(night_light / SUNLIGHT)
end

local function unset_night(player)
	player:override_day_night_ratio(nil)
end

if auto then
	minetest.register_on_joinplayer(function(player)
		bright_night.apply(player)
	end)
end

function bright_night.apply(object)
	if night_mode then
		set_night(object)
	else
		unset_night(object)
	end
end

minetest.register_globalstep(function()
	local time = minetest.get_timeofday()
	if time < dawn or time > dusk then
		if not night_mode then
			night_mode = true
		end
	elseif night_mode then
		night_mode = false
	end

	if auto then
		for _, player in ipairs(minetest.get_connected_players()) do
			bright_night.apply(player)
		end
	end
end)

