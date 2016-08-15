AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Stalker' M4"
	SWEP.Description = "Using this gun will severely reduce the distance in which zombies can see your aura."
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.m4_Parent"
	SWEP.HUD3DPos = Vector(-0.85, -5.5, -2)
	SWEP.HUD3DAng = Angle(0, -8.5, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "smg"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound = Sound("Weapon_m4a1.Single")
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.11

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 0.125
SWEP.ConeMin = 0.045

SWEP.WalkSpeed = 183

SWEP.IronSightsPos = Vector(-7.9, 0, 0.039)
SWEP.IronSightsAng = Vector(3, -1.35, -4)

function SWEP:GetAuraRange()
	return 512
end
