AddCSLuaFile()

SWEP.Base = "weapon_zs_zombiebase"

if CLIENT then
	SWEP.PrintName = "Zombie Torso"
end

SWEP.MeleeReach = 40
SWEP.MeleeDamage = 15

SWEP.DelayWhenDeployed = true

function SWEP:Reload()
	self:SecondaryAttack()
end

function SWEP:StartMoaning()
end

function SWEP:StopMoaning()
end

function SWEP:IsMoaning()
	return false
end
