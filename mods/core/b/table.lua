b.t = {}

-- Combine tables and return the result. Later tables take priority.
function b.t.combine(...)
	return b.t.merge({}, ...)
end

-- Combine array tables in order.
function b.t.icombine(...)
	return b.t.imerge({}, ...)
end

function b.t.flagarray(t, i)
	local ret = {}
	for _,v in ipairs(t) do
		if i then
			table.insert(ret, v)
		end
		ret[v] = true
	end
	return ret
end

-- Get an array of all keys from tables.
function b.t.keys(...)
	assert(#({...}) > 0, "no arguments")
	local ret = {}
	local have = {}
	for _,t in ipairs({...}) do
		for k in pairs(t) do
			if not have[k] then
				table.insert(ret, k)
				have[k] = true
			end
		end
	end
	return ret
end

-- Loop through the parts of t, with keys sorted by f.
function b.t.spairs(t, f)
	local keys = b.t.keys(t)
	if f then
		table.sort(keys, function(a, b) return f(t, a, b) end)
	else
		table.sort(keys)
	end

	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

-- Apply f() to all elements of t and return the result.
-- The signature of f is f(value, key), and it returns the new value.
function b.t.map(t, f)
	local ret = {}
	for k,v in pairs(t) do
		ret[k] = f(v, k)
	end
	return ret
end

function b.t.imap(t, f)
	local ret = {}
	for i,v in ipairs(t) do
		local new = f(v, i)
		if new then
			table.insert(ret, new)
		end
	end
	return ret
end

-- Return a shuffled version of an array.
function b.t.shuffled(t)
	local ret = {}
	local keys = b.t.keys(t)
	while #keys > 0 do
		local ki = math.random(#keys)
		table.insert(ret, t[keys[ki]])
		table.remove(keys, ki)
	end
	return ret
end

function b.t.choice(t)
	return t[math.random(#t)]
end

-- Select a random, weighted choice.
-- Input is in the form: {{<value>, <relative weight>}, {<another value>, <its relative weight>}}
function b.t.weighted_choice(t)
	local total = 0
	for _,v in ipairs(t) do
		total = total + v[2]
	end

	local index = math.random() * total

	for _,v in ipairs(t) do
		index = index - v[2]
		if index <= 0 then
			return v[1]
		end
	end
end

-- Duplicate x n times and return the resulting table. No deep copying done.
function b.t.duplicate(x, n)
	local ret = {}
	for i=1,n do
		ret[i] = x
	end
	return ret
end

function b.t.deep_copy(t)
	if type(t) == "table" then
		local ret = {}
		for k,v in pairs(t) do
			ret[k] = b.t.deep_copy(v)
		end
		return ret
	else
		return t
	end
end

function b.t.merge(to, ...)
	for _,t in ipairs{...} do
		for k,v in pairs(t) do
			to[k] = v
		end
	end
	return to
end

function b.t.imerge(to, ...)
	for _,t in ipairs{...} do
		for _,v in ipairs(t) do
			table.insert(to, v)
		end
	end
	return to
end

-- Iterate through all elements in the array array, but start at a random point.
function b.t.ro_ipairs(array)
	if #array <= 1 then
		return ipairs(array)
	else
		local i = 0
		local start = math.random(#array)
		return function()
			i = i + 1
			local wi = ((i + start) % #array) + 1
			if i <= #array then
				return wi, array[wi]
			end
		end
	end
end
