include("shared.lua")

SWEP.PrintName = "Electrohammer"

SWEP.ViewModelFOV = 75

function SWEP:DrawHUD()
	if GetGlobalBool("classicmode") then return end

	surface.SetFont("ZSHUDFontSmall")
	local nails = self:GetPrimaryAmmoCount()
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to hammer in a nail.")

	if 0 < nails then
		draw.SimpleText("Nails: "..nails, "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Nails: 0", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_RED, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Right click to hammer in a nail.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
	
	--if LocalPlayer() == self:GetOwner() then
		--local eyes = LocalPlayer():EyePos()
		--local props = {}
		--for _, ent in pairs( ents.FindByClass( "prop_physics*" )) do
		--	if !ent:IsNailed() and (ent:GetMaxBarricadeHealth() == 0 or ent:GetBarricadeHealth() > 0) and --TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
		--		table.insert( props, ent )
		--	end
		--end
		--halo.Add( props, Color( 255, 255, 0 ), 2, 2, 1, true, true )
	--end
end
