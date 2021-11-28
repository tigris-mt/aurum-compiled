function b.random_whole(n, random)
	random = random or math.random
	if n < 0 then
		return -b.random_whole(-n)
	else
		local whole = math.floor(n)
		return whole + (random() < (n - whole) and 1 or 0)
	end
end

-- Returns math.random compatible function based on the supplied seed.
function b.seed_random(seed)
	local rng = PcgRandom(seed)
	local f
	f = function(a, b)
		if a then
			if b then
				local lower = a
				local upper = b + 1
				return math.floor(f() * (upper - lower) + lower)
			else
				return f(1, a)
			end
		else
			return (rng:next() + 2147483648) / (2147483648 + 2147483648)
		end
	end
	return f
end
