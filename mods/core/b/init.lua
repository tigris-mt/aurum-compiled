b = {}

-- Do a file relative to the current mod.
b.dofile = function(path)
	return dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. path)
end

b.DODIR_INIT = "init.lua"

b.dodir = function(path)
	local path = minetest.get_modpath(minetest.get_current_modname()) .. "/" .. path
	local names = b.set(minetest.get_dir_list(path, false))
	-- Execute init file first if it exists.
	if names[b.DODIR_INIT] then
		dofile(path .. "/" .. b.DODIR_INIT)
		names[b.DODIR_INIT] = nil
	end
	-- Execute all other files.
	for name in b.set.iter(names) do
		dofile(path .. "/" .. name)
	end
end

b.dofile("cache.lua")
b.dofile("table.lua")
b.dofile("set.lua")

b.dodir("geometry")
b.dodir("pathfinder")
b.dofile("world.lua")
