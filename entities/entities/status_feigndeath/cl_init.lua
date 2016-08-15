include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.FeignDeath = self
		owner.NoCollideAll = true

		self.CommandYaw = owner:GetAngles().yaw

		owner:CallWeaponFunction("KnockedDown", self, false)
		owner:CallZombieFunction("KnockedDown", self, false)
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.FeignDeath = nil
		owner.NoCollideAll = owner:Team() == TEAM_UNDEAD and owner:GetZombieClassTable().NoCollideAll
	end
end

function ENT:Draw()
end
