AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Akbar' Assault Rifle"
	SWEP.Description = "Fully Automatic Assault Rifle with moderate damage and high fire rate"
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 40

	SWEP.HUD3DBone = "v_weapon.AK47_Parent"
	SWEP.HUD3DPos = Vector(-0.87, -6.7, -8)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.010
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.ReloadSound = Sound("Weapon_AK47.Clipout")
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Damage = 19
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.12

SWEP.Primary.ClipSize = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.125
SWEP.ConeMin = 0.050

SWEP.WalkSpeed = 180

SWEP.IronSightsPos = Vector(-6.6, 20, 1.1)
SWEP.IronSightsAng = Vector(2.55, 0, 0)

/*function SWEP:SecondaryAttack()
end*/
