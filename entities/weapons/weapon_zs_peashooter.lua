AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Peashooter' Handgun"
	SWEP.Slot = 1
	SWEP.SlotPos = 0

	SWEP.ViewModelFOV = 60

	SWEP.ViewModelFlip = false
	
	SWEP.HUD3DBone = "v_weapon.p228_Slide"
	SWEP.HUD3DPos = Vector(-0.65, -0.25, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"

SWEP.WalkSpeed = 200

SWEP.Primary.Sound = Sound("Weapon_P228.Single")
SWEP.Primary.Damage = 16
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1

SWEP.Primary.ClipSize = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.08
SWEP.ConeMin = 0.015

SWEP.IronSightsPos = Vector(-5.961, 11, 2.64)