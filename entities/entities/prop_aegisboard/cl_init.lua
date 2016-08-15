include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetBoardHealth(health)
	self:SetDTFloat(0, health)
end

//local matOutlineWhite = Material("white_outline")
//local ScaleNormal = 1
//local ScaleOutline = 1.09
function ENT:Draw()
	if MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN then
		//render.SuppressEngineLighting(true)
		//render.SetAmbientLight(1, 1, 1)

		//local percentage = self:GetBoardHealth() / self:GetMaxBoardHealth()
		//render.SetColorModulation(1 - percentage, percentage, 0)

		//self:SetModelScale(ScaleOutline, 0)
		//render.ModelMaterialOverride(matOutlineWhite)
		//self:DrawModel()

		//render.ModelMaterialOverride()
		//self:SetModelScale(ScaleNormal, 0)

		//render.SuppressEngineLighting(false)
		//render.SetColorModulation(1, 1, 1)

		self:DrawModel()

		local owner = self:GetObjectOwner()
		if owner:IsValid() and owner:IsPlayer() and owner:Team() ~= TEAM_UNDEAD then
			local name = owner:Name()

			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Up(), 270)
			ang:RotateAroundAxis(ang:Right(), 270)
			ang:RotateAroundAxis(ang:Forward(), 270)

			local vPos = self:GetPos()
			local vOffset = self:GetForward() * self:OBBMaxs().x

			cam.Start3D2D(vPos + vOffset, ang, 0.1)
				draw.SimpleText(name, "ZS3D2DFont", 0, 0, COLOR_WHITE, TEXT_ALIGN_CENTER)
			cam.End3D2D()

			ang:RotateAroundAxis(ang:Right(), 180)

			cam.Start3D2D(vPos - vOffset, ang, 0.1)
				draw.SimpleText(name, "ZS3D2DFont", 0, 0, COLOR_WHITE, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	else
		self:DrawModel()
	end
end
