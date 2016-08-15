CLASS.Name = "Bonemesh"
CLASS.Description = "Disfigured and mangled, the Bonemesh is capable of tossing blood bombs.\nEach bomb is comprised of bones and flesh that damages humans while giving precious food to other zombies."
CLASS.Help = "> PRIMARY: Claws\n> SECONDARY: Toss blood bomb"

CLASS.Wave = 0
CLASS.Threshold = 0
CLASS.Unlocked = true
CLASS.Hidden = true
CLASS.Boss = true

CLASS.Health = 2500
CLASS.Speed = 190

CLASS.FearPerInstance = 1

CLASS.Points = 50

CLASS.SWEP = "weapon_zs_bonemesh"

CLASS.Model = Model("models/Zombie/Fast.mdl")

CLASS.VoicePitch = 0.8

CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound("npc/antlion_guard/foot_light1.wav", 65, math.Rand(115, 120))
	else
		pl:EmitSound("npc/antlion_guard/foot_light2.wav", 65, math.Rand(115, 120))
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
	if wep:IsValid() and wep.IsSwingAnim and wep:IsSwingAnim() then
		pl.CalcSeqOverride = 17
	elseif not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl.CalcSeqOverride = 5
	elseif velocity:Length2D() <= 0.5 then
		pl.CalcIdeal = ACT_IDLE
	else
		pl.CalcIdeal = ACT_RUN
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)

	local seq = pl:GetSequence()
	if seq == 5 then
		pl:SetPlaybackRate(1)
		return true
	end

	if seq == 1 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
	elseif seq == 17 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		pl:SetPlaybackRate(1)
		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

if SERVER then
	function CLASS:OnSpawned(pl)
		local status = pl:GiveStatus("overridemodel")
		if status and status:IsValid() then
			status:SetModel("models/Zombie/Poison.mdl")
		end

		pl:CreateAmbience("bonemeshambience")
	end
end

if not CLIENT then return end

CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar__human")
--CLASS.Icon = "zombiesurvival/killicons/bonemesh"
