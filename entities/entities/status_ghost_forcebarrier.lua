AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_ghost_base"

ENT.GhostModel = Model("models/props_lab/lab_flourescentlight002b.mdl")
ENT.GhostRotation = Angle(0, 0, 0)
ENT.GhostEntity = "prop_forcebarrier"
ENT.GhostWeapon = "weapon_zs_forcebarrier"
ENT.GhostDistance = 80
ENT.GhostHitNormalOffset = 2.9
ENT.GhostRotateFunction = "Forward"

function ENT:RecalculateValidity()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if SERVER or MySelf == owner then
		self:SetRotation(math.NormalizeAngle(owner:GetInfoNum("_zs_ghostrotation", 0)))
	end

	local rotation = self.GhostNoRotation and 0 or self:GetRotation()
	local eyeangles = owner:EyeAngles()
	local shootpos = owner:GetShootPos()
	local entity
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + owner:GetAimVector() * 48, mask = MASK_SOLID, filter = owner})

	if tr.HitWorld and not tr.HitSky and tr.HitNormal.z >= 0.75 or tr.HitNonWorld and self.GhostPlaceOnEntities then
		if self.GhostHitNormalOffset then
			tr.HitPos = tr.HitPos + tr.HitNormal * self.GhostHitNormalOffset
		end

		local rot = self.GhostRotation
		eyeangles = tr.HitNormal:Angle()
		eyeangles:RotateAroundAxis(eyeangles:Right(), rot.pitch)
		eyeangles:RotateAroundAxis(eyeangles:Up(), rot.yaw)
		eyeangles:RotateAroundAxis(eyeangles:Forward(), rot.roll)

		local valid = true
		if self.GhostLimitedNormal and tr.HitNormal.z < self.GhostLimitedNormal or self:IsInsideProp() then
			valid = false
		elseif self.GhostDistance then
			for _, ent in pairs(ents.FindInSphere(tr.HitPos, self.GhostDistance)) do
				if ent:IsValid() and ent:GetClass() == self.GhostEntity then
					valid = false
					break
				end
			end
		end

		if valid and self.GhostFlatGround and math.abs(tr.HitNormal.z) < 0.75 then
			local start = tr.HitPos + tr.HitNormal
			if not util.TraceLine({start = start, endpos = start + Vector(0, 0, -128), mask = MASK_SOLID_BRUSHONLY}).Hit then
				valid = false
			end
		end

		if valid then
			valid = self:CustomValidate(tr)
		end

		entity = tr.Entity

		self:SetValidPlacement(valid)
	else
		self:SetValidPlacement(false)
	end

	if tr.HitNormal.z >= 0.75 then
		eyeangles:RotateAroundAxis(eyeangles[self.GhostRotateFunction](eyeangles), owner:GetAngles().yaw + rotation)
	else
		eyeangles:RotateAroundAxis(eyeangles[self.GhostRotateFunction](eyeangles), rotation)
	end

	local pos, ang = tr.HitPos, eyeangles
	self:SetPos(pos)
	self:SetAngles(ang)

	return pos, ang, entity
end