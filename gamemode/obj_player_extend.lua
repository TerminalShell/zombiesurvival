local meta = FindMetaTable("Player")
if not meta then return end

meta.GetTeamID = meta.Team

function meta:Dismember(dismembermenttype)
	local effectdata = EffectData()
		effectdata:SetOrigin(self:EyePos())
		effectdata:SetEntity(self)
		effectdata:SetScale(dismembermenttype)
	util.Effect("dismemberment", effectdata, true, true)
end

function meta:GetAuraRange()
	local wep = self:GetActiveWeapon()
	return wep:IsValid() and wep.GetAuraRange and wep:GetAuraRange() or 2048
end

function meta:GetCoupledHeadcrab()
	local status = self.m_Couple
	return status and status:IsValid() and status:GetPartner() or NULL
end

function meta:GetPoisonDamage()
	return self.PoisonRecovery and self.PoisonRecovery:IsValid() and self.PoisonRecovery:GetDamage() or 0
end

function meta:CallWeaponFunction(funcname, ...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[funcname] then
		return wep[funcname](wep, self, ...)
	end
end

function meta:ClippedName()
	local name = self:Name()
	if #name > 16 then
		name = string.sub(name, 1, 14)..".."
	end

	return name
end

function meta:DispatchAltUse()
	local tr = self:TraceLine(64, MASK_SOLID, self:GetMeleeFilter())
	local ent = tr.Entity
	if ent and ent:IsValid() then
		if ent.AltUse then
			return ent:AltUse(self, tr)
		end
	end
end

function meta:MeleeViewPunch(damage)
	local maxpunch = (damage + 25) * 0.5
	local minpunch = -maxpunch
	self:ViewPunch(Angle(math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch)))
end

function meta:NearArsenalCrate()
	local pos = self:EyePos()

	for _, ent in pairs(ents.FindByClass("prop_arsenalcrate")) do
		local nearest = ent:NearestPoint(pos)
		if pos:Distance(nearest) <= 80 and (WorldVisible(pos, nearest) or self:TraceLine(80).Entity == ent) then
			return true
		end
	end

	return false
end
meta.IsNearArsenalCrate = meta.NearArsenalCrate

function meta:NearestArsenalCrateOwnedByOther()
	local pos = self:EyePos()

	for _, ent in pairs(ents.FindByClass("prop_arsenalcrate")) do
		local nearest = ent:NearestPoint(pos)
		local owner = ent:GetObjectOwner()
		if owner ~= self and owner:IsValid() and owner:IsPlayer() and owner:Team() == TEAM_HUMAN and pos:Distance(nearest) <= 80 and (WorldVisible(pos, nearest) or self:TraceLine(80).Entity == ent) then
			return ent
		end
	end
end

function meta:AddLegDamage(damage)
	self:SetLegDamage(self:GetLegDamage() + damage)
end

function meta:SetPoints(points)
	self:SetDTInt(1, points)
end

function meta:GetPoints()
	return self:GetDTInt(1)
end

function meta:SetPalsy(onoff, nosend)
	self.m_Palsy = onoff
	if SERVER and not nosend then
		self:SendLua("LocalPlayer():SetPalsy("..tostring(onoff)..")")
	end
end

function meta:GetPalsy()
	return self.m_Palsy
end

function meta:SetHemophilia(onoff, nosend)
	self.m_Hemophilia = onoff
	if SERVER and not nosend then
		self:SendLua("LocalPlayer():SetHemophilia("..tostring(onoff)..")")
	end
end

function meta:GetHemophilia()
	return self.m_Hemophilia
end

function meta:SetUnlucky(onoff)
	self.m_Unlucky = onoff
end

function meta:GetUnlucky()
	return self.m_Unlucky
end

function meta:SetLegDamage(damage)
	self:SetDTFloat(2, CurTime() + math.min(GAMEMODE.MaxLegDamage, damage * 0.125))
end

function meta:RawSetLegDamage(time)
	self:SetDTFloat(2, math.min(CurTime() + GAMEMODE.MaxLegDamage, time))
end

function meta:RawCapLegDamage(time)
	self:RawSetLegDamage(math.max(self:GetDTFloat(2), time))
end

