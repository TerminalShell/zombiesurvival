include("shared.lua")

SWEP.PrintName = "Junk Pack"
SWEP.Description = "It's simply a pack of wooden junk kept together with some duct tape.\nVery useful for making barricades when no materials are around.\nNeeds something like a hammer and nails to keep the things in place."
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false

SWEP.Slot = 4
SWEP.SlotPos = 0

function SWEP:DrawHUD()
	if GetGlobalBool("classicmode") then return end

	surface.SetFont("ZSHUDFontSmall")
	local junk = self:GetPrimaryAmmoCount()
	local nTEXW, nTEXH = surface.GetTextSize("Left click to drop junk.")

	if 0 < junk then
		draw.SimpleText("Junk: "..junk, "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Junk: 0", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_RED, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Left click to drop junk.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
	
	--if LocalPlayer() == self:GetOwner() then
	--	local eyes = LocalPlayer():EyePos()
	--	local props = {}
	--	for _, ent in pairs( ents.FindByClass( "prop_physics*" )) do
	--		if !ent:IsNailed() and (ent:GetMaxBarricadeHealth() == 0 or ent:GetBarricadeHealth() > 0) and --TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
	--			table.insert( props, ent )
	--		end
	--	end
	--	halo.Add( props, Color( 255, 255, 0 ), 2, 2, 1, true, true )
	--end
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
