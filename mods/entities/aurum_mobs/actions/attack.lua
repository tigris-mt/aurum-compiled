aurum.mobs.initial_data.attack = {
	damage = {blade = 2},
	moves = 0,
	speed = 1,
	distance = 2.5,
	effects = {},
	-- Name of projectile to fire if ranged.
	fire_projectile = nil,
	projectile_speed = 25,
}

function aurum.mobs.helper_do_attack(object, attack, target)
	target:punch(object, 1, {
		full_punch_interval = 1.0,
		damage_groups = attack.damage,
	})

	for name,def in pairs(attack.effects) do
		aurum.effects.add(target, name, def.level, def.duration)
	end
end

gemai.register_action("aurum_mobs:attack", function(self)
	local target = aurum.mobs.helper_target_entity(self, self.data.params.target)
	if not target then
		self:fire_event("lost")
		return
	end

	local ranged = not not self.data.attack.fire_projectile
	local too_far = vector.distance(target:get_pos(), self.entity.object:get_pos()) > self.data.attack.distance

	if ranged then
		if not aurum.mobs.helper_can_see(self, target) or too_far then
			self:fire_event("lost_sight", self.data.params)
			return
		end
	else
		if too_far then
			self:fire_event("noreach", self.data.params)
			return
		end
	end

	self.data.attack.moves = self.data.attack.moves + self.data.step_time * self.data.attack.speed

	local whole = math.floor(self.data.attack.moves)
	self.data.attack.moves = self.data.attack.moves - whole
	for _=1,whole do
		if ranged then
			gprojectiles.spawn(self.data.attack.fire_projectile, {
				pos = vector.add(self.entity.object:get_pos(), vector.new(0, math.random() * 0.5, 0)),
				velocity = vector.multiply(vector.normalize(vector.subtract(vector.add(target:get_pos(), vector.new(0, target:get_properties().collisionbox[5] / 2, 0)), self.entity.object:get_pos())), self.data.attack.projectile_speed),
				skip_first = self.entity.object,
				data = {
					attack = self.data.attack,
				},
			})
		else
			aurum.mobs.helper_do_attack(self.entity.object, self.data.attack, target)
		end
	end
end)
