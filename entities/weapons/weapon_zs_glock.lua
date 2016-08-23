AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Crossfire' Glock 3"
	SWEP.Description = "High damage pistol that shoots 3 bullets at once. Effective at close range"
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(0.5, 0, -1)
	SWEP.HUD3DAng = Angle(100, -380, 0)
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.WalkSpeed = 200

SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.Damage = 19
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 0.3

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.14
SWEP.ConeMin = 0.07

SWEP.IronSightsPos = Vector(-5.781, 0, 2.95)
