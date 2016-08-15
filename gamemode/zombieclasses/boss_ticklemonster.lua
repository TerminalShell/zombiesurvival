CLASS.Name = "The Tickle Monster"
CLASS.Description = "Said to be the monster that hides in your closet at night to drag you from your bed.\nThe Tickle Monster's almost elastic arms make it extremely hard to outrun and they also make it an ideal barricade destroyer."
CLASS.Help = "> PRIMARY: Elastic claws\n> SECONDARY: Moan"

CLASS.Wave = 0
CLASS.Threshold = 0
CLASS.Unlocked = true
CLASS.Hidden = true
CLASS.Boss = true

CLASS.Health = 2000
CLASS.Speed = 140

CLASS.FearPerInstance = 1

CLASS.CanTaunt = true

CLASS.Points = 50

CLASS.SWEP = "weapon_zs_ticklemonster"

CLASS.Model = Model("models/player/zombie_classic.mdl")

CLASS.VoicePitch = 0.8

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.ViewOffset = Vector(0, 0, 80)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 86)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 48)}

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

function CLASS:CalcMainActivity(pl, velocity)
	pl.CalcSeqOverride = pl:LookupSequence("zombie_run")

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 0.5 then
		pl:SetPlaybackRate(math.min(len2d / maxseqgroundspeed, 3))
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

if SERVER then
	function CLASS:OnSpawned(pl)
		local status = pl:GiveStatus("overridemodel")
		if status and status:IsValid() then
			status:SetModel("models/zombie/fast.mdl")
		end

		pl:CreateAmbience("ticklemonsterambience")
	end
end

if not CLIENT then return end

CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar__human")
CLASS.Icon = "zombiesurvival/killicons/tickle"

local vecSpineOffset = Vector(10, 0, 0)
local SpineBones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine3"}
function CLASS:BuildBonePositions(pl)
	for _, bone in pairs(SpineBones) do
		local spineid = pl:LookupBone(bone)
		if spineid and spineid > 0 then
			pl:ManipulateBonePosition(spineid, vecSpineOffset)
		end
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetSwingEndTime then
		local desiredscale
		if wep:GetSwingEndTime() > 0 then
			desiredscale = 2 + (1 - math.Clamp((wep:GetSwingEndTime() - CurTime()) / wep.MeleeDelay, 0, 1)) * 10
		else
			desiredscale = 2
		end
		pl.m_TMArmLength = math.Approach(pl.m_TMArmLength or 2, desiredscale, FrameTime() * 10)

		local larmid = pl:LookupBone("ValveBiped.Bip01_L_Forearm")
		if larmid and larmid > 0 then
			pl:ManipulateBoneScale(larmid, Vector(pl.m_TMArmLength, 2, 2))
		end
		local rarmid = pl:LookupBone("ValveBiped.Bip01_R_Forearm")
		if rarmid and rarmid > 0 then
			pl:ManipulateBoneScale(rarmid, Vector(pl.m_TMArmLength, 2, 2))
		end
	end
end
