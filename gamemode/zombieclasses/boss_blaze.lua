CLASS.Name = "Blaze Cadaver"
CLASS.Base = "boss_nightmare"
CLASS.Description = "Flaming and filled with rage, the Blaze Cadaver chases its prey outside of barricades with swift speed.\nIt wields the ability to fling fire and surge through the air."
CLASS.Help = "> PRIMARY: Throw Fire\n> SECONDARY: Surge"

CLASS.Health = 1500
CLASS.Speed = 190
CLASS.Points = 50

CLASS.SWEP = "weapon_zs_blaze"

CLASS.Model = Model("models/player/skeleton.mdl")
CLASS.NoFallDamage = true

CLASS.NoGibs = true
CLASS.PainSounds = {"npc/vort/vort_foot1.wav", "npc/vort/vort_foot2.wav", "npc/vort/vort_foot3.wav", "npc/vort/vort_foot4.wav"}
CLASS.DeathSounds = {"ambient/fire/gascan_ignite1.wav"}

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

local matSkin = Material("Models/Charple/Charple1_sheet")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end
