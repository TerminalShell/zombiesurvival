include("shared.lua")

SWEP.PrintName = "Bone Mesh"
SWEP.ViewModelFOV = 47
SWEP.DrawCrosshair = false

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to throw meatball")

	draw.SimpleText("Left Click to attack.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to throw meatball.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end