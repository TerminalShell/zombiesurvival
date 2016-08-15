-- This is a special class which is essentially just Fresh Dead made to be a bit stronger so people can put it in their maps.
-- It also has a climbing function although not as good as the Fast Zombie. Only so you don't have people exploiting high places.

CLASS.Name = "Classic Zombie"
CLASS.Base = "freshdead"

CLASS.Health = 125
CLASS.Speed = 200
CLASS.Points = 4

CLASS.SWEP = "weapon_zs_classiczombie"

CLASS.UsePlayerModel = true
CLASS.UsePreviousModel = false
CLASS.NoFallDamage = true

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end
end

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move and wep:Move(mv) then
		return true
	end
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		pl.CalcSeqOverride = 10
		return true
	end

	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:GetSequence() == 10 then
		local zvel = pl:GetVelocity().z
		if math.abs(zvel) < 8 then zvel = 0 end
		pl:SetPlaybackRate(math.Clamp(zvel / 60 * 0.25, -1, 1))
		return true
	end

	return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end
