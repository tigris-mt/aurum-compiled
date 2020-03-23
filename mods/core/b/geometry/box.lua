b.box = {}

-- Returns true if box a and box b have collided.
function b.box.collide_box(a, b)
    local e = {
        a = b.box.extremes(a),
        b = b.box.extremes(b),
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
function b.box.inside_box(inner, outer)
	local e = {
        i = b.box.extremes(inner),
        o = b.box.extremes(outer),
    }

	for _,axis in ipairs({"x", "y", "z"}) do
		if e.i.a[axis] < e.o.a[axis] or e.i.b[axis] > e.o.b[axis] then
			return false
		end
	end

	return true
end

-- Check if <point> collides with <box>.
function b.box.collide_point(box, point)
	return b.box.collide_box(box, b.box.new(point, point))
end

-- Get the extremes of the box.
function b.box.extremes(box)
	local min, max = vector.sort(box.a, box.b)
	return b.box.new(min, max)
end

-- Get the box translated to a position
function b.box.translate(box, pos)
	return b.box.new(vector.add(box.a, pos), vector.add(box.b, pos))
end

-- From corners.
function b.box.new(a, b)
	return {a = a, b = b}
end

-- From addition.
function b.box.new_add(a, b)
	return b.box.new(a, vector.add(a, b))
end

-- From entity collision box.
function b.box.new_cbox(box)
    return b.geometry.Box.new(vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6]))
end

-- From radius.
function b.box.new_radius(center, radius)
	return b.box.new(vector.subtract(center, radius), vector.add(center, radius))
end

-- Convert box to VoxelArea.
function b.box.voxelarea(box)
	return VoxelArea:new{MinEdge=box.a, MaxEdge=box.b}
end

-- Get all positions in the box.
-- If sort_near is specified, the positions will be sorted in order nearest to sort_near.
function b.box.poses(box, sort_near)
	local poses = {}
	local box = b.box.extremes(box)
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
