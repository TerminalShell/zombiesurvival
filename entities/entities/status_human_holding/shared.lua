ENT.Type = "anim"
ENT.Base = "status__base"

util.PrecacheModel("models/weapons/v_hands.mdl")

function ENT:GetObject()
	return self:GetDTEntity(0)
end

function ENT:SetObject(object)
	self:SetDTEntity(0, object)
end

function ENT:SetIsHeavy(heavy)
	self:SetDTBool(0, heavy)
end

function ENT:GetIsHeavy()
	return self:GetDTBool(0)
end

function ENT:GetPullPos()
	local owner = self:GetOwner()
	if owner:IsValid() then
		return owner:EyePos() + owner:GetAimVector() * 48
	end

	return self:GetObjectPos()
end

function ENT:GetObjectPos()
	local object = self:GetObject()
	if object:IsValid() then
		return object:GetPos()
	end

	return self:GetPos()
end

function ENT:SetHingePos(pos)
	local object = self:GetObject()
	if object:IsValid() then
		self:SetDTVector(0, object:WorldToLocal(pos))
	end
end

function ENT:GetHingePos()
	local object = self:GetObject()
	if object:IsValid() then
		return object:LocalToWorld(self:GetDTVector(0))
	end

	return self:GetObjectPos()
end
