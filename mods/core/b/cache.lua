b.cache = {}

function b.cache.simple(f, get_key)
	local cache = {
		cache = {},
		stored = {},
		f = f,
	}
	local stored = {}
	return function(...)
		local key = get_key(...)
		if not cache.stored[key] then
			cache.cache[key] = f(...)
			cache.stored[key] = true
		end
		return cache.cache[key]
	end, cache
end
