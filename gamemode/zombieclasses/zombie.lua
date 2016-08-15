-- Has a climbing function although not as good as the Fast Zombie. Only so you don't have people exploiting high places.

CLASS.Name = "Zombie"
CLASS.Description = "The basic zombie is very durable and has powerful claws.\nIt's hard to keep down, especially if not shot in the head."
CLASS.Help = "> PRIMARY: Claws\n> SECONDARY: Scream\n> RELOAD: Moan\n> SPRINT: Feign death\n> ON FATAL HIT IN LEGS: Revive / Transform"

CLASS.Base = "freshdead"

CLASS.IsDefault = true

CLASS.Wave = 0
CLASS.Unlocked = true
CLASS.Hidden = false

CLASS.Order = 0

CLASS.Revives = true
CLASS.CanTaunt = true
CLASS.CanFeignDeath = true

CLASS.Health = 200
CLASS.Speed = 180
CLASS.Points = 5

CLASS.SWEP = "weapon_zs_zombie"

CLASS.Model = Model("models/player/zombie_classic.mdl")
CLASS.NoFallDamage = false

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end
end

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move and wep:Move(mv) then
		return true
	end
end

	CLASS.ReviveCallback = function(pl, attacker, dmginfo)
		if not pl.Revive and not dmginfo:GetInflictor().IsMelee and dmginfo:GetDamageType() ~= DMG_BLAST and dmginfo:GetDamageType() ~= DMG_BURN and (pl:LastHitGroup() == HITGROUP_LEFTLEG or pl:LastHitGroup() == HITGROUP_RIGHTLEG) then
			local classtable = math.random(3) == 3 and GAMEMODE.ZombieClasses["Zombie Legs"] or GAMEMODE.ZombieClasses["Zombie Torso"]
			if classtable then
				pl:RemoveStatus("overridemodel", false, true)
				local deathclass = pl.DeathClass or pl:GetZombieClass()
				pl:SetZombieClass(classtable.Index)
				pl:DoHulls(classtable.Index, TEAM_UNDEAD)
				pl.DeathClass = deathclass

				pl:EmitSound("physics/flesh/flesh_bloody_break.wav", 100, 75)
				local ent = ents.Create("prop_dynamic_override")
				if ent:IsValid() then
					ent:SetModel(Model("models/Zombie/Classic_legs.mdl"))
					ent:SetPos(pl:GetPos())
					ent:SetAngles(pl:GetAngles())
					ent:Spawn()
					ent:Fire("kill", "", 1.5)
				end
				pl:Gib()
				pl.Gibbed = nil

				timer.SimpleEx(0, pl.SecondWind, pl)
				return true
			end
		end

		return false
	end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		pl.CalcSeqOverride = 10
		return true
	end

	if pl:WaterLevel() >= 3 then
		pl.CalcIdeal = ACT_HL2MP_SWIM_PISTOL
		return true
	end

	if pl:Crouching() and pl:OnGround() then
		pl.CalcIdeal = ACT_HL2MP_WALK_CROUCH_KNIFE
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


if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/zombie"
end