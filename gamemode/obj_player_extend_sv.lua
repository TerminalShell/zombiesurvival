local meta = FindMetaTable("Player")
if not meta then return end

function meta:ChangeTeam(teamid)
	local oldteam = self:Team()
	self:SetTeam(teamid)
	if oldteam ~= teamid then
		gamemode.Call("OnPlayerChangedTeam", self, oldteam, teamid)
	end

	self:CollisionRulesChanged()
end

function meta:FloatingScore(victimorpos, effectname, frags, flags)
	if type(victimorpos) == "Vector" then
		umsg.Start("floatingscore_vec", self)
			umsg.Vector(victimorpos)
			umsg.String(effectname)
			umsg.Short(frags)
			umsg.Short(flags)
		umsg.End()
	else
		umsg.Start("floatingscore", self)
			umsg.Entity(victimorpos)
			umsg.String(effectname)
			umsg.Short(frags)
			umsg.Short(flags)
		umsg.End()
	end
end

function meta:PrintTranslatedMessage(hudprinttype, translateid, ...)
	if ... ~= nil then
		self:PrintMessage(hudprinttype, translate.ClientFormat(self, translateid, ...))
	else
		self:PrintMessage(hudprinttype, translate.ClientGet(self, translateid))
	end
end

function meta:RefreshDynamicSpawnPoint()
	local target = self:GetObserverTarget()
	if GAMEMODE.DynamicSpawning and self:GetObserverMode() == OBS_MODE_CHASE and target and target:IsValid() and target:IsPlayer() and target:Team() == TEAM_UNDEAD then
		self.ForceDynamicSpawn = target
	else
		self.ForceDynamicSpawn = nil
	end
end

function meta:CreateFakeFlashlight()
	self:RemoveFakeFlashlight()

	local ent = ents.Create("env_projectedtexture")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetLocalPos(Vector(16000, 16000, 16000))
		ent:SetAngles(self:EyeAngles())
		ent:SetOwner(self)
		ent:SetKeyValue("enableshadows", 0)
		ent:SetKeyValue("farz", 1024)
		ent:SetKeyValue("nearz", 8)
		ent:SetKeyValue("lightfov", 60)
		ent:SetKeyValue("lightcolor", "0 255 255 255")
		ent:Spawn()
		ent:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")

		self.FakeFlashlight = ent
	end
end

function meta:RemoveFakeFlashlight()
	if IsValid(self.FakeFlashlight) then
		self.FakeFlashlight:Remove()
	end
end

function meta:ChangeToCrow()
	self.StartCrowing = nil

	local crowclass = GAMEMODE.ZombieClasses["Crow"]
	if not crowclass then return end

	local curclass = self.DeathClass or self:GetZombieClass()
	local crowindex = crowclass.Index
	self:SetZombieClass(crowindex)
	self:DoHulls(crowindex, TEAM_UNDEAD)

	self.DeathClass = nil
	self:UnSpectateAndSpawn()
	self.DeathClass = curclass
end

