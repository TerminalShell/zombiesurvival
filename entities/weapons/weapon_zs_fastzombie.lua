AddCSLuaFile()

SWEP.Base = "weapon_zs_zombiebase"

if CLIENT then
	SWEP.PrintName = "Fast Zombie"
end

SWEP.ViewModel = Model("models/weapons/v_fza.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

if CLIENT then
	SWEP.ViewModelFOV = 70
end

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to Lunge.")

	draw.SimpleText("Left Click to Attack.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to Lunge.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end

SWEP.MeleeDelay = 0
SWEP.MeleeReach = 42
SWEP.MeleeDamage = 4
SWEP.MeleeForceScale = 0.1
SWEP.MeleeSize = 1.5
SWEP.MeleeDamageType = DMG_SLASH
SWEP.Primary.Delay = 0.32

SWEP.PounceDamage = 2
SWEP.PounceDamageType = DMG_IMPACT
SWEP.PounceReach = 32
SWEP.PounceSize = 16
SWEP.PounceStartDelay = 0.5
SWEP.PounceDelay = 2
SWEP.PounceKnockback = 40
SWEP.PounceKnockbackMin = 30

SWEP.Secondary.Automatic = false

SWEP.NextClimbSound = 0
function SWEP:Think()
	self.BaseClass.Think(self)

	local curtime = CurTime()
	local owner = self.Owner

	if self.NextAllowJump and self.NextAllowJump <= curtime then
		self.NextAllowJump = nil

		owner:ResetJumpPower()
	end

	if self:GetClimbing() then
		if self:GetClimbSurface() and owner:KeyDown(IN_ATTACK2) then
			if SERVER and (owner:KeyDown(IN_FORWARD) or owner:KeyDown(IN_BACK)) and CurTime() >= self.NextClimbSound then
				self.NextClimbSound = CurTime() + 0.25
				owner:EmitSound("player/footsteps/metalgrate"..math.random(4)..".wav")
			end
		else
			self:StopClimbing()
		end
	elseif self:GetSwinging() then
		if not owner:KeyDown(IN_ATTACK) and self.SwingStop and self.SwingStop <= curtime then
			self:SetSwinging(false)
			self.SwingStop = nil

			self.RoarCheck = curtime + 0.1

			self:StopSwingingSound()
			owner:ResetSpeed()
		end
	elseif self.RoarCheck then
		if self.RoarCheck <= curtime then
			self.RoarCheck = nil

			if owner:GetVelocity():Length2D() <= 0.5 and owner:IsOnGround() then
				self:SetRoarEndTime(CurTime() + 1.6)
				if SERVER then
					owner:EmitSound("NPC_FastZombie.Frenzy")
				end
			end
		end
	elseif self:GetPouncing() then
		if owner:IsOnGround() then
			self:StopPounce()
		else
			owner:LagCompensation(true)

			local hit = false
			local traces = owner:PenetratingMeleeTrace(self.PounceReach, self.PounceSize, nil, owner:LocalToWorld(owner:OBBCenter()))
			local damage = self:GetDamage(self:GetTracesNumPlayers(traces), self.PounceDamage)

			for _, trace in ipairs(traces) do
				if not trace.Hit then continue end

				hit = true

				if trace.HitWorld then
					self:MeleeHitWorld(trace)
				else
					local ent = trace.Entity
					if ent and ent:IsValid() then
						local temp = owner:GetVelocity()
						temp.z = 0
						self:MeleeHit(ent, trace, damage, math.Max(temp:Length()/700*self.PounceKnockback, self.PounceKnockbackMin))
					end
				end
			end

			if SERVER and hit then
				owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
				owner:EmitSound("npc/fast_zombie/wake1.wav")
			end

			owner:LagCompensation(false)

			if hit then
				self:StopPounce()
			end
		end
	elseif self:GetPounceTime() > 0 and CurTime() >= self:GetPounceTime() then
		self:StartPounce()
	end

	self:NextThink(CurTime())
	return true
end

function SWEP:MeleeHitEntity(ent, trace, damage, forcescale)
	self.BaseClass.MeleeHitEntity(self, ent, trace, damage, forcescale ~= nil and forcescale * 0.25)
end

local climblerp = 0
function SWEP:GetViewModelPosition(pos, ang)
	climblerp = math.Approach(climblerp, self:IsClimbing() and 1 or 0, FrameTime() * ((climblerp + 1) ^ 3))
	ang:RotateAroundAxis(ang:Right(), 64 * climblerp)
	if climblerp > 0 then
		pos = pos + -8 * climblerp * ang:Up() + -12 * climblerp * ang:Forward()
	end
	return pos, ang
end

function SWEP:Swung()
	self.SwingStop = CurTime() + 0.5

	if not self:GetSwinging() then
		self:SetSwinging(true)

		--self.Owner:SetSpeed(90)
		self:StartSwingingSound()
	end

	self.BaseClass.Swung(self)
end

function SWEP:PrimaryAttack()
	if self:IsPouncing() or self:GetPounceTime() > 0 or self:IsClimbing() then return end

	self.BaseClass.PrimaryAttack(self)
end

local climbtrace = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
function SWEP:GetClimbSurface()
	local owner = self.Owner
	climbtrace.start = owner:GetPos() + owner:GetUp() * 8
	climbtrace.endpos = climbtrace.start + owner:SyncAngles():Forward() * 24
	local tr = util.TraceHull(climbtrace)
	if tr.Hit and not tr.HitSky then
		return tr
	end
end

function SWEP:SecondaryAttack()
	if self:IsPouncing() or self:IsClimbing() or self:GetPounceTime() > 0 then return end

	if self.Owner:IsOnGround() then
		if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() then return end

		self:SetNextPrimaryFire(math.huge)
		self:SetPounceTime(CurTime() + self.PounceStartDelay)

		self.Owner:ResetJumpPower()
		if SERVER then
			self.Owner:EmitSound("npc/fast_zombie/leap1.wav")
		end
	elseif self:GetClimbSurface() then
		self:StartClimbing()
	end
end

function SWEP:StartClimbing()
	if self:GetClimbing() then return end

	self:SetClimbing(true)

	self:SetNextPrimaryFire(math.huge)
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:StopClimbing()
	if not self:GetClimbing() then return end

	self:SetClimbing(false)

	self:SetNextPrimaryFire(CurTime() + 0.25)
	self:SetNextSecondaryFire(CurTime() + 0.25)
end

function SWEP:StartPounce()
	if self:IsPouncing() then return end

	self:SetPounceTime(0)

	local owner = self.Owner
	if owner:IsOnGround() then
		self:SetPouncing(true)

		self.m_ViewAngles = owner:EyeAngles()

		local vel = owner:GetAimVector()
		vel.z = math.max(0.25, vel.z)

		if SERVER then
			owner:EmitSound("NPC_FastZombie.Scream")
		end

		owner:SetGroundEntity(NULL)
		owner:SetLocalVelocity((350 + 500 * (1 - (owner:GetLegDamage() / GAMEMODE.MaxLegDamage))) * vel:GetNormalized())
		owner:SetAnimation(PLAYER_JUMP)
	end
end

function SWEP:StopPounce()
	if not self:IsPouncing() then return end

	self:SetPouncing(false)
	self:SetNextSecondaryFire(CurTime() + self.PounceDelay)
	self.m_ViewAngles = nil
	self.NextAllowJump = CurTime() + 0.25
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self.Owner:ResetJumpPower()
end

function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

function SWEP:OnRemove()
	self.Removing = true

	local owner = self.Owner
	if owner and owner:IsValid() then
		self:StopSwingingSound()
		owner:ResetJumpPower()
	end

	self.BaseClass.OnRemove(self)
end

function SWEP:Holster()
	local owner = self.Owner
	if owner and owner:IsValid() then
		self:StopSwingingSound()
		owner:ResetJumpPower()
	end

	self.BaseClass.Holster(self)
end

function SWEP:ResetJumpPower(power)
	if self.Removing then return end

	if self.NextAllowJump and CurTime() < self.NextAllowJump or self:IsPouncing() or self:GetPounceTime() > 0 then
		return 1
	end
end

function SWEP:StartMoaning()
end

function SWEP:StopMoaning()
end

function SWEP:StartMoaningSound()
end

function SWEP:PlayHitSound()
	self.Owner:EmitSound("NPC_FastZombie.AttackHit")
end

function SWEP:PlayMissSound()
	self.Owner:EmitSound("NPC_FastZombie.AttackMiss")
end

function SWEP:PlayAttackSound()
end

function SWEP:PlayIdleSound()
	self.Owner:EmitSound("NPC_FastZombie.AlertFar")
	self:SetRoarEndTime(CurTime() + 1.6)
end

function SWEP:PlayAlertSound()
	self.Owner:EmitSound("NPC_FastZombie.Frenzy")
	self:SetRoarEndTime(CurTime() + 1.6)
end

function SWEP:StartSwingingSound()
	self.Owner:EmitSound("NPC_FastZombie.Gurgle")
end

function SWEP:StopSwingingSound()
	self.Owner:StopSound("NPC_FastZombie.Gurgle")
end

function SWEP:IsMoaning()
	return false
end

function SWEP:Move(mv)
	if self:IsPouncing() or self:GetPounceTime() > 0 then
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)
	elseif self:GetClimbing() then
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)

		if self.Owner:KeyDown(IN_FORWARD) then
			mv:SetVelocity(Vector(0, 0, 160))
		elseif self.Owner:KeyDown(IN_BACK) then
			mv:SetVelocity(Vector(0, 0, -160))
		else
			mv:SetVelocity(Vector(0, 0, 4))
		end
	end
end

function SWEP:SetRoarEndTime(time)
	self:SetDTFloat(1, time)
end

function SWEP:GetRoarEndTime()
	return self:GetDTFloat(1)
end

function SWEP:IsRoaring()
	return CurTime() < self:GetRoarEndTime()
end

function SWEP:SetPounceTime(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetPounceTime()
	return self:GetDTFloat(2)
end

function SWEP:SetPounceTime(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetPounceTime()
	return self:GetDTFloat(2)
end

function SWEP:SetClimbing(climbing)
	self:SetDTBool(1, climbing)
end

function SWEP:GetClimbing()
	return self:GetDTBool(1)
end
SWEP.IsClimbing = SWEP.GetClimbing

function SWEP:SetSwinging(swinging)
	self:SetDTBool(2, swinging)
end

function SWEP:GetSwinging()
	return self:GetDTBool(2)
end

function SWEP:SetPouncing(leaping)
	self:SetDTBool(3, leaping)
end

function SWEP:GetPouncing()
	return self:GetDTBool(3)
end
SWEP.IsPouncing = SWEP.GetPouncing

if not SERVER then return end

function SWEP:Deploy()
	self.Owner:CreateAmbience("fastzombieambience")

	return self.BaseClass.Deploy(self)
end
