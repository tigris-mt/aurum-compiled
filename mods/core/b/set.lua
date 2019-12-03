b.set = {}

-- Convert an array to a set.
function b.set.new(t)
	local r = {}
	for _,v in ipairs(t) do
		r[v] = true
	end
	return r
end

-- Alias b.set() to b.set.new().
setmetatable(b.set, {__call = function(t, v) return b.set.new(v) end})

-- Get a set with all entries from parameter sets.
function b.set.union(...)
	local r = {}
	for _,s in ipairs{...} do
		for k in b.set.iter(s) do
			r[k] = true
		end
	end
	return r
end

-- Get a set with only the entries that are in every parameter set.
function b.set.intersection(...)
	local r = {}
	local p = {...}
	for _,s in ipairs(p) do
		for k in b.set.iter(s) do
			r[k] = (r[k] or 0) + 1
		end
	end
	return b.t.map(r, function(v) return (v == #p) and v or nil end)
end

-- Get a set with only the entries that are in a single parameter set.
function b.set.difference(...)
	local r = {}
	local p = {...}
	for _,s in ipairs(p) do
		for k in b.set.iter(s) do
			r[k] = (r[k] or 0) + 1
		end
	end
	return b.t.map(r, function(v) return (v == 1) and v or nil end)
end

-- Convert a set to an array.
function b.set.to_array(set)
	return b.t.keys(set)
end

-- Set iterator, iterates over entries.
b.set.iter = pairs

