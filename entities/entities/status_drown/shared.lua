ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:SetDrown(drownamount)
	self:SetDTFloat(0, CurTime())
	self:SetDTFloat(1, drownamount)
end

function ENT:SetUnderwater(underwater)
	self:SetDrown(self:GetDrown())

	self:SetDTBool(0, underwater)
end

function ENT:GetUnderwater()
	return self:GetDTBool(0)
end
ENT.IsUnderwater = ENT.GetUnderwater

function ENT:GetDrown()
	if self:IsUnderwater() then
		return math.Clamp(self:GetDTFloat(1) + (CurTime() - self:GetDTFloat(0)) / 30, 0, 1)
	else
		return math.Clamp(self:GetDTFloat(1) - (CurTime() - self:GetDTFloat(0)) / 10, 0, 1)
	end
end

function ENT:IsDrowning()
	return self:GetDrown() == 1 and self:GetUnderwater()
end