function meta:GetLegDamage()
	return math.max(0, self:GetDTFloat(2) - CurTime())
end

function meta:ProcessDamage(dmginfo)
	local attacker, inflictor = dmginfo:GetAttacker(), dmginfo:GetInflictor()

	if self.DamageVulnerability then
		dmginfo:SetDamage(dmginfo:GetDamage() * self.DamageVulnerability)
	end

	--[[if dmginfo:IsBulletDamage() then
		local hitgroup = self:LastHitGroup() or HITGROUP_GENERIC
		gamemode.Call("ScalePlayerDamage", self, hitgroup, dmginfo)

		if hitgroup == HITGROUP_HEAD then
			self.m_LastHeadShot = CurTime()
		end
	end]]

	if self:Team() == TEAM_UNDEAD then
		if self ~= attacker then
			dmginfo:SetDamage(dmginfo:GetDamage() * GAMEMODE:GetZombieDamageScale(dmginfo:GetDamagePosition(), pl))
		end

		return self:CallZombieFunction("ProcessDamage", dmginfo)
	elseif attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD and inflictor:IsValid() and inflictor == attacker:GetActiveWeapon() then
		local scale = inflictor.SlowDownScale or 1
		if dmginfo:GetDamage() >= 40 or scale > 1 then
			self:RawCapLegDamage(self:GetLegDamage() + CurTime() + dmginfo:GetDamage() * 0.04 * (inflictor.SlowDownScale or 1))
		end
	end
end

function meta:KnockDown(time)
	if self:Team() ~= TEAM_UNDEAD then
		self:GiveStatus("knockdown", time or 3)
	end
end

function meta:GetZombieClass()
	return self.Class or GAMEMODE.DefaultZombieClass
end

function meta:GetZombieClassTable()
	return GAMEMODE.ZombieClasses[self:GetZombieClass()]
end

function meta:CallZombieFunction(funcname, ...)
	if self:Team() == TEAM_UNDEAD then
		local tab = self:GetZombieClassTable()
		if tab and tab[funcname] then
			return tab[funcname](tab, self, ...)
		end
	end
end

function meta:TraceLine(distance, mask, filter, start)
	start = start or self:GetShootPos()
	return util.TraceLine({start = start, endpos = start + self:GetAimVector() * distance, filter = filter or self, mask = mask})
end

function meta:TraceHull(distance, mask, size, filter, start)
	start = start or self:GetShootPos()
	return util.TraceHull({start = start, endpos = start + self:GetAimVector() * distance, filter = filter or self, mask = mask, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)})
end

function meta:DoubleTrace(distance, mask, size, mask2, filter)
	local tr1 = self:TraceLine(distance, mask, filter)
	if tr1.Hit then return tr1 end
	if mask2 then
		local tr2 = self:TraceLine(distance, mask2, filter)
		if tr2.Hit then return tr2 end
	end

	local tr3 = self:TraceHull(distance, mask, size, filter)
	if tr3.Hit then return tr3 end
	if mask2 then
		local tr4 = self:TraceHull(distance, mask2, size, filter)
		if tr4.Hit then return tr4 end
	end

	return tr1
end

function meta:SetSpeed(speed)
	if not speed then speed = 200 end

	self:SetWalkSpeed(speed)
	self:SetRunSpeed(speed)
	self:SetMaxSpeed(speed)
end

function meta:SetHumanSpeed(speed)
	if self:Team() == TEAM_HUMAN then self:SetSpeed(speed) end
end

function meta:ResetSpeed(noset, health)
	if not self:IsValid() then return end

	if self:Team() == TEAM_UNDEAD then
		local speed = self:GetZombieClassTable().Speed * GAMEMODE.ZombieSpeedMultiplier
		self:SetSpeed(speed)
		return speed
	end

	local wep = self:GetActiveWeapon()
	local speed

	if wep:IsValid() and wep.GetWalkSpeed then
		speed = wep:GetWalkSpeed()
	end

	if not speed then
		speed = wep.WalkSpeed or SPEED_NORMAL
	end

	if self.HumanSpeedAdder and self:Team() == TEAM_HUMAN and 32 < speed then
		speed = speed + self.HumanSpeedAdder
	end

	if self:IsHolding() then
		local status = self.status_human_holding
		if status and status:IsValid() and status:GetObject():IsValid() and status:GetObject():GetPhysicsObject():IsValid() then
			speed = math.min(speed, math.max(CARRY_SPEEDLOSS_MINSPEED, speed - status:GetObject():GetPhysicsObject():GetMass() * CARRY_SPEEDLOSS_PERKG))
		end
	end

	if 32 < speed then
		if not health then health = self:Health() end
		/*
		if health < 60 then
			speed = math.max(88, speed - speed * 0.4 * (1 - health / 60))
		end
		*/
	end

	if not noset then
		self:SetSpeed(speed)
	end

	return speed
