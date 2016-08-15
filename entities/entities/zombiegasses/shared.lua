ENT.Type = "anim"

function ENT:SetRadius(fRadius)
	self:SetDTFloat(0, fRadius)
end

function ENT:GetRadius()
	return self:GetDTFloat(0)
end
