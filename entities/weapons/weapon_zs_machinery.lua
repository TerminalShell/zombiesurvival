AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Machinery' SMG"
	SWEP.Description = "Fires multiple silenced rounds at once keeping your presence hidden from farther ranges."
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false
	
	SWEP.HUD3DBone = "v_weapon.TMP_Parent"
	SWEP.HUD3DPos = Vector(-1.2, -4, 1)
	SWEP.HUD3DAng = Angle(10, 0, 0)
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "smg"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"

SWEP.Primary.Sound = Sound("Weapon_tmp.Single")
SWEP.Primary.Damage = 10
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.17

SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.11
SWEP.ConeMin = 0.06

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.WalkSpeed = 190

SWEP.IronSightsPos = Vector(-6.861, 0, 2.549)

SWEP.Primary.DefaultNumShots = SWEP.Primary.NumShots
SWEP.Primary.DefaultDelay = SWEP.Primary.Delay
SWEP.Primary.IronsightsNumShots = SWEP.Primary.NumShots
SWEP.Primary.IronsightsDelay = SWEP.Primary.Delay * 1.6666

function SWEP:CanPrimaryAttack()
	if self:GetIronsights() and self:Clip1() == 1 then
		self:SetIronsights(false)
	end

	return self.BaseClass.CanPrimaryAttack(self)
end


function SWEP:TakeAmmo()
	if self:GetIronsights() then
		self:TakePrimaryAmmo(1)
	else
		self.BaseClass.TakeAmmo(self)
	end
end

function SWEP:GetAuraRange()
	return 512
end