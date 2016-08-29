AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

if CLIENT then
	function ENT:Initialize()
		self:DrawShadow(false)

		self.AmbientSound = CreateSound(self, "ambient/fire/firebig.wav")
		if player.Blazing then
			self.AmbientSound:PlayEx(0.55, 130)
		end
		if player.Cooling then
			self.AmbientSound:PlayEx(0.40, 100)
		end
		if player.Surging then
			self.AmbientSound:PlayEx(0.75, 100)
		end
		self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 90))

		self.Emitter = ParticleEmitter(self:GetPos())
		self.Emitter:SetNearClip(40, 50)
	end
	
	ENT.NextEmit = 0

	function ENT:OnRemove()
		self.AmbientSound:Stop()
		self.Emitter:Finish()
	end

	function ENT:Think()
		self.Emitter:SetPos(self:GetPos())
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			if player.Blazing then
				local c = Color(230, 200, 120, 255)
			end
			if player.Cooling then
				local c = Color(25, 120, 230, 255)
			end
			if player.Surging then
				local c = Color(100, 230, 100, 255)
			end
			dlight.Pos = self:GetPos()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = 0.5
			dlight.Decay = 500 * 5
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end

	function ENT:Draw()
		if CurTime() < self.NextEmit then return end
		self.NextEmit = CurTime() + 0.01
		local owner = self:GetOwner()
		local speed = owner:GetVelocity()

		if owner:IsValid() then
			-- Head
			local attach = owner:GetAttachment(owner:LookupAttachment("eyes"))
			if not attach then attach = owner:GetAttachment(owner:LookupAttachment("head")) end
			if attach then
				self:SetAngles(attach.Ang)
				local pos = attach.Pos
				self:SetPos(pos)
				local particle = self.Emitter:Add("effects/fire_cloud1", pos + owner:GetAimVector() * -2)
				self:Flame(particle,math.Rand(6, 14),speed)
			end
			-- Body
			local attach = owner:GetAttachment(owner:LookupAttachment("chest"))
			if attach then
				self:SetAngles(attach.Ang)
				local pos = attach.Pos - Vector(0, 0, 10)
				self:SetPos(pos)
				local particle = self.Emitter:Add("effects/fire_cloud1", pos)
				self:Flame(particle,math.Rand(14, 26),speed)
			end
			-- Left Hand
			local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_LH"))
			if attach then
				self:SetAngles(attach.Ang)
				local pos = attach.Pos
				self:SetPos(pos)
				local particle = self.Emitter:Add("effects/fire_cloud1", pos)
				self:Flame(particle,math.Rand(4, 12),speed)
			end
			-- Right Hand
			local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
			if attach then
				self:SetAngles(attach.Ang)
				local pos = attach.Pos
				self:SetPos(pos)
				local particle = self.Emitter:Add("effects/fire_cloud1", pos)
				self:Flame(particle,math.Rand(4, 12),speed)
			end
			-- Feet
			local pos = owner:GetPos() + Vector(0, 0, 15)
			self:SetPos(pos)
			local particle = self.Emitter:Add("effects/fire_cloud1", pos)
			self:Flame(particle,math.Rand(14, 26),speed)
		end
		return
	end
	
	function ENT:Flame(particle, size, speed)
		particle:SetVelocity(speed)
		particle:SetDieTime(math.Rand(0.4, 0.6))
		if player.Blazing then
			particle:SetColor(255,255,255)
		end
		if player.Cooling then
			particle:SetColor(25, 120, 230)
		end
		if player.Surging then
			particle:SetColor(100,230,100)
		end
		particle:SetStartAlpha(255)
		particle:SetStartSize(size)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetGravity(Vector(0,0,125))
		particle:SetCollide(true)
		particle:SetAirResistance(12)
	end
else
	local owner = self:GetOwner()
	if owner or owner:IsValid() or owner:Alive() then self:Remove() end
end