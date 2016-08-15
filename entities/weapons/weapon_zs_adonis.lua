AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Adonis' Pulse Rifle"
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.HUD3DBone = "Vent"
	SWEP.HUD3DPos = Vector(1, 0, 0)	
	SWEP.HUD3DScale = 0.018

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_IRifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"

SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Airboat.FireGunHeavy")
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.125
SWEP.ConeMin = 0.045

SWEP.WalkSpeed = 183

SWEP.IronSightsPos = Vector(-5.2, 0, 1.2)

SWEP.TracerName = "AR2Tracer"

--function SWEP.BulletCallback(attacker, tr, dmginfo)
--	local ent = tr.Entity
--	if ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_UNDEAD then
--		ent:AddLegDamage(2)
--	end
--
--	GenericBulletCallback(attacker, tr, dmginfo)
--end
