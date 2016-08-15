include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(1.03, 0)
end

local matDamage = Material("Models/props_debris/concretefloor013a")
function ENT:Draw()
	local sat = 1 - math.abs(math.sin(CurTime() * 3)) * 0.6

	render.ModelMaterialOverride(matDamage)
	render.SetBlend(0.35)
	render.SetColorModulation(1, sat, sat)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	render.ModelMaterialOverride(0)
end
