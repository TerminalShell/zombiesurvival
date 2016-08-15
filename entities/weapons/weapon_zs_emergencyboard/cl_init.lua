include("shared.lua")

SWEP.PrintName = "Emergency Board"
SWEP.Description = "An emergency board pack with the chance of one singular board. The moment is intense and it's a risk. But, you don't mind that!"
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false

SWEP.Slot = 4
SWEP.SlotPos = 0

function SWEP:DrawHUD()
	if GetGlobalBool("classicmode") then return end

	surface.SetFont("ZSHUDFontSmall")
	local boards = self:GetPrimaryAmmoCount()
	local nTEXW, nTEXH = surface.GetTextSize("Left click to drop board.")

	if 0 < boards then
		draw.SimpleText("Boards: "..boards, "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Boards: 0", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_RED, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Left Click to drop board.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end

function SWEP:Deploy()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

function SWEP:DrawWorldModel()
	local owner = self.Owner
	if owner:IsValid() and self:GetReplicatedAmmo() > 0 then
		local id = owner:LookupAttachment("anim_attachment_RH")
		if id and id > 0 then
			local attch = owner:GetAttachment(id)
			if attch then
				cam.Start3D(EyePos() + (owner:GetPos() - attch.Pos + Vector(0, 0, 24)), EyeAngles())
					self:DrawModel()
				cam.End3D()
			end
		end
	end
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:Initialize()
	self:SetDeploySpeed(1.1)
end

function SWEP:GetViewModelPosition(pos, ang)
	if self:GetPrimaryAmmoCount() <= 0 then
		return pos + ang:Forward() * -256, ang
	end

	return pos, ang
end

function SWEP:DrawWeaponSelection(...)
	return self:BaseDrawWeaponSelection(...)
end
