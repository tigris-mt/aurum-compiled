-- If player is underground, do <f()>.
-- <yunder> specifies the maximum underground y coordinate.
function screalms.check_underground(player, yunder, f)
	if player:get_pos().y > yunder then
		return
	end

	-- What node is the player's head in?
	local nh = minetest.registered_nodes[minetest.get_node(vector.add(player:get_pos(), vector.new(0, 1.5, 0))).name]

	-- If the node is probably see-through, then assume the player is legitimately underground.
	if nh.walkable == false or nh.drawtype == "mesh" then
		f()
	end
end

-- Default underground handling.
function screalms.apply_underground(player)
	screalms.check_underground(player, -100, function()
		player:set_sky(0, "plain", {})
		player:set_clouds{density = 0}
	end)
end
