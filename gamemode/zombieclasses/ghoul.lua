CLASS.Name = "Ghoul"
CLASS.Description = "This zombie has highly toxic flesh.\nIt's slightly weaker than other zombies but makes up for it with its poison attacks.\nIts claws can debilitate a human for a short time and it will eject poison through its wounds if hit with enough damage."
CLASS.Help = "> PRIMARY: Poison claws\n> SECONDARY: Flesh toss\n> SPRINT: Feign death\n> RELOAD: Scream\n> ON HIT HUMAN: Slow\n> ON HIT BY HUMAN: Poison ejection"

CLASS.Wave = 0
CLASS.Unlocked = true

CLASS.Health = 125
CLASS.Speed = 140

CLASS.Points = 3

CLASS.CanTaunt = true

CLASS.SWEP = "weapon_zs_ghoul"

CLASS.Model = Model("models/player/zombie_classic.mdl")

CLASS.UsePreviousModel = true

CLASS.VoicePitch = 0.7

CLASS.CanFeignDeath = true

function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_warn"..math.random(1, 2)..".wav", 75, math.Rand(137, 143))

	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_die2.wav", 75, math.Rand(122, 128))

	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		if CurTime() * 2 % 2 < 0.3 then
			pl:EmitSound("Zombie.ScuffLeft")
		else
			pl:EmitSound("Zombie.FootstepLeft")
		end
	else
		if CurTime() * 2 % 2 < 0.3 then
			pl:EmitSound("Zombie.ScuffRight")
		else
			pl:EmitSound("Zombie.FootstepRight")
		end
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750
	end

	return 450
end

function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

function CLASS:CalcMainActivity(pl, velocity)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetDirection() == DIR_BACK then
			pl.CalcSeqOverride = pl:LookupSequence("zombie_slump_rise_02_fast")
		else
			pl.CalcIdeal = ACT_HL2MP_ZOMBIE_SLUMP_RISE
		end
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

	if velocity:Length2D() <= 0.5 then
		pl.CalcIdeal = ACT_HL2MP_IDLE_ZOMBIE
	else
		pl.CalcIdeal = ACT_HL2MP_WALK_ZOMBIE_01 - 1 + math.ceil((CurTime() / 4 + pl:EntIndex()) % 3)
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetState() == 1 then
			pl:SetCycle(1 - math.max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		else
			pl:SetCycle(math.max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		end
		pl:SetPlaybackRate(0)
		return true
	end

	local len2d = velocity:Length2D()
	if len2d > 0.5 then
		pl:SetPlaybackRate(math.min(len2d / maxseqgroundspeed * 0.666, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
		return ACT_INVALID
	end
end

function CLASS:DoesntGiveFear(pl)
	return IsValid(pl.FeignDeath)
end

local function CreateFlesh(pl, damage, damagepos, damagedir)
	damage = math.min(damage, 100)

	pl:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 74, 125 - damage * 0.50)

	if SERVER then
		local damagepos = pl:LocalToWorld(damagepos)

		for i=1, math.max(1, math.floor(damage / 15)) do
			local ent = ents.Create("projectile_poisonflesh")
			if ent:IsValid() then
				local heading = (damagedir + VectorRand() * 0.3):GetNormalized()
				ent:SetPos(damagepos + heading)
				ent:SetOwner(pl)
				ent:Spawn()
				ent:SetTeamID(TEAM_UNDEAD)
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocityInstantaneous(math.min(350, 16 + damage ^ math.Rand(1.15, 1.25)) * heading)
				end
			end
		end
	end
end

function CLASS:ProcessDamage(pl, dmginfo)
	local attacker, damage = dmginfo:GetAttacker(), dmginfo:GetDamage()
	if attacker ~= pl and damage >= 5 and damage < pl:Health() and CurTime() >= (pl.m_NextGhoulEmit or 0) then
		pl.m_NextGhoulEmit = CurTime() + 0.25

		timer.SimpleEx(0, CreateFlesh, pl, damage, pl:WorldToLocal(dmginfo:GetDamagePosition()), dmginfo:GetDamageForce():GetNormalized() * -1)
	end
end

function CLASS:ShouldDrawLocalPlayer(pl)
	return IsValid(pl.FeignDeath)
end

if SERVER then
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end

	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local damage = dmginfo:GetDamage()
		if damage >= 5 then
			timer.SimpleEx(0, CreateFlesh, pl, math.max(30, damage * 2), pl:WorldToLocal(dmginfo:GetDamagePosition()), dmginfo:GetDamageForce():GetNormalized() * -1)
		end
	end

	function CLASS:OnSpawned(pl)
		local status = pl:GiveStatus("overridemodel")
		if status and status:IsValid() then
			status:SetModel("models/player/corpse1.mdl")
		end
	end
end

if not CLIENT then return end

CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar__human")
CLASS.Icon = "zombiesurvival/killicons/ghoul"