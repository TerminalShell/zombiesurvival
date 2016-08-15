include("shared.lua")

ENT.AnimTime = 0.25

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner == MySelf then
		if self.Rotating then
			hook.Remove("CreateMove", "HoldingCreateMove")
		end

		local wep = owner:GetActiveWeapon()
		if wep:IsValid() then
			if wep.NoHolsterOnCarry then
				self.NoHolster = true
			else
				wep:SendWeaponAnim(ACT_VM_DRAW)
			end
		end
	end

	self.BaseClass.OnRemove(self)
end

function ENT:Initialize()
	self.Created = CurTime()

	if not self.NoHolster then
		local owner = self:GetOwner()
		if owner == MySelf then
			local wep = owner:GetActiveWeapon()
			if wep:IsValid() then
				wep:SendWeaponAnim(ACT_VM_HOLSTER)
			end
		end
	end

	self.BaseClass.Initialize(self)
end

function ENT:Think()
	if not self.NoHolster then
		self:SetSequence(0)
		self:SetCycle(0.68 + math.sin(CurTime() * math.pi) * 0.01)
	end

	self.BaseClass.Think(self)
end

function ENT:Draw()
	if self:GetOwner() ~= MySelf or self.NoHolster or MySelf:ShouldDrawLocalPlayer() then return end

	local pos = EyePos()
	local ang = EyeAngles()

	pos = pos + ang:Forward() * -16 + -16 * (1 - math.Clamp((CurTime() - self.Created) / self.AnimTime, 0, 1) ^ 0.5) * ang:Up()

	self:SetPos(pos)
	self:SetAngles(ang)
	self:DrawModel()
end
