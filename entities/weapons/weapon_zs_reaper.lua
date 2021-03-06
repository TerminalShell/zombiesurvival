AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Reaper' UMP"
	SWEP.Description = "A powerful SMG that does a lot of damage but slows you down quite a bit"
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.ump45_Release"
	SWEP.HUD3DPos = Vector(-1.8, -4, 3.5)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"

SWEP.Primary.Sound = Sound("Weapon_UMP45.Single")
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.13

SWEP.Primary.ClipSize = 28
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

SWEP.ConeMax = 0.08
SWEP.ConeMin = 0.045

SWEP.WalkSpeed = 190

SWEP.IronSightsPos = Vector(-8.641, 0, 3.4)
SWEP.IronSightsAng = Vector(0, 0, -2)
