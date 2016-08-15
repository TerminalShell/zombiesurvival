include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))
end

function ENT:SetCrateHealth(health)
	self:SetDTFloat(0, health)
end

local NextUse = 0
local vOffset = Vector(16, 0, 0)
local vOffset2 = Vector(-15, 0, 8)
local aOffset = Angle(0, 90, 90)


local v2Offset = Vector(-16, 0, 0)
local a2Offset = Angle(0, -90, 90)

function ENT:Draw()
	self:DrawModel()

	if not MySelf:IsValid() then return end

	local owner = self:GetObjectOwner()
	local ang = self:LocalToWorldAngles(aOffset)
	local ang2 = self:LocalToWorldAngles(a2Offset)

	cam.Start3D2D(self:LocalToWorld(vOffset), ang, 0.15)

		draw.RoundedBox(16, -92, -50, 184, 100, color_black_alpha90)

		draw.SimpleText("Resupply Box", "ArsenalCrate", 0, 0, NextUse <= CurTime() and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if owner:IsValid() and owner:IsPlayer() then
			draw.SimpleText("("..owner:ClippedName()..")", "ArsenalCrate2", 0, 20, owner == MySelf and COLOR_BLUE or COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end

	cam.End3D2D()

	cam.Start3D2D(self:LocalToWorld(vOffset2), ang, 0.02)

		draw.SimpleText("The bullies can't get me here.", "ArsenalCrate", 0, 0, color_white, TEXT_ALIGN_CENTER)

	cam.End3D2D()
	
	
	
	--second box name thingy here OK BAAKAKA?
	
	
	cam.Start3D2D(self:LocalToWorld(v2Offset), ang2, 0.15)

		draw.RoundedBox(16, -92, -50, 184, 100, color_black_alpha90)

		draw.SimpleText("Resupply Box", "ArsenalCrate", 0, 0, NextUse <= CurTime() and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if owner:IsValid() and owner:IsPlayer() then
			draw.SimpleText("("..owner:ClippedName()..")", "ArsenalCrate2", 0, 20, owner == MySelf and COLOR_BLUE or COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end

	cam.End3D2D()
	
end

usermessage.Hook("NextResupplyUse", function(um)
	NextUse = um:ReadFloat()
end)

function ENT:SetMessageID(id)
	self:SetDTInt(0, id)
	self.WorldHint:SetHint(self:GetMessage())
end