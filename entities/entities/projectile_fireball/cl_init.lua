include("shared.lua")

ENT.NextEmit = 0

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
	self.AmbientSound:PlayEx(0.75, 100)
end

function ENT:Think()
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		local c = Color(230, 200, 120, 255)
		dlight.Pos = self:GetPos()
		dlight.r = c.r
		dlight.g = c.g
		dlight.b = c.b
		dlight.Brightness = 0.5
		dlight.Decay = 250 * 5
		dlight.Size = 250
		dlight.DieTime = CurTime() + 1
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Draw()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.01

	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle = emitter:Add("effects/fire_cloud1", pos)
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(16, 48))
	particle:SetDieTime(math.Rand(0.4, 0.6))
	particle:SetColor(255,255,255)
	particle:SetStartAlpha(255)
	particle:SetStartSize(math.Rand(4, 8))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetGravity(Vector(0,0,125))
	particle:SetCollide(true)
	particle:SetAirResistance(12)
	emitter:Finish()
end
