local meta = FindMetaTable("Entity")
if not meta then return end

function meta:TakeSpecialDamage(damage, damagetype, attacker, inflictor, hitpos)
	attacker = attacker or self
	if not attacker:IsValid() then attacker = self end
	inflictor = inflictor or attacker
	if not inflictor:IsValid() then inflictor = attacker end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	dmginfo:SetDamagePosition(hitpos or self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter()))))
	dmginfo:SetDamageType(damagetype)
	self:TakeDamageInfo(dmginfo)

	return dmginfo
end

function meta:IsProjectile()
	return self:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE or self.m_IsProjectile
end

function meta:ResetBones(onlyscale)
	local v = Vector(1, 1, 1)
	if onlyscale then
		for i=0, self:GetBoneCount() - 1 do
			self:ManipulateBoneScale(i, v)
		end
	else
		local a = Angle(0, 0, 0)
		for i=0, self:GetBoneCount() - 1 do
			self:ManipulateBoneScale(i, v)
			self:ManipulateBoneAngles(i, a)
			self:ManipulateBonePosition(i, vector_origin)
		end
	end
end

function meta:SetTeamID(teamid)
	self.TeamID = teamid
end

function meta:GetTeamID()
	return self.Team and self:Team() or self.TeamID or 0
end

function meta:SetBarricadeHealth(m)
	self:SetDTFloat(1, m)
end

function meta:GetBarricadeHealth()
	return self:GetDTFloat(1)
end

function meta:SetMaxBarricadeHealth(m)
	self:SetDTFloat(2, m)
end

function meta:GetMaxBarricadeHealth()
	return self:GetDTFloat(2)
end

function meta:SetBarricadeRepairs(m)
	self:SetDTFloat(3, m)
end

function meta:GetBarricadeRepairs()
	return self:GetDTFloat(3)
end

function meta:GetMaxBarricadeRepairs()
	return self:GetMaxBarricadeHealth() * 1.5
end

function meta:GetBonePositionMatrixed(index)
	local matrix = self:GetBoneMatrix(index)
	if matrix then
		return matrix:GetTranslation(), matrix:GetAngles()
	end

	return self:GetPos(), self:GetAngles()
end

-- This needs to be done otherwise the physics might crash.
function meta:CollisionRulesChanged()
	if not self.m_OldCollisionGroup then self.m_OldCollisionGroup = self:GetCollisionGroup() end
	self:SetCollisionGroup(self.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
	self:SetCollisionGroup(self.m_OldCollisionGroup)
	self.m_OldCollisionGroup = nil
end

function meta:IsNailed()
	for _, nail in pairs(ents.FindByClass("prop_nail")) do
		if nail:IsValid() and (nail.GetAttachEntity and nail:GetAttachEntity() == self or nail.GetBaseEntity and nail:GetBaseEntity() == self) then
			return true
		end
	end

	return false
end

function meta:GetAlpha()
	return self:GetColor().a
end

function meta:SetAlpha(a)
	local col = self:GetColor()
	col.a = a
	self:SetColor(col)
end

local function barricadetimer(self, timername)
	if self:IsValid() then
		for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
			if e:IsPlayer() and e:Alive() then
				return
			end
		end

		self.IsBarricadeObject = nil
		self:CollisionRulesChanged()
	end

	timer.Destroy(timername)
end

function meta:TemporaryBarricadeObject()
	if self.IsBarricadeObject then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e:Alive() then
			self.IsBarricadeObject = true
			self:CollisionRulesChanged()

			local timername = "TemporaryBarricadeObject"..self:GetCreationID()
			timer.CreateEx(timername, 0, 0, barricadetimer, self, timername)

			return
		end
	end
end

function meta:IsBarricadeProp()
	return self.IsBarricadeObject or self:IsNailed()
end

function meta:GetHolder()
	for _, ent in pairs(ents.FindByClass("status_human_holding")) do
		if ent:GetObject() == self then
			local owner = ent:GetOwner()
			if owner:IsPlayer() and owner:Alive() then return owner, ent end
		end
	end
end

function meta:RemoveNextFrame(time)
	self.Removing = true
	self:Fire("kill", "", time or 0.01)
end

function meta:ThrowFromPosition(pos, force, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end

	if self:IsPlayer() and self:ActiveBarricadeGhosting() then return false end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):GetNormalized(), nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.abs(force)
			if absforce >= 512 or self.Clumsy and self:Team() ~= TEAM_UNDEAD and absforce >= 32 then
				self:KnockDown()
			end
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):GetNormalized())

		return true
	end
