CLASS.Name = "Wraith"
CLASS.Description = "A zombie or an apparition?\nNot much is known about it besides the fact that it uses its\nunique stealth ability and sharp claws to cut things to ribbons."
CLASS.Help = "> PRIMARY: Claws\n> SECONDARY: Surge\n> INVISIBILITY BASED ON MOVEMENT AND VIEW DISTANCE"

CLASS.Wave = 1 / 2
CLASS.Health = 150
CLASS.SWEP = "weapon_zs_wraith"
CLASS.Model = Model("models/wraith_zsv1.mdl")
CLASS.Speed = 185

CLASS.Points = 4
CLASS.Infliction = 0.5 -- We auto-unlock this class if 50% of humans are dead regardless of what wave it is.

CLASS.VoicePitch = 0.65

CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
CLASS.DeathSounds = {Sound("zombiesurvival/wraithdeath1.wav"), Sound("zombiesurvival/wraithdeath2.wav"), Sound("zombiesurvival/wraithdeath3.wav"), Sound("zombiesurvival/wraithdeath4.wav")}

CLASS.NoShadow = true

function CLASS:Move(pl, mv)
	if pl:KeyDown(IN_SPEED) then
		mv:SetMaxSpeed(60)
		mv:SetMaxClientSpeed(60)
	end
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsAttacking and wep:IsAttacking() then
		pl.CalcSeqOverride = 10
	elseif velocity:Length2D() > 0.5 then
		pl.CalcSeqOverride = 3
	else
		pl.CalcSeqOverride = 1
	end

	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

-- The Wraith model doesn't have hitboxes.
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)

	local seq = pl:GetSequence()
	if seq == 10 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	if not wep.IsAttacking then wep = NULL end

	if wep:IsValid() and wep:IsAttacking() then
		return 0.7
	elseif MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD then
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0.5, 35, 180) / 255
	else
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0.5, 1, 180) / 255
	end
end

function CLASS:PrePlayerDraw(pl)
	pl:RemoveAllDecals()

	render.SetBlend(self:GetAlpha(pl))
	render.SetColorModulation(0.3, 0.3, 0.3)
end

function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end

function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	if SERVER then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(pl:GetForward())
			effectdata:SetEntity(pl)
		util.Effect("wraithdeath", effectdata, nil, true)
	end

	return true
end

if CLIENT then
	CLASS.HealthBar = surface.GetTextureID("zombiesurvival/healthbar_wraith")
	CLASS.Icon = "zombiesurvival/killicons/wraithv2"
end
