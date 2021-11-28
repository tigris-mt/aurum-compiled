b = {}

-- Do a file relative to the current mod.
b.dofile = function(path)
	return dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. path)
end

b.DODIR_INIT = "init.lua"

b.dodir = function(path, recursive)
	local gpath = minetest.get_modpath(minetest.get_current_modname()) .. "/" .. path
	local names = b.set(minetest.get_dir_list(gpath, false))
	-- Execute init file first if it exists.
	if names[b.DODIR_INIT] then
		dofile(gpath .. "/" .. b.DODIR_INIT)
		names[b.DODIR_INIT] = nil
	end
	-- Execute all other files.
	for name in b.set.iter(names) do
		dofile(gpath .. "/" .. name)
	end

	-- Descend recursively.
	if recursive then
		for _,name in ipairs(minetest.get_dir_list(gpath, true)) do
			b.dodir(path .. "/" .. name, recursive)
		end
	end
end

b.dofile("chance.lua")

b.dofile("cache.lua")
b.dofile("table.lua")
b.dofile("set.lua")
b.dofile("uid.lua")

b.dofile("color.lua")
b.dodir("geometry")
b.dodir("pathfinder")
b.dofile("ref_table.lua")
b.dofile("world.lua")
