AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.FireDamage = 5

function ENT:Initialize()
	self.DeathTime = CurTime() + 30

	self:SetModel("models/props/cs_italy/orange.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:SetColor(Color(230, 200, 120, 255))
	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(4)
		phys:SetBuoyancyRatio(0.002)
		phys:EnableMotion(true)
		phys:Wake()
	end
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:Explode(vHitPos, vHitNormal, eHitEntity)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	if eHitEntity:IsValid() then
		if eHitEntity:IsPlayer() and eHitEntity:Team() ~= owner:Team() and eHitEntity:Alive() then
			eHitEntity:TakeDamage(self.FireDamage, owner, self)
			eHitEntity:GiveStatus("blazing",1)
		else
			eHitEntity:TakeDamage(self.FireDamage, owner, self)
		end
	else
		for _, ent in pairs(ents.FindInSphere(vHitPos, 100)) do
			if ((ent:IsPlayer() and ent:Team() ~= owner:Team() and ent:Alive()) or !ent:IsPlayer()) and TrueVisible(vHitPos, ent:NearestPoint(vHitPos)) then
				local dist = vHitPos:Distance(ent:GetPos())
				local damage = math.max(math.ceil(self.FireDamage/2) - math.floor(self.FireDamage/2 * (dist/100)),1)
				ent:TakeDamage(1, owner, self)
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("fireball", effectdata)
	sound.Play("ambient/fire/gascan_ignite1.wav", vHitPos, 75, math.Rand(200, 255), 1)
end

function ENT:PhysicsCollide(data, phys)
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
