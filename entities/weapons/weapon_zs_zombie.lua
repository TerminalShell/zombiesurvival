AddCSLuaFile()

SWEP.Base = "weapon_zs_zombiebase"

SWEP.MeleeDamage = 30

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