end

function meta:ResetJumpPower(noset)
	local power = DEFAULT_JUMP_POWER

	if self:Team() == TEAM_UNDEAD then
		local classtab = self:GetZombieClassTable()
		if classtab and classtab.JumpPower then
			power = classtab.JumpPower
		end
	/*else
		if self:GetBarricadeGhosting() then
			power = power * 0.25
			if not noset then
				self:SetJumpPower(power)
			end

			return power
		end*/
	end

	local wep = self:GetActiveWeapon()
	if wep and wep.ResetJumpPower then
		power = wep:ResetJumpPower(power) or power
	end

	if not noset then
		self:SetJumpPower(power)
	end

	return power
end

function meta:SetBarricadeGhosting(b)
	if b and self.NoGhosting then return end

	self:SetDTBool(0, b)

	if not b then
		self.GhostingEntities = {}
	end

	self:ResetJumpPower()
	self:CollisionRulesChanged()
end

function meta:GetBarricadeGhosting()
	return self:GetDTBool(0)
end

local function PointInBox(pos, mins, maxs)
	return pos.x <= maxs.x and pos.x >= mins.x
	and pos.y <= maxs.y and pos.y >= mins.y
	and pos.z <= maxs.z and pos.z >= mins.z
end

function meta:ShouldBarricadeGhostWith(ent)
	return ent:IsBarricadeProp() or ( ent:IsPlayer() and ent:Team() == TEAM_UNDEAD ) -- Phase through zombies? Yes please! =D
end

function meta:BarricadeGhostingThink()
	local abg = self:ActiveBarricadeGhosting()
	if self:KeyDown(IN_ZOOM) or abg then 
		if !self.bghost and !self:IsOnGround() and abg then
			local oldVel = self:GetVelocity()
			self:SetVelocity(Vector(-oldVel.x*0.9,-oldVel.y*0.9,0))
			self.bghost = true
		end
		return
	end

	self.bghost = nil
	self:SetBarricadeGhosting(false)
end

function meta:ShouldNotCollide(ent)
	return ent:IsPlayer() and (self:Team() == ent:Team() or self.NoCollideAll or ent.NoCollideAll) or self:GetBarricadeGhosting() and self:ShouldBarricadeGhostWith(ent) or ent:GetPhysicsObject():IsValid() and ent:GetPhysicsObject():HasGameFlag(FVPHYSICS_PLAYER_HELD)
end

local function nocollidetimer(self, timername)
	if self:IsValid() then
		for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
			if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
				return
			end
		end

		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	end

	timer.Destroy(timername)
end

function meta:TemporaryNoCollide(force)
	if self:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER and not force then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local timername = "TemporaryNoCollide"..self:UniqueID()
			timer.CreateEx(timername, 0, 0, nocollidetimer, self, timername)

			return
		end
	end

	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end

meta.OldSetHealth = FindMetaTable("Entity").SetHealth
function meta:SetHealth(health)
	self:OldSetHealth(health)
	if self:Team() == TEAM_HUMAN and 1 <= health then
		self:ResetSpeed(nil, health)
	end
end

function meta:IsHeadcrab()
	return self:Team() == TEAM_UNDEAD and GAMEMODE.ZombieClasses[self:GetZombieClass()].IsHeadcrab
end

function meta:AirBrake()
	local vel = self:GetVelocity()

	vel.x = vel.x * 0.15
	vel.y = vel.y * 0.15
	if vel.z > 0 then
		vel.z = vel.z * 0.15
	end

	self:SetLocalVelocity(vel)
end

function meta:GetMeleeFilter()
	return team.GetPlayers(self:Team())
