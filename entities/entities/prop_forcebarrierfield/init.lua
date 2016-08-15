AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MaxHP = 200
ENT.m_Health = ENT.MaxHP

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/props_c17/streetsign005b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if not self.Destroyed then
		local attacker = dmginfo:GetAttacker()
		if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
			if attacker.LifeBarricadeDamage ~= nil and self:HumanNearby() then
				attacker.LifeBarricadeDamage = attacker.LifeBarricadeDamage + dmginfo:GetDamage()
			end

			self.m_Health = self.m_Health - dmginfo:GetDamage()
			if self.m_Health <= 0 then
				self.Destroyed = true
			else
				local effectdata = EffectData()
					effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
				util.Effect("cball_bounce", effectdata, true, true)
			end
			local owner = self:GetOwner()
			local updmg = ( owner.MaxHP / self.MaxHP ) / #owner.Field * dmginfo:GetDamage() // Amount by which damaging shield should also damage base
			owner.m_Health = owner.m_Health - updmg
			if owner.m_Health <= 0 then owner.Destroyed = true end
			owner:RealDamage(updmg)
		end
	end
end

function ENT:Think()
	if self.Destroyed then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		util.Effect("cball_explode", effectdata, true, true)
		self:Remove()
	end
end