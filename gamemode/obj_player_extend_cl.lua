local meta = FindMetaTable("Player")
if not meta then return end

function meta:FloatingScore(victim, effectname, frags, flags)
	if MySelf == self then
		gamemode.Call("FloatingScore", victim, effectname, frags, flags)
	end
end

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetRenderAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

function meta:RemoveAllStatus(bSilent, bInstant)
end

function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
end

function meta:SplitMessage(message)
	if self == MySelf then
		GAMEMODE:SplitMessage(message)
	end
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent.Owner == self then return ent end
end

function meta:GiveStatus(sType, fDie)
end

if not meta.SetGroundEntity then
	function meta:SetGroundEntity(ent) end
end

if not meta.Kill then
	function meta:Kill() end
end

function meta:SetMaxHealth(num)
	self:SetDTInt(0, math.ceil(num))
end

meta.OldGetMaxHealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	return self:GetDTInt(0)
end

function meta:DoHulls(classid, teamid)
	teamid = teamid or self:Team()

	if teamid == TEAM_UNDEAD then
		self:SetIK(false)

		classid = classid or -10
		local classtab = GAMEMODE.ZombieClasses[classid]
		if classtab then
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

			self.NoCollideAll = classtab.NoCollideAll
			self.AllowTeamDamage = classtab.AllowTeamDamage
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMass(classtab.Mass or DEFAULT_MASS)
			end
		end
	else
		self:SetIK(true)
		self:ResetHull()
		self:SetViewOffset(DEFAULT_VIEW_OFFSET)
		self:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
		self:SetStepSize(DEFAULT_STEP_SIZE)
		self:SetJumpPower(DEFAULT_JUMP_POWER)
		self:SetModelScale(DEFAULT_MODELSCALE, 0)

		self.NoCollideAll = nil
		self.AllowTeamDamage = nil
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(DEFAULT_MASS)
		end
	end
end

function meta:GivePenalty(amount)
	surface.PlaySound("ambient/alarms/klaxon1.wav")
end

function meta:SetZombieClass(cl)
	self:CallZombieFunction("SwitchedAway")

	local classtab = GAMEMODE.ZombieClasses[cl]
	if classtab then
		self.Class = classtab.Index or cl
		self:CallZombieFunction("SwitchedTo")
	end
end

usermessage.Hook("penalty", function(um)
	MySelf:GivePenalty(um:ReadShort())
end)

usermessage.Hook("dohulls", function(um)
	local ent = um:ReadEntity()
	local classid = um:ReadShort()
	local teamid = um:ReadShort()
	if ent:IsValid() then
		ent:DoHulls(classid, teamid)
	end
end)

usermessage.Hook("setzclass", function(um)
	local ent = um:ReadEntity()
	local id = um:ReadShort()

	if ent:IsValid() and ent:IsPlayer() then
		ent:SetZombieClass(id)
	end
end)

usermessage.Hook("floatingscore", function(um)
	local victim = um:ReadEntity()
	local effectname = um:ReadString()
	local frags = um:ReadShort()
	local flags = um:ReadShort()

	if victim and victim:IsValid() then
		MySelf:FloatingScore(victim, effectname, frags, flags)
	end
end)

usermessage.Hook("floatingscore_vec", function(um)
	local pos = um:ReadVector()
	local effectname = um:ReadString()
	local frags = um:ReadShort()
	local flags = um:ReadShort()

	MySelf:FloatingScore(pos, effectname, frags, flags)
end)