function meta:SelectRandomPlayerModel()
	self:SetModel(player_manager.TranslatePlayerModel(GAMEMODE.RandomPlayerModels[math.random(#GAMEMODE.RandomPlayerModels)]))
end

function meta:GiveEmptyWeapon(weptype)
	if not self:HasWeapon(weptype) then
		local wep = self:Give(weptype)
		if wep:IsValid() and wep:IsWeapon() then
			wep:EmptyAll()
		end

		return wep
	end
end

-- Here for when garry makes weapons use 357 ammo like he does every other update.
--[[local oldgive = meta.Give
function meta:Give(...)
	local wep = oldgive(self, ...)
	if wep:IsValid() then
		if wep.Primary and wep.Primary.Ammo and wep.Primary.Ammo ~= "none" then
			self:RemoveAmmo(wep.Primary.DefaultClip - wep.Primary.ClipSize, "357")
			wep:SetClip1(0)

			if wep.Primary.DefaultClip > wep.Primary.ClipSize then
				self:GiveAmmo(wep.Primary.DefaultClip, wep.Primary.Ammo, true)
			end
			wep:SetClip1(wep.Primary.ClipSize)
			self:RemoveAmmo(wep.Primary.ClipSize, wep.Primary.Ammo)
		end
		if wep.Secondary and wep.Secondary.Ammo and wep.Secondary.Ammo ~= "none" then
			self:RemoveAmmo(wep.Secondary.DefaultClip - wep.Secondary.ClipSize, "357")
			wep:SetClip2(0)

			if wep.Secondary.DefaultClip > wep.Secondary.ClipSize then
				self:GiveAmmo(wep.Secondary.DefaultClip, wep.Secondary.Ammo, true)
			end
			wep:SetClip2(wep.Secondary.ClipSize)
			self:RemoveAmmo(wep.Secondary.ClipSize, wep.Secondary.Ammo)
		end
	end
	return wep
end]]

function meta:StartFeignDeath()
	local feigndeath = self.FeignDeath
	if feigndeath and feigndeath:IsValid() then
		if CurTime() >= feigndeath:GetStateEndTime() then
			feigndeath:SetState(1)
			feigndeath:SetStateEndTime(CurTime() + 1.5)
		end
	elseif self:IsOnGround() then
		local wep = self:GetActiveWeapon()
		if wep:IsValid() and not wep:IsSwinging() and CurTime() > wep:GetNextPrimaryFire() then
			if wep.StopMoaning then
				wep:StopMoaning()
			end

			local status = self:GiveStatus("feigndeath")
			if status and status:IsValid() then
				status:SetStateEndTime(CurTime() + 1.5)
			end
		end
	end
end

function meta:SendHint()
end

local function RemoveSkyCade(groundent, timername)
	if not groundent:IsValid() or not groundent:IsNailedToWorldHierarchy() then
		timer.Destroy(timername)
		return
	end

	for _, pl in pairs(player.GetAll()) do
		if pl:Alive() and pl:GetGroundEntity() == groundent then
			groundent:TakeDamage(3, groundent, groundent)
			if math.random(1, 8) == 1 then
				groundent:EmitSound("npc/strider/creak"..math.random(1, 5)..".wav", 65, math.random(95, 105))
			end

			return
		end
	end

	timer.Destroy(timername)
end
local checkoffset = Vector(0, 0, -90)
function meta:PreventSkyCade()
	local groundent = self:GetGroundEntity()
	if groundent:IsValid() and groundent:IsNailedToWorldHierarchy() then
		local phys = groundent:GetPhysicsObject()
		if phys:IsValid() and phys:GetMass() <= CARRY_DRAG_MASS then
			local timername = "RemoveSkyCade"..tostring(groundent)
			local start = groundent:LocalToWorld(groundent:OBBCenter())
			if not timer.Exists(timername) and not util.TraceHull({start = start,
									endpos = start + checkoffset,
									mins = groundent:OBBMins() * 0.9, maxs = groundent:OBBMaxs() * 0.9,
									mask = MASK_SOLID_BRUSHONLY}) then
				timer.CreateEx(timername, 0.25, 0, RemoveSkyCade, groundent, timername) -- Oh dear.
			end
		end
	end
end

function meta:CoupleWith(plheadcrab)
	if self:GetZombieClassTable().Headcrab == plheadcrab:GetZombieClassTable().Name then
		local status = self:GiveStatus("headcrabcouple")
		if status:IsValid() then
			status:SetPartner(plheadcrab)
		end
	end
end

function meta:SplitMessage(message, submessage)
	self:SendLua("GAMEMODE:SplitMessage("..string.format("%q", message or "")..","..string.format("%q", submessage or "")..")")
end

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

function meta:RemoveAllStatus(bSilent, bInstant)
	if bInstant then
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent:Remove()
			end
		end
	else
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
		end
	end
end

function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
	local removed

	for _, ent in pairs(ents.FindByClass("status_"..sType)) do
		if ent:GetOwner() == self and not (sExclude and ent:GetClass() == "status_"..sExclude) then
			if bInstant then
				ent:Remove()
			else
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
			removed = true
		end
	end

	return removed
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:IsValid() and ent.Owner == self then return ent end
end

function meta:GiveStatus(sType, fDie)
	local cur = self:GetStatus(sType)
	if cur then
		if fDie then
			cur:SetDie(fDie)
		end
		cur:SetPlayer(self, true)
		return cur
	else
		local ent = ents.Create("status_"..sType)
		if ent:IsValid() then
			ent:Spawn()
			if fDie then
				ent:SetDie(fDie)
			end
			ent:SetPlayer(self)
			return ent
		end
	end
end

function meta:UnSpectateAndSpawn()
	self:UnSpectate()
	self:Spawn()
end

function meta:SecondWind(pl)
	if self.Gibbed or self:Alive() or self:Team() ~= TEAM_UNDEAD then return end

	local pos = self:GetPos()
	local angles = self:EyeAngles()
	local lastattacker = self:GetLastAttacker()
	local dclass = self.DeathClass
	self.DeathClass = nil
	self.Revived = true
	self:UnSpectateAndSpawn()
	self.Revived = nil
	self.DeathClass = dclass
	self:SetLastAttacker(lastattacker)
	self:SetPos(pos)
	self:SetHealth(self:Health() * 0.2)
	self:SetEyeAngles(angles)

	self:CallZombieFunction("OnSecondWind")
end

function meta:DropAll()
	self:DropAllAmmo()
	self:DropAllWeapons()
end

local function CreateRagdoll(pl)
	if pl:IsValid() then pl:OldCreateRagdoll() end
end

local function SetModel(pl, mdl)
	if pl:IsValid() then
		pl:SetModel(mdl)
		timer.SimpleEx(0, CreateRagdoll, pl)
	end
end

meta.OldCreateRagdoll = meta.CreateRagdoll
function meta:CreateRagdoll()
	local status = self.status_overridemodel
	if status and status:IsValid() then
		timer.SimpleEx(0, SetModel, self, status:GetModel())
		status:SetRenderMode(RENDERMODE_NONE)
	else
		self:OldCreateRagdoll()
	end
end

function meta:DropWeaponByType(class)
	local wep = self:GetWeapon(class)
	if wep and wep:IsValid() and not wep.Undroppable then
		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetWeaponType(class)
			ent:Spawn()
			ent:SetClip1(wep:Clip1())
			ent:SetClip2(wep:Clip2())

			self:StripWeapon(class)

			return ent
		end
	end
end

function meta:DropAllWeapons()
	local vPos = self:GetPos()
	local vVel = self:GetVelocity()
	local zmax = self:OBBMaxs().z * 0.75
	for _, wep in pairs(self:GetWeapons()) do
		local ent = self:DropWeaponByType(wep:GetClass())
		if ent and ent:IsValid() then
			ent:SetPos(vPos + Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(2, zmax)))
			ent:SetAngles(VectorRand():Angle())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:AddAngleVelocity(Vector(math.Rand(-720, 720), math.Rand(-720, 720), math.Rand(-720, 720)))
				phys:ApplyForceCenter(phys:GetMass() * (math.Rand(32, 328) * VectorRand():GetNormalized() + vVel))
			end
		end
	end
end

function meta:DropAmmoByType(ammotype, amount)
	local mycount = self:GetAmmoCount(ammotype)
	amount = math.min(mycount, amount or mycount)
	if not amount or amount <= 0 then return end

	local ent = ents.Create("prop_ammo")
	if ent:IsValid() then
		ent:SetAmmoType(ammotype)
		ent:SetAmmo(amount)
		ent:Spawn()

		self:RemoveAmmo(amount, ammotype)

		return ent
	end
end

function meta:DropAllAmmo()
	local vPos = self:GetPos()
	local vVel = self:GetVelocity()
	local zmax = self:OBBMaxs().z * 0.75
	for ammotype in pairs(GAMEMODE.AmmoCache) do
		local ent = self:DropAmmoByType(ammotype)
		if ent and ent:IsValid() then
			ent:SetPos(vPos + Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(2, zmax)))
			ent:SetAngles(VectorRand():Angle())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:AddAngleVelocity(Vector(math.Rand(-720, 720), math.Rand(-720, 720), math.Rand(-720, 720)))
				phys:ApplyForceCenter(phys:GetMass() * (math.Rand(32, 328) * VectorRand():GetNormalized() + vVel))
			end
		end
	end
end

-- Lets other players know about our maximum health.
meta.OldSetMaxHealth = FindMetaTable("Entity").SetMaxHealth
function meta:SetMaxHealth(num)
	num = math.ceil(num)
	self:SetDTInt(0, num)
	self:OldSetMaxHealth(num)
end

function meta:PointCashOut(ent, fmtype)
	if self.m_PointQueue >= 1 and self:Team() == TEAM_HUMAN then
		local points = math.floor(self.m_PointQueue)
		self.m_PointQueue = self.m_PointQueue - points

		self:AddPoints(points)
		self:FloatingScore(ent or self.m_LastDamageDealtPosition or vector_origin, "floatingscore", points, fmtype or FM_NONE)
	end
end

function meta:AddPoints(points)
	self:AddFrags(points)
	self:SetPoints(self:GetPoints() + points)

	gamemode.Call("PlayerPointsAdded", self, points)
end

function meta:TakePoints(points)
	self:SetPoints(self:GetPoints() - points)
end

function meta:UpdateAllZombieClasses()
	for _, pl in pairs(player.GetAll()) do
		if pl ~= self and pl:Team() == TEAM_UNDEAD then
			local id = pl:GetZombieClass()
			if id and 0 < id then
				umsg.Start("setzclass", self)
					umsg.Entity(pl)
					umsg.Short(id)
				umsg.End()
			end
		end
	end
end

function meta:CreateAmbience(class)
	class = "status_"..class

	for _, ent in pairs(ents.FindByClass(class)) do
		if ent:GetOwner() == self then return end
	end

	local ent = ents.Create(class)
	if ent:IsValid() then
		ent:SetPos(self:LocalToWorld(self:OBBCenter()))
		self[class] = ent
		ent:SetOwner(self)
		ent:SetParent(self)
		ent:Spawn()
	end
end

function meta:SetZombieClass(cl, onlyupdate, filter)
	if onlyupdate then
		umsg.Start("setzclass", filter)
			umsg.Entity(self)
			umsg.Short(cl)
		umsg.End()
		return
	end

	self:CallZombieFunction("SwitchedAway")

	local classtab = GAMEMODE.ZombieClasses[cl]
	if classtab then
		self.Class = cl
		if self:Team() == TEAM_UNDEAD then
			self:DoHulls(cl)
		end
		self:CallZombieFunction("SwitchedTo")

		umsg.Start("setzclass", filter)
			umsg.Entity(self)
			umsg.Short(cl)
		umsg.End()
	end
end

function meta:DoHulls(classid, teamid)
	teamid = teamid or self:Team()

	if teamid == TEAM_UNDEAD then
		classid = classid or -10
		local classtab = GAMEMODE.ZombieClasses[classid]
		if classtab then
			if self:Alive() then
				self:SetMoveType(classtab.MoveType or MOVETYPE_WALK)
			end

			if not classtab.Hull or not classtab.HullDuck then
				self:ResetHull()
			end
			if classtab.Hull then
				self:SetHull(classtab.Hull[1], classtab.Hull[2])
			end
			if classtab.HullDuck then
				self:SetHullDuck(classtab.HullDuck[1], classtab.HullDuck[2])
			end
			if classtab.ViewOffset then
				self:SetViewOffset(classtab.ViewOffset)
			elseif self:GetViewOffset() ~= DEFAULT_VIEW_OFFSET then
				self:SetViewOffset(DEFAULT_VIEW_OFFSET)
			end
			if classtab.ViewOffsetDucked then
				self:SetViewOffsetDucked(classtab.ViewOffsetDucked)
			elseif self:GetViewOffsetDucked() ~= DEFAULT_VIEW_OFFSET_DUCKED then
				self:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
			end
			if classtab.StepSize then
				self:SetStepSize(classtab.StepSize)
			elseif self:GetStepSize() ~= DEFAULT_STEP_SIZE then
				self:SetStepSize(DEFAULT_STEP_SIZE)
			end
			if classtab.JumpPower then
				self:SetJumpPower(classtab.JumpPower)
			elseif self:GetJumpPower() ~= DEFAULT_JUMP_POWER then
				self:SetJumpPower(DEFAULT_JUMP_POWER)
			end
			if classtab.ModelScale then
				self:SetModelScale(classtab.ModelScale, 0)
			elseif self:GetModelScale() ~= DEFAULT_MODELSCALE then
				self:SetModelScale(DEFAULT_MODELSCALE, 0)
			end

			self:DrawShadow(not classtab.NoShadow)

			self.NoCollideAll = classtab.NoCollideAll
			self.AllowTeamDamage = classtab.AllowTeamDamage
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMass(classtab.Mass or DEFAULT_MASS)
			end
		end
	else
		self:ResetHull()
		self:SetViewOffset(DEFAULT_VIEW_OFFSET)
		self:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
		self:SetStepSize(DEFAULT_STEP_SIZE)
		self:SetJumpPower(DEFAULT_JUMP_POWER)
		self:SetModelScale(DEFAULT_MODELSCALE, 0)

		self:DrawShadow(true)

		self.NoCollideAll = nil
		self.AllowTeamDamage = nil
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(DEFAULT_MASS)
		end
	end

	umsg.Start("dohulls")
		umsg.Entity(self)
		umsg.Short(classid)
		umsg.Short(teamid)
	umsg.End()

	self:CollisionRulesChanged()
end

function meta:Redeem()
	gamemode.Call("PlayerRedeemed", self)
end

function meta:RedeemNextFrame(manual)
	if manual then
		timer.SimpleEx(0, self.ManualRedeem, self, true)
	else
		timer.SimpleEx(0, self.CheckRedeem, self, true)
	end
end

function meta:TakeBrains(amount)
	self:AddFrags(-amount)
	self.BrainsEaten = self.BrainsEaten - 1
end

function meta:AddBrains(amount)
	self:AddFrags(amount)
	self.BrainsEaten = self.BrainsEaten + 1
	self:CheckRedeem()
end

function meta:CheckRedeem(instant)
	if self:IsValid() and self:Team() == TEAM_UNDEAD and GAMEMODE:GetRedeemBrains() > 0 and GAMEMODE:GetRedeemBrains() <= self:Frags() and GAMEMODE:GetWave() ~= GAMEMODE:GetNumberOfWaves() and not self.NoRedeeming and not self:GetZombieClassTable().Boss then
		if instant then
			self:Redeem()
		else
			self:RedeemNextFrame(false)
		end
	end
end

function meta:ManualRedeem(instant)
	if self:IsValid() and self:Team() == TEAM_UNDEAD and GAMEMODE:GetRedeemBrains() > 0 and GAMEMODE:GetRedeemBrains() <= self:Frags() and GAMEMODE:GetWave() ~= GAMEMODE:GetNumberOfWaves() and not self:GetZombieClassTable().Boss and not LASTHUMAN then
		if instant then
			self:Redeem()
		else
			self:RedeemNextFrame(true)
		end
	end
end

function meta:AntiGrief(damage, overridenostrict)
	if GAMEMODE.GriefStrict and not overridenostrict then return 0 end

	damage = math.ceil(damage * GAMEMODE.GriefForgiveness)

	self:GivePenalty(math.ceil(damage * 0.5))
	self:ReflectDamage(damage)

	return damage
end

function meta:GivePenalty(amount)
	self.m_PenaltyCarry = (self.m_PenaltyCarry or 0) + amount * 0.1
	local frags = math.floor(self.m_PenaltyCarry)
	if frags > 0 then
		self.m_PenaltyCarry = self.m_PenaltyCarry - frags
		self:GivePointPenalty(frags)
	end
end

function meta:GivePointPenalty(amount)
	self:SetFrags(self:Frags() - amount)

	umsg.Start("penalty", self)
		umsg.Short(amount)
	umsg.End()
end

function meta:ReflectDamage(damage)
	local frags = self:Frags()
	if frags < GAMEMODE.GriefReflectThreshold then
		self:TakeDamage(math.ceil(damage * frags * -0.05 * GAMEMODE.GriefDamageMultiplier))
	end
end

function meta:GiveWeaponByType(weapon, plyr, ammo)
	if ammo then
		local wep = self:GetActiveWeapon()
		if not wep or not wep:IsValid() or not wep.Primary then return end

		local ammotype = wep:ValidPrimaryAmmo()
		local ammocount = wep:GetPrimaryAmmoCount()
		if ammotype and ammocount then
			local desiredgive = math.min(ammocount, math.ceil((GAMEMODE.AmmoCache[ammotype] or wep.Primary.ClipSize) * 5))
			if desiredgive >= 1 then
				wep:TakeCombinedPrimaryAmmo(desiredgive)
				plyr:GiveAmmo(desiredgive, ammotype)

				self:PlayGiveAmmoSound()
				self:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep and wep:IsValid() then
		local primary = wep:ValidPrimaryAmmo()
		if primary and 0 < wep:Clip1() then
			self:GiveAmmo(wep:Clip1(), primary, true)
			wep:SetClip1(0)
		end
		local secondary = wep:ValidSecondaryAmmo()
		if secondary and 0 < wep:Clip2() then
			self:GiveAmmo(wep:Clip2(), secondary, true)
			wep:SetClip2(0)
		end

		self:StripWeapon(weapon:GetClass())
		
		local wep2 = plyr:Give(weapon:GetClass())
		if wep2 and wep2:IsValid() then
			if wep2.Primary then
				local primary = wep2:ValidPrimaryAmmo()
				if primary then
					wep2:SetClip1(0)
					plyr:RemoveAmmo(math.max(0, wep2.Primary.DefaultClip - wep2.Primary.ClipSize), primary)
				end
			end
			if wep2.Secondary then
				local secondary = wep2:ValidSecondaryAmmo()
				if secondary then
					wep2:SetClip2(0)
					plyr:RemoveAmmo(math.max(0, wep2.Secondary.DefaultClip - wep2.Secondary.ClipSize), secondary)
				end
			end
		end
	end
end

function meta:Gib()
	local pos = self:LocalToWorld(self:OBBCenter())

	local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(pos)
	util.Effect("gib_player", effectdata, true, true)

	self.Gibbed = CurTime()

	timer.SimpleEx(0, GAMEMODE.CreateGibs, GAMEMODE, pos, self:LocalToWorld(self:OBBMaxs()).z - pos.z)
end

function meta:GetLastAttacker()
	local ent = self.LastAttacker
	if ent and ent:IsValid() and ent:Team() ~= self:Team() and CurTime() <= self.LastAttacked + 300 then
		return ent
	end
	self:SetLastAttacker()
end

function meta:SetLastAttacker(ent)
	if ent then
		if ent ~= self then
			self.LastAttacker = ent
			self.LastAttacked = CurTime()
		end
	else
		self.LastAttacker = nil
		self.LastAttacked = nil
	end
end

meta.OldUnSpectate = meta.UnSpectate
function meta:UnSpectate()
	if self:GetObserverMode() ~= OBS_MODE_NONE then
		self:OldUnSpectate(obsm)
	end
end
