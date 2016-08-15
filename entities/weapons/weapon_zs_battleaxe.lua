AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Battleaxe' Handgun"
	SWEP.Slot = 1
	SWEP.SlotPos = 0

	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.HUD3DPos = Vector(-0.85, -0.25, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DBone = "v_weapon.USP_Slide"
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"

SWEP.Primary.Sound = Sound("Weapon_USP.Single")
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

SWEP.WalkSpeed = 200

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.IronSightsPos = Vector(-5.913, 11, 2.70)

SWEP.ConeMax = 0.07
SWEP.ConeMin = 0.02
