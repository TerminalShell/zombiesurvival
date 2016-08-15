include("shared.lua")

SWEP.PrintName = "Wraith"
SWEP.ViewModelFOV = 47

function SWEP:OnRemove()
	if MySelf == self.Owner then
		local vm = MySelf:GetViewModel()
		if vm and vm:IsValid() then
			vm:SetColor(color_white)
		end
	end

	if self.Owner and self.Owner:IsValid() then
		self.Owner:SetColor(color_white)
	end

	self.BaseClass.OnRemove(self)
end

function SWEP:Holster()
	if self.Owner == MySelf then
		local vm = MySelf:GetViewModel()
		if vm and vm:IsValid() then
			vm:SetColor(color_white)
		end
	end

	return self.BaseClass.Holster(self)
end

function SWEP:PreDrawViewModel(vm)
	render.SetBlend(self.Owner:CallZombieFunction("GetAlpha") or 1)
	render.SetColorModulation(0.3, 0.3, 0.3)
end

function SWEP:PostDrawViewModel(vm)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to Surge.")

	draw.SimpleText("Left Click to Attack.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to Surge.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Hold Shift to Sneak.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 1, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end