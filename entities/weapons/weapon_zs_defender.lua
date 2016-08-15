AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Defender' Galil"
	SWEP.Description = "Semi automatic firing rifle capable of dealing a decent amount of damage without sacrificing stopping power or accuracy."
	SWEP.Slot = 3
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 45
	
	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1.5, -1.5, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.Primary.Damage = 42
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.4

SWEP.Primary.ClipSize = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.09
SWEP.ConeMin = 0.035

SWEP.WalkSpeed = 180

SWEP.IronSightsPos = Vector(-6.361, 22, 2.44)