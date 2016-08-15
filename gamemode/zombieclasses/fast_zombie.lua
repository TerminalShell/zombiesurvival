CLASS.Name = "Fast Zombie"
CLASS.Description = "This boney cadaver is much faster than other zombies.\nThey aren't much of a threat by themselves but can reach nearly any area by climbing with their razor sharp claws\nThey also have no problem hunting down weak or hurt humans."
CLASS.Help = "> PRIMARY: Claws\n> SECONDARY: Lunge / Climb (next to wall)\n> RELOAD: Scream"

CLASS.Model = Model("models/Zombie/Fast.mdl")

CLASS.Wave = 1 / 2
CLASS.Revives = true
CLASS.Infliction = 0.5 -- We auto-unlock this class if 50% of humans are dead regardless of what wave it is.

CLASS.Health = 100
CLASS.Speed = 200
CLASS.SWEP = "weapon_zs_fastzombie"

CLASS.Points = 4

CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

CLASS.PainSounds = {"NPC_FastZombie.Pain"}
CLASS.DeathSounds = {"NPC_FastZombie.Die"}

CLASS.VoicePitch = 0.75

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound("NPC_FastZombie.GallopLeft")
	else
		pl:EmitSound("NPC_FastZombie.GallopRight")
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 450 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 400
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 550
	end

	return 250
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing then return end

	if wep:GetClimbing() then
		pl.CalcSeqOverride = 10
		return true
	elseif wep:GetSwinging() then
		pl.CalcSeqOverride = 8
		return true
	elseif wep:GetPounceTime() > 0 then
		pl.CalcSeqOverride = 4
		return true
	end
		
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl.CalcSeqOverride = 5
	elseif velocity:Length2D() <= 0.5 then
		if wep:IsRoaring() then
			pl.CalcSeqOverride = 16
		else
			pl.CalcIdeal = ACT_IDLE
		end
	else
		pl.CalcIdeal = ACT_RUN
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)

	local seq = pl:GetSequence()
	if seq == 5 or seq == 8 then
		pl:SetPlaybackRate(1)
		return true
	end
	
	if seq == 10 then
		local zvel = pl:GetVelocity().z
		if math.abs(zvel) < 8 then zvel = 0 end
		pl:SetPlaybackRate(math.Clamp(zvel / 160, -1, 1))
		return true
	end

	if seq == 4 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		pl:SetPlaybackRate(0.25)

		return true
	elseif seq == 16 or seq == 1 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

if SERVER then
	CLASS.ReviveCallback = function(pl, attacker, dmginfo)
		--Had to replace the hitgroup legs to head and chest, it just doens't work well on legs.
		if not pl.Revive and not dmginfo:GetInflictor().IsMelee and dmginfo:GetDamageType() ~= DMG_BLAST and dmginfo:GetDamageType() ~= DMG_BURN and (pl:LastHitGroup() ~= HITGROUP_HEAD or pl:LastHitGroup() ~= HITGROUP_CHEST) then
			local classtable = math.random(3) == 3 and GAMEMODE.ZombieClasses["Fast Zombie Legs"]
			if classtable then
				pl:RemoveStatus("overridemodel", false, true)
				local deathclass = pl.DeathClass or pl:GetZombieClass()
				pl:SetZombieClass(classtable.Index)
				pl:DoHulls(classtable.Index, TEAM_UNDEAD)
				pl.DeathClass = deathclass

				pl:EmitSound("physics/flesh/flesh_bloody_break.wav", 100, 75)
				local ent = ents.Create("prop_dynamic_override")
				if ent:IsValid() then
					ent:SetModel(Model("models/Gibs/Fast_Zombie_Legs.mdl"))
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
end

if not CLIENT then return end

CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar_fastzombie")
CLASS.Icon = "zombiesurvival/killicons/fastzombie"

function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.m_ViewAngles and wep:IsPouncing() then
		local maxdiff = FrameTime() * 20
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles

		cmd:SetViewAngles(viewangles)
	end
end
