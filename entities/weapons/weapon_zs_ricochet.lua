AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Ricochet' Magnum"
	SWEP.Description = "This gun's bullets will bounce off of walls which will then deal extra damage."
	SWEP.Slot = 1
	SWEP.SlotPos = 0

	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(1, -1, -2.5)
	SWEP.HUD3DScale = 0.015

	SWEP.ViewModelFlip = false
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.WalkSpeed = 195

SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Delay = 1
SWEP.Primary.Damage = 62
SWEP.Primary.NumShots = 1

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.075
SWEP.ConeMin = 0.025

SWEP.IronSightsPos = Vector(-4.64, 11, 0.639)
SWEP.IronSightsAng = Vector(0, 0, 0)

local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
	attacker.RicochetBullet = true
	attacker:FireBullets({Num = 1, Src = hitpos, Dir = 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, Spread = Vector(0, 0, 0), Tracer = 1, TracerName = "rico_trace", Force = damage * 0.7, Damage = damage, Callback = GenericBulletCallback})
	attacker.RicochetBullet = nil
end
function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and tr.HitWorld and not tr.HitSky then
		timer.SimpleEx(0, DoRicochet, attacker, tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * 1.5)
	end

	GenericBulletCallback(attacker, tr, dmginfo)
end
