include("shared.lua")

ENT.NextGas = 0
ENT.NextSound = 0

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(48, 64)
end

function ENT:OnRemove()
	self.Emitter:Finish()
end

function ENT:Think()
	if self.NextSound <= CurTime() then
		self.NextSound = CurTime() + math.Rand(4, 6)

		if 0 < GAMEMODE:GetWave() and MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN and MySelf:Alive() then
			local mypos = self:GetPos()
			local eyepos = MySelf:EyePos()
			if eyepos:Distance(mypos) <= self:GetRadius() + 128 and TrueVisible(eyepos, mypos) then
				MySelf:EmitSound("ambient/voices/cough"..math.random(4)..".wav")
			end
		end
	end
end

function ENT:Draw()
	local radius = self:GetRadius()

	if CurTime() < self.NextGas then return end
	self.NextGas = CurTime() + math.Rand(0.1, 0.25)

	local particle = self.Emitter:Add("particles/smokey", self:GetPos() + VectorRand():GetNormalized() * math.Rand(8, radius + 32))
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 32))
	particle:SetDieTime(math.Rand(1.2, 2.5))
	particle:SetStartAlpha(math.Rand(115, 145))
	particle:SetEndAlpha(0)
	particle:SetStartSize(8)
	particle:SetEndSize(radius * math.Rand(0.5, 0.7))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-2, 2))
	particle:SetCollide(true)
	particle:SetBounce(0.25)
	particle:SetColor(10, math.Rand(120, 180), 10)
end
