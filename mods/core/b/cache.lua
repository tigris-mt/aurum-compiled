b.cache = {}

function b.cache.simple(f, get_key)
	local cache = {}
	local stored = {}
	return function(...)
		local key = get_key(...)
		if not stored[key] then
			cache[key] = f(...)
			stored[key] = true
		end
		return cache[key]
	end
end
