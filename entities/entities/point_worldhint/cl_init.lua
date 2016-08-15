include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:Draw()
end

function ENT:DrawHint()
	if self:GetViewable() == 0 or self:GetViewable() == MySelf:Team() then
		local hint = self:GetHint()
		if hint then
			local range = self:GetRange()
			local pos = self:GetPos()
			if range == 0 then
				DrawWorldHint(hint, pos, nil, 0.1)
			else
				local dist = EyePos():Distance(pos)
				if dist <= range then
					local fadeoff = range * 0.75
					if dist >= fadeoff then
						DrawWorldHint(hint, pos, (1 - dist / fadeoff) * 0.5, 0.1)
					else
						DrawWorldHint(hint, pos, nil, 0.1)
					end
				end
			end
		end
	end
end
