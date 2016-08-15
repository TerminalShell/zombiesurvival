AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Zombie Drill' Desert Eagle"
	SWEP.Description = "This handgun uses high-powered rounds that have more knockback than others." --SWEP.Description = "This high-powered handgun has the ability to pierce through multiple zombies. The bullet's power decreases by half which each zombie it hits."
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false
	
	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(180, 180, 180)

	SWEP.ViewModelFOV = 55
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage = 47
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.3
SWEP.Primary.KnockbackScale = 7

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.WalkSpeed = 195

SWEP.ConeMax = 0.1
SWEP.ConeMin = 0.04

SWEP.IronSightsPos = Vector(-6.361, 0, 2.119)