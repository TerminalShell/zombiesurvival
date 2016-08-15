include("shared.lua")
include("animations.lua")

ENT.ColorModulation = Color(0.15, 0.8, 1)

function ENT:OnRemove()
	if self.WElements then
		self:RemoveModels()
	end
end

function ENT:Draw()
	if self.WElements then
		self:Anim_Draw()
	end
end