end

function meta:ThrowFromPositionSetZ(pos, force, zmul, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end
	zmul = zmul or 0.7

	if self:IsPlayer() and self:ActiveBarricadeGhosting() then return false end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.max(math.abs(force) * math.abs(zmul), math.abs(force))
			if absforce >= 512 or self.Clumsy and self:Team() ~= TEAM_UNDEAD and absforce >= 32 then
				self:KnockDown()
			end
		end

		local dir = self:LocalToWorld(self:OBBCenter()) - pos
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity(force * dir)

		return true
	end
end

function meta:ThrowFromPosition(pos, force, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end

	if self:IsPlayer() and self:ActiveBarricadeGhosting() then return false end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):GetNormalized(), nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.abs(force)
			if absforce >= 512 or self.Clumsy and self:Team() ~= TEAM_UNDEAD and absforce >= 32 then
				self:KnockDown()
			end
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):GetNormalized())

		return true
	end
end

function meta:ThrowFromPositionSetZ(pos, force, zmul, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end
	zmul = zmul or 0.7

	if self:IsPlayer() and self:ActiveBarricadeGhosting() then return false end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.max(math.abs(force) * math.abs(zmul), math.abs(force))
			if absforce >= 512 or self.Clumsy and self:Team() ~= TEAM_UNDEAD and absforce >= 32 then
				self:KnockDown()
			end
		end

		local dir = self:LocalToWorld(self:OBBCenter()) - pos
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity(force * dir)

		return true
	end
end

util.PrecacheSound("player/pl_pain5.wav")
util.PrecacheSound("player/pl_pain6.wav")
util.PrecacheSound("player/pl_pain7.wav")
function meta:PoisonDamage(damage, attacker, inflictor, hitpos, noreduction)
	damage = damage or 1

	local dmginfo = DamageInfo()

	if self:IsPlayer() then
		if ( !attacker:IsPlayer() and self:Team() == TEAM_UNDEAD ) or (attacker:IsPlayer() and self:Team() == attacker:Team() ) then return end

		self:ViewPunch(Angle(math.random(-10, 10), math.random(-10, 10), math.random(-20, 20)))
		self:EmitSound("player/pl_pain"..math.random(5, 7)..".wav")

		if SERVER then
			self:GiveStatus("poisonrecovery"):AddDamage(math.floor(damage * 0.75))
		end

		dmginfo:SetDamageType(DMG_ACID)
	else
		if not noreduction then
			damage = damage / 3
		end
		dmginfo:SetDamageType(DMG_SLASH) -- Fixes not doing damage to props.
	end

	attacker = attacker or self
	inflictor = inflictor or attacker

	dmginfo:SetDamagePosition(hitpos or self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter()))))
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	self:TakeDamageInfo(dmginfo)
end

if CLIENT then
	function meta:SetModelScaleVector(vec)
		if self:GetBoneCount() > 1 then
			local scale
			if type(vec) == "number" then
				scale = vec
			else
				scale = math.min(vec.x, vec.y, vec.z)
			end
			self._ModelScale = Vector(scale, scale, scale)
			self:SetModelScale(scale, 0)
		else
			if type(vec) == "number" then
				vec = Vector(vec, vec, vec)
			end

			self._ModelScale = vec
			local m = Matrix()
			m:Scale(vec)
			self:EnableMatrix("RenderMultiply", m)
		end
	end

	if not meta.TakeDamageInfo then
		meta.TakeDamageInfo = function() end
	end
	if not meta.SetPhysicsAttacker then
		meta.SetPhysicsAttacker = function() end
	end
end