end
meta.GetMeleeFilterOld = meta.GetMeleeFilter
meta.GetTraceFilter = meta.GetMeleeFilter

function meta:MeleeTrace(distance, size, filter, start)
	return self:TraceHull(distance, MASK_SOLID, size, filter, start)
end

function meta:PenetratingMeleeTrace(distance, size, prehit, start)
	start = start or self:GetShootPos()

	local t = {}
	local trace = {start = start, endpos = start + self:GetAimVector() * distance, filter = self:GetMeleeFilter(), mask = MASK_SOLID, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)}
	local onlyhitworld
	for i=1, 50 do
		local tr = util.TraceHull(trace)

		if not tr.Hit then break end

		if tr.HitWorld then
			table.insert(t, tr)
			break
		end

		if onlyhitworld then break end

		local ent = tr.Entity
		if ent and ent:IsValid() then
			if not ent:IsPlayer() then
				trace.mask = MASK_SOLID_BRUSHONLY
				onlyhitworld = true
			end

			table.insert(t, tr)
			table.insert(trace.filter, ent)
		end
	end

	if prehit and (#t == 1 and not t[1].HitNonWorld and prehit.HitNonWorld or #t == 0 and prehit.HitNonWorld) then
		t[1] = prehit
	end

	return t
end

function meta:ActiveBarricadeGhosting()
	if self:Team() ~= TEAM_HUMAN or not self:GetBarricadeGhosting() then return false end

	for _, ent in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if self:ShouldBarricadeGhostWith(ent) then return true end
	end

	return false
end

function meta:IsHolding()
	return self.status_human_holding and self.status_human_holding:IsValid()
end
meta.IsCarrying = meta.IsHolding

function meta:GetMaxZombieHealth()
	return GAMEMODE.ZombieClasses[self:GetZombieClass()].Health
end

local oldmaxhealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	if self:Team() == TEAM_UNDEAD then
		return self:GetMaxZombieHealth()
	end

	return oldmaxhealth(self)
end

meta.OldAlive = meta.Alive
function meta:Alive()
	if self:GetObserverMode() ~= OBS_MODE_NONE or self:Team() == TEAM_UNDEAD and GAMEMODE.ZombieClasses[self:GetZombieClass()].Name == "Crow" then return false end

	return self:OldAlive()
end

local VoiceSets = {}

VoiceSets["male"] = {
	["GiveAmmoSounds"] = {
		Sound("vo/npc/male01/ammo03.wav"),
		Sound("vo/npc/male01/ammo04.wav"),
		Sound("vo/npc/male01/ammo05.wav")
	},
	["PainSoundsLight"] = {
		Sound("vo/npc/male01/ow01.wav"),
		Sound("vo/npc/male01/ow02.wav"),
		Sound("vo/npc/male01/pain01.wav"),
		Sound("vo/npc/male01/pain02.wav"),
		Sound("vo/npc/male01/pain03.wav")
	},
	["PainSoundsMed"] = {
		Sound("vo/npc/male01/pain04.wav"),
		Sound("vo/npc/male01/pain05.wav"),
		Sound("vo/npc/male01/pain06.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("vo/npc/male01/pain07.wav"),
		Sound("vo/npc/male01/pain08.wav"),
		Sound("vo/npc/male01/pain09.wav")
	},
	["DeathSounds"] = {
		Sound("vo/npc/male01/no02.wav"),
		Sound("ambient/voices/citizen_beaten1.wav"),
		Sound("ambient/voices/citizen_beaten3.wav"),
		Sound("ambient/voices/citizen_beaten4.wav"),
		Sound("ambient/voices/citizen_beaten5.wav"),
		Sound("vo/npc/male01/pain07.wav"),
		Sound("vo/npc/male01/pain08.wav")
	},
	["EyePoisonedSounds"] = {
		Sound("ambient/voices/m_scream1.wav")
	}
}

VoiceSets["barney"] = {
	["GiveAmmoSounds"] = {
		Sound("items/ammo_pickup.wav")
	},
	["PainSoundsLight"] = {
		Sound("vo/npc/Barney/ba_pain02.wav"),
		Sound("vo/npc/Barney/ba_pain07.wav"),
		Sound("vo/npc/Barney/ba_pain04.wav")
	},
	["PainSoundsMed"] = {
		Sound("vo/npc/Barney/ba_pain01.wav"),
		Sound("vo/npc/Barney/ba_pain08.wav"),
		Sound("vo/npc/Barney/ba_pain10.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("vo/npc/Barney/ba_pain05.wav"),
		Sound("vo/npc/Barney/ba_pain06.wav"),
		Sound("vo/npc/Barney/ba_pain09.wav")
	},
	["DeathSounds"] = {
		Sound("vo/npc/Barney/ba_ohshit03.wav"),
		Sound("vo/npc/Barney/ba_no01.wav"),
		Sound("vo/npc/Barney/ba_no02.wav"),
		Sound("vo/npc/Barney/ba_pain03.wav")
	},
	["EyePoisonedSounds"] = {
		Sound("vo/k_lab/ba_thingaway02.wav")
	}
}

VoiceSets["female"] = {
	["GiveAmmoSounds"] = {
		Sound("vo/npc/female01/ammo03.wav"),
		Sound("vo/npc/female01/ammo04.wav"),
		Sound("vo/npc/female01/ammo05.wav")
	},
	["PainSoundsLight"] = {
		Sound("vo/npc/female01/pain01.wav"),
		Sound("vo/npc/female01/pain02.wav"),
		Sound("vo/npc/female01/pain03.wav")
	},
	["PainSoundsMed"] = {
		Sound("vo/npc/female01/pain04.wav"),
		Sound("vo/npc/female01/pain05.wav"),
		Sound("vo/npc/female01/pain06.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("vo/npc/female01/pain07.wav"),
		Sound("vo/npc/female01/pain08.wav"),
		Sound("vo/npc/female01/pain09.wav")
	},
	["DeathSounds"] = {
		Sound("vo/npc/female01/no01.wav"),
		Sound("vo/npc/female01/ow01.wav"),
		Sound("vo/npc/female01/ow02.wav"),
		Sound("vo/npc/female01/goodgod.wav"),
		Sound("ambient/voices/citizen_beaten2.wav")
	},
	["EyePoisonedSounds"] = {
		Sound("ambient/voices/f_scream1.wav")
	}
}

VoiceSets["alyx"] = {
	["GiveAmmoSounds"] = {
		Sound("vo/npc/female01/ammo03.wav"),
		Sound("vo/npc/female01/ammo04.wav"),
		Sound("vo/npc/female01/ammo05.wav")
	},
	["PainSoundsLight"] = {
		Sound("vo/npc/Alyx/gasp03.wav"),
		Sound("vo/npc/Alyx/hurt08.wav")
	},
	["PainSoundsMed"] = {
		Sound("vo/npc/Alyx/hurt04.wav"),
		Sound("vo/npc/Alyx/hurt06.wav"),
		Sound("vo/Citadel/al_struggle07.wav"),
		Sound("vo/Citadel/al_struggle08.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("vo/npc/Alyx/hurt05.wav"),
		Sound("vo/npc/Alyx/hurt06.wav")
	},
	["DeathSounds"] = {
		Sound("vo/npc/Alyx/no01.wav"),
		Sound("vo/npc/Alyx/no02.wav"),
		Sound("vo/npc/Alyx/no03.wav"),
		Sound("vo/Citadel/al_dadgordonno_c.wav"),
		Sound("vo/Streetwar/Alyx_gate/al_no.wav")
	},
	["EyePoisonedSounds"] = {
		Sound("vo/npc/Alyx/uggh01.wav"),
		Sound("vo/npc/Alyx/uggh02.wav")
	}
}

VoiceSets["combine"] = {
	["GiveAmmoSounds"] = {
		Sound("npc/combine_soldier/vo/hardenthatposition.wav"),
		Sound("npc/combine_soldier/vo/readyweapons.wav"),
		Sound("npc/combine_soldier/vo/weareinaninfestationzone.wav"),
		Sound("npc/metropolice/vo/dismountinghardpoint.wav")
	},
	["PainSoundsLight"] = {
		Sound("npc/combine_soldier/pain1.wav"),
		Sound("npc/combine_soldier/pain2.wav"),
		Sound("npc/combine_soldier/pain3.wav")
	},
	["PainSoundsMed"] = {
		Sound("npc/metropolice/pain1.wav"),
		Sound("npc/metropolice/pain2.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("npc/metropolice/pain3.wav"),
		Sound("npc/metropolice/pain4.wav")
	},
	["DeathSounds"] = {
		Sound("npc/combine_soldier/die1.wav"),
		Sound("npc/combine_soldier/die2.wav"),
		Sound("npc/combine_soldier/die3.wav")
	},
	["EyePoisonSounds"] = {
		Sound("npc/combine_soldier/die1.wav"),
		Sound("npc/combine_soldier/die2.wav"),
		Sound("npc/metropolice/vo/shit.wav")
	}
}

VoiceSets["monk"] = {
	["GiveAmmoSounds"] = {
		Sound("vo/ravenholm/monk_giveammo01.wav")
	},
	["PainSoundsLight"] = {
		Sound("vo/ravenholm/monk_pain01.wav"),
		Sound("vo/ravenholm/monk_pain02.wav"),
		Sound("vo/ravenholm/monk_pain03.wav"),
		Sound("vo/ravenholm/monk_pain05.wav")
	},
	["PainSoundsMed"] = {
		Sound("vo/ravenholm/monk_pain04.wav"),
		Sound("vo/ravenholm/monk_pain06.wav"),
		Sound("vo/ravenholm/monk_pain07.wav"),
		Sound("vo/ravenholm/monk_pain08.wav")
	},
	["PainSoundsHeavy"] = {
		Sound("vo/ravenholm/monk_pain09.wav"),
		Sound("vo/ravenholm/monk_pain10.wav"),
		Sound("vo/ravenholm/monk_pain12.wav")
	},
	["DeathSounds"] = {
		Sound("vo/ravenholm/monk_death07.wav")
	},
	["EyePoisonSounds"] = {
		Sound("vo/ravenholm/monk_death07.wav")
	}
}

function meta:PlayEyePoisonedSound()
	local snds = VoiceSets[self.VoiceSet].EyePoisonSounds
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayGiveAmmoSound()
	local snds = VoiceSets[self.VoiceSet].GiveAmmoSounds
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayDeathSound()
	local snds = VoiceSets[self.VoiceSet].DeathSounds
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayZombieDeathSound()
	if not self:CallZombieFunction("PlayDeathSound") then
		local snds = self:GetZombieClassTable().DeathSounds
		if snds then
			self:EmitSound(snds[math.random(1, #snds)])
		end
	end
end

function meta:PlayPainSound()
	if CurTime() < self.NextPainSound then return end

	local snds

	if self:Team() == TEAM_UNDEAD then
		if self:CallZombieFunction("PlayPainSound") then return end
		snds = self:GetZombieClassTable().PainSounds
	else
		local set = VoiceSets[self.VoiceSet]
		if set then
			local health = self:Health()
			if 70 <= health then
				snds = set.PainSoundsLight
			elseif 35 <= health then
				snds = set.PainSoundsMed
			else
				snds = set.PainSoundsHeavy
			end
		end
	end

	if snds then
		local snd = snds[math.random(1, #snds)]
		if snd then
			self:EmitSound(snd)
			self.NextPainSound = CurTime() + SoundDuration(snd) - 0.1
		end
	end
end

local ViewHullMins = Vector(-8, -8, -8)
local ViewHullMaxs = Vector(8, 8, 8)
function meta:GetThirdPersonCameraPos(origin, angles)
	local allplayers = player.GetAll()
	local tr = util.TraceHull({start = origin, endpos = origin + angles:Forward() * -math.max(36, self:Team() == TEAM_UNDEAD and self:GetZombieClassTable().CameraDistance or self:BoundingRadius()), mask = MASK_SHOT, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
	return tr.HitPos + tr.HitNormal * 3
end

-- Override these because they're different in 1st person and on the server.
function meta:SyncAngles()
	local ang = self:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	return ang
end
meta.GetAngles = meta.SyncAngles

function meta:GetForward()
	return self:SyncAngles():Forward()
end

function meta:GetUp()
	return self:SyncAngles():Up()
end

function meta:GetRight()
	return self:SyncAngles():Right()
end
