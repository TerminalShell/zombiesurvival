AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Sprayer' Mac 10"
	SWEP.Description = "An SMG that sacrifices accuracy for a large clip. Great for close quarters"
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 40

	SWEP.HUD3DBone = "v_weapon.mac10_bolt"
	SWEP.HUD3DPos = Vector(-1.3, -0.1, 1.5)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"

SWEP.Primary.Sound = Sound("Weapon_MAC10.Single")
SWEP.Primary.Damage = 18
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.075

SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 0.13
SWEP.ConeMin = 0.06

SWEP.WalkSpeed = 190

function SWEP:SecondaryAttack()
end

//This will do for now

/**Just kidding, it won't.
SWEP.IronSightsPos = Vector(-7.46, 0, 0.7)
SWEP.IronSightsAng = Vector(0.7, 0, -7)
**/

//Commenting out these coordinates due to the arms extending WAY too far
--SWEP.IronSightsPos = Vector(-7.46, 150, 0.7)
--SWEP.IronSightsAng = Vector(0.7, 0, -7)
