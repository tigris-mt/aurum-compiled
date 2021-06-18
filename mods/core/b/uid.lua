local storage = minetest.get_mod_storage()

function b.new_uid()
	local uid = storage:get_int("uid") + 1
	storage:set_int("uid", uid)
	return uid
end
