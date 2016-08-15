CLASS.Name = "Chem Zombie"
CLASS.Description = "The Chem Zombie body is comprised of volatile, toxic chemicals.\nIt has no other means of attack besides being killed in hopes of blowing up next to any nearby humans."
CLASS.Help = "> ON DEATH: Poison Bomb"
CLASS.Wave = 7 / 8
CLASS.Health = 100
CLASS.SWEP = "weapon_zs_chemzombie"
CLASS.Model = Model("models/Zombie/Poison.mdl")
CLASS.Speed = 160

CLASS.Unlocked = false
CLASS.Hidden = false

CLASS.Points = 3

CLASS.PainSounds = {Sound("npc/metropolice/knockout2.wav"), Sound("npc/metropolice/pain1.wav"), Sound("npc/metropolice/pain2.wav"), Sound("npc/metropolice/pain3.wav"), Sound("npc/metropolice/pain4.wav")}
CLASS.DeathSounds = {Sound("ambient/fire/gascan_ignite1.wav")}
CLASS.VoicePitch = 0.65

CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

function CLASS:CanUse(pl)
	return false
end

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2D() <= 0.5 then
		pl.CalcIdeal = ACT_IDLE
	else
		pl.CalcSeqOverride = 2
	end

	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math.random(1,3) < 3 then
		pl:EmitSound("NPC_PoisonZombie.FootstepRight")
	else
		pl:EmitSound("NPC_PoisonZombie.FootstepLeft")
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 365 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 300
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 450
	end

	return 150
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)
end

if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("chemzombieambience")
	end

	hook.Add("InitPostEntity", "MakeChemDummy", function()
		DUMMY_CHEMZOMBIE = ents.Create("dummy_chemzombie")
		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:Spawn()
		end
	end)

	local function ChemBomb(pl, pos)
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("chemzombieexplode", effectdata, true)

		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:SetPos(pos)
		end
		util.PoisonBlastDamage(DUMMY_CHEMZOMBIE, pl, pos, 128, 85, true)

		pl:CheckRedeem()
	end

	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		if attacker ~= pl and not suicide then
			pl:Gib(dmginfo)
			timer.SimpleEx(0, ChemBomb, pl, pl:LocalToWorld(pl:OBBCenter()))

			return true
		end
	end
end

if not CLIENT then return end

CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar_chemzombie")
CLASS.Icon = "zombiesurvival/killicons/chemzombie"
