ENT.Type = "anim"

function ENT:SetViewable(viewable)
	self:SetDTInt(0, viewable)
end

function ENT:GetViewable()
	return self:GetDTInt(0)
end

function ENT:SetHint(hint)
	self:SetNetworkedString(0, hint)
end

function ENT:GetHint()
	return self:GetNetworkedString(0)
end

function ENT:SetRange(range)
	self:SetDTFloat(0, range)
end

function ENT:GetRange()
	return self:GetDTFloat(0)
end
