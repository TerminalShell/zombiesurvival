include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.Seed = math.Rand(0, 10)

	self:DrawShadow(false)
end

local matRefract = Material("models/spawn_effect")
local matGlow = Material("models/props_combine/combine_fenceglow")
function ENT:DrawTranslucent()
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matGlow)

	render.SetBlend(0.1 + math.max(0, math.cos(CurTime())) ^ 4 * 0.1)
	self:DrawModel()

	if render.SupportsPixelShaders_2_0() then
		render.UpdateRefractTexture()

		matRefract:SetFloat("$refractamount", 0.0125 + math.sin(CurTime() * 2) ^ 2 * 0.0025)

		render.SetBlend(1)

		render.ModelMaterialOverride(matRefract)
		self:DrawModel()
	end

	render.SetBlend(1)
	render.ModelMaterialOverride(0)
	render.SuppressEngineLighting(false)
end