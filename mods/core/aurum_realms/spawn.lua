-- Get the central spawn point for a realm.
function aurum.realms.get_spawn(id)
	local pos = aurum.gpos(id, vector.new(0, 0, 0))
	pos = table.combine(pos, {y = minetest.get_spawn_level(pos.x, pos.z)})

	for y=0,150 do
		local t = vector.add(pos, vector.new(0, y, 0))
		local function above(n)
			return aurum.force_get_node(vector.add(t, vector.new(0, n, 0))).name
		end

		if above(0) == "air" and above(1) == "air" and above(2) == "air" then
			return t
		end
	end

	return pos
end

minetest.register_chatcommand("rteleport", {
	params = "<realm>",
	description = "Teleport to a realm's spawn",
	privs = {teleport = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end

		if not aurum.realms.get(param) then
			return false, "No such realm."
		end

		aurum.player.teleport_guarantee(player, aurum.box.new_add(aurum.realms.get_spawn(param), vector.new(0, 150, 0)), function(player)
			aurum.player.teleport(player, aurum.realms.get_spawn(param))
		end)
		return true, "Teleporting to " .. param
	end,
})
