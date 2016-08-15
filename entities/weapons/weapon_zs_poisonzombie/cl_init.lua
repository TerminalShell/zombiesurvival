include("shared.lua")

SWEP.PrintName = "Poison Zombie"
SWEP.ViewModelFOV = 47
SWEP.DrawCrosshair = false

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right click to Throw Flesh.")

	draw.SimpleText("Left Click to Attack.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to Throw Flesh.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end