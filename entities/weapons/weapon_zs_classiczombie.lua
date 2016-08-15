AddCSLuaFile()

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 30

function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

function SWEP:StartMoaning()
end

function SWEP:StopMoaning()
end

function SWEP:IsMoaning()
	return false
end

SWEP.NextClimbSound = 0
function SWEP:Think()
	local curtime = CurTime()
	local owner = self.Owner

	if self:GetClimbing() then
		if self:GetClimbSurface() and owner:KeyDown(IN_ATTACK2) then
			if SERVER and (owner:KeyDown(IN_FORWARD) or owner:KeyDown(IN_BACK)) and CurTime() >= self.NextClimbSound then
				self.NextClimbSound = CurTime() + 1
				owner:EmitSound("player/footsteps/metalgrate"..math.random(4)..".wav", 75, math.Rand(85, 90))
			end
		else
			self:StopClimbing()
		end
	end

	return self.BaseClass.Think(self)
end

local climblerp = 0
function SWEP:GetViewModelPosition(pos, ang)
	climblerp = math.Approach(climblerp, self:IsClimbing() and 1 or 0, FrameTime() * ((climblerp + 1) ^ 3))
	ang:RotateAroundAxis(ang:Right(), 64 * climblerp)
	if climblerp > 0 then
		pos = pos + -8 * climblerp * ang:Up() + -12 * climblerp * ang:Forward()
	end
	return self.BaseClass.GetViewModelPosition(self, pos, ang)
end

function SWEP:PrimaryAttack()
	if self:IsClimbing() then return end

	self.BaseClass.PrimaryAttack(self)
end

local climbtrace = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-5, -5, -5), maxs = Vector(5, 5, 5)}
function SWEP:GetClimbSurface()
	local owner = self.Owner

	local fwd = owner:SyncAngles():Forward()
	local up = owner:GetUp()
	local pos = owner:GetPos()
	local tr
	for i=-15, owner:OBBMaxs().z, 5 do
		if not tr or not tr.Hit then
			climbtrace.start = pos + up * i
			climbtrace.endpos = climbtrace.start + fwd * 28
			tr = util.TraceHull(climbtrace)
			if tr.Hit and not tr.HitSky then break end
		end
	end

	if tr.Hit and not tr.HitSky then
		climbtrace.start = tr.HitPos + tr.HitNormal
		climbtrace.endpos = climbtrace.start + owner:SyncAngles():Up() * 72
		local tr2 = util.TraceHull(climbtrace)
		if tr2.Hit and not tr2.HitSky then
			return tr2
		end

		return tr
	end
end

function SWEP:SecondaryAttack()
	if self:IsClimbing() then return end

	if not self.Owner:IsOnGround() and self.Owner:GetVelocity():Length() < 200 and self:GetClimbSurface() then
		self:StartClimbing()
	else
		self.BaseClass.SecondaryAttack(self)
	end
end

function SWEP:StartClimbing()
	if self:GetClimbing() then return end

	self:SetClimbing(true)

	self:SetNextPrimaryFire(math.huge)

	if SERVER and not IsValid(self.Owner.status_overridemodel) then
		local ov = self.Owner:GiveStatus("overridemodel")
		if ov and ov:IsValid() then
			ov:SetModel(self.Owner:GetModel())
			self.Owner:SetModel("models/zombie/fast.mdl")
		end
	end
end

function SWEP:StopClimbing()
	if not self:GetClimbing() then return end

	self:SetClimbing(false)

	self:SetNextPrimaryFire(CurTime() + 0.5)

	if SERVER then
		local ov = self.Owner.status_overridemodel
		if ov and ov:IsValid() then
			self.Owner:SetModel(ov:GetModel())
			ov:Remove()
		end
	end
end

function SWEP:Move(mv)
	if self:GetClimbing() then
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)

		local tr = self:GetClimbSurface()
		local dir = tr and tr.Hit and tr.HitNormal.z <= -0.5 and (self.Owner:SyncAngles():Forward() * -1) or self.Owner:GetUp()

		if self.Owner:KeyDown(IN_FORWARD) then
			mv:SetVelocity(dir * 60)
		elseif self.Owner:KeyDown(IN_BACK) then
			mv:SetVelocity(dir * -60)
		else
			mv:SetVelocity(Vector(0, 0, 4))
		end

		return true
	end
end

function SWEP:SetClimbing(climbing)
	self:SetDTBool(1, climbing)
end

function SWEP:GetClimbing()
	return self:GetDTBool(1)
end
SWEP.IsClimbing = SWEP.GetClimbing
