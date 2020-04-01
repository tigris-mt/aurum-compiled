local m = {}
b.box = m

-- Returns true if box a and box b have collided.
function m.collide_box(a, b)
    local e = {
        a = m.extremes(a),
        b = m.extremes(b),
    }

    local function beyond(axis)
        if e.a.a[axis] < e.b.a[axis] and e.a.b[axis] < e.b.a[axis] then
            return true
        elseif e.a.a[axis] > e.b.b[axis] and e.a.b[axis] > e.b.b[axis] then
            return true
        elseif e.b.a[axis] < e.a.a[axis] and e.b.b[axis] < e.a.a[axis] then
            return true
        elseif e.b.a[axis] > e.a.b[axis] and e.b.b[axis] > e.a.b[axis] then
            return true
        else
            return false
        end
    end

    for _,axis in ipairs({"x", "y", "z"}) do
        if beyond(axis) then
            return false
        end
    end
    return true
end

-- Returns true if <inner> is inside <outer>.
function m.inside_box(inner, outer)
	local e = {
        i = m.extremes(inner),
        o = m.extremes(outer),
    }

	for _,axis in ipairs({"x", "y", "z"}) do
		if e.i.a[axis] < e.o.a[axis] or e.i.b[axis] > e.o.b[axis] then
			return false
		end
	end

	return true
end

-- Check if <point> collides with <box>.
function m.collide_point(box, point)
	return m.collide_box(box, m.new(point, point))
end

-- Get the extremes of the box.
function m.extremes(box)
	local min, max = vector.sort(box.a, box.b)
	return m.new(min, max)
end

-- Get the box translated to a position
function m.translate(box, pos)
	return m.new(vector.add(box.a, pos), vector.add(box.b, pos))
end

-- From corners.
function m.new(a, b)
	return {a = a, b = b}
end

-- From addition.
function m.new_add(a, b)
	return m.new(a, vector.add(a, b))
end

-- From entity collision box.
function m.new_cbox(box)
    return b.geometry.Box.new(vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6]))
end

-- From radius.
function m.new_radius(center, radius)
	return m.new(vector.subtract(center, radius), vector.add(center, radius))
end

-- Convert box to VoxelArea.
function m.voxelarea(box)
	return VoxelArea:new{MinEdge=box.a, MaxEdge=box.b}
end

-- To entity collision box.
function m.to_cbox(box)
	return {
		box.a.x,
		box.a.y,
		box.a.z,
		box.b.x,
		box.b.y,
		box.b.z,
	}
end

-- Get all positions in the box.
-- If sort_near is specified, the positions will be sorted in order nearest to sort_near.
function m.poses(box, sort_near)
	local poses = {}
	local box = m.extremes(box)
	for x=box.a.x,box.b.x do
		for y=box.a.y,box.b.y do
			for z=box.a.z,box.b.z do
				table.insert(poses, vector.new(x, y, z))
			end
		end
	end
	if sort_near then
		table.sort(poses, function(a, b)
			-- TODO: Use faster sorting method.
			return vector.distance(sort_near, a) < vector.distance(sort_near, b)
		end)
	end
	return poses
end
