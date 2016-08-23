AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Owens' Handgun"
	SWEP.Description = "A Tier 1 handgun that excels at close range by firing 2 deadly shots at once"
	SWEP.Slot = 1
	SWEP.SlotPos = 0

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1, 0.25, -3)
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.WalkSpeed = 200

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 12
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.2

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.08
SWEP.ConeMin = 0.04

SWEP.IronSightsPos = Vector(-6.151, 11, 2.97)
SWEP.IronSightsAng = Vector(0.15, -1.101, 0)
