function b.random_whole(n)
	if n < 0 then
		return -b.random_whole(-n)
	else
		local whole = math.floor(n)
		return whole + (math.random() < (n - whole) and 1 or 0)
	end
end
