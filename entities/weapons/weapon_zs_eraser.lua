AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Eraser' Tactical Pistol"
	SWEP.Description = "Damage increases as remaining bullets decrease. The last shot is worth double damage."
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.FIVESEVEN_SLIDE"
	SWEP.HUD3DPos = Vector(-0.80, -1, 0)
	SWEP.HUD3DAng = Angle(180, 180, 90)

end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Primary.Sound = Sound("weapons/ar2/npc_ar2_altfire.wav")
SWEP.Primary.Damage = 18
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.06
SWEP.ConeMin = 0.03

SWEP.WalkSpeed = 200

SWEP.IronSightsPos = Vector(-5.961, 0, 2.839)

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 80, 70 + (1 - (self:Clip1() / self.Primary.ClipSize)) * 90)
end

function SWEP:ShootBullets(dmg, numbul, cone)
	dmg = dmg + dmg * (1 - self:Clip1() / self.Primary.ClipSize)
	self.BaseClass.ShootBullets(self, dmg, numbul, cone)
end
