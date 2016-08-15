ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Model = Model("models/props_combine/combine_mine01.mdl")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMaterial("models/debug/debugwhite")
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(-8.29, -8.29, 0), Vector(8.29, 8.29, 10.13))

	self:RecalculateValidity()
end

function ENT:IsInsideProp()
	for _, ent in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if ent ~= self and ent:IsValid() and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetSolid() > 0 then return true end
	end

	return false
end

function ENT:RecalculateValidity()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local eyeangles = owner:EyeAngles()
	local shootpos = owner:GetShootPos()
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + owner:GetAimVector() * 48, mask = MASK_SOLID, filter = owner})

	if tr.HitWorld and not tr.HitSky and tr.HitNormal.z >= 0.75 then
		eyeangles = tr.HitNormal:Angle()
		eyeangles:RotateAroundAxis(eyeangles:Right(), 270)

		local valid = true
		if self:IsInsideProp() then
			valid = false
		else
			for _, ent in pairs(ents.FindInSphere(tr.HitPos, 64)) do
				if ent:IsValid() and ent:GetClass() == "prop_arsenalcrate" then
					valid = false
					break
				end
			end
		end

		self:SetValidPlacement(valid)
	else
		self:SetValidPlacement(false)
	end

	local pos, ang = tr.HitPos, eyeangles
	self:SetPos(pos)
	self:SetAngles(ang)

	return pos, ang
end

function ENT:GetValidPlacement()
	return self:GetDTBool(0)
end

function ENT:SetValidPlacement(onoff)
	self:SetDTBool(0, onoff)
end
