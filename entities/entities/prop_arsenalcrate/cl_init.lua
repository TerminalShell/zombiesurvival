include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))
end

function ENT:SetCrateHealth(health)
	self:SetDTFloat(0, health)
end

local colFlash = Color(30, 255, 30)
function ENT:Draw()
	self:DrawModel()

	if not MySelf:IsValid() then return end

	local owner = self:GetObjectOwner()

	cam.Start3D2D(self:LocalToWorld(Vector(0, 0, self:OBBMaxs().z)), self:GetAngles(), 0.15)

		draw.RoundedBox(16, -92, -70, 184, 140, color_black_alpha90)

		draw.SimpleText("Arsenal Crate", "ArsenalCrate", 0, 0, COLOR_GRAY, TEXT_ALIGN_CENTER)

		if MySelf:Team() == TEAM_HUMAN and GAMEMODE:PlayerCanPurchase(MySelf) then
			colFlash.a = math.abs(math.sin(CurTime() * 5)) * 255
			draw.SimpleText("Purchase now!", "ArsenalCrate2", 0, -24, colFlash, TEXT_ALIGN_CENTER)
		end

		if owner:IsValid() and owner:IsPlayer() then
			draw.SimpleText("("..owner:ClippedName()..")", "ArsenalCrate2", 0, 32, owner == MySelf and COLOR_BLUE or COLOR_GRAY, TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()
end

function ENT:SetMessageID(id)
	self:SetDTInt(0, id)
	self.WorldHint:SetHint(self:GetMessage())
end