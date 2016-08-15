AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MaxHP = 600
ENT.m_Health = ENT.MaxHP // Health of the shield emitter itself
ENT.FieldHPScale = 1 / 3 // Health of each field panel, as a fraction of the emitter's health

function ENT:Initialize()
	self:SetModel("models/props_lab/lab_flourescentlight002b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	self:SetColor(Color(100, 230, 255, 255))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	
	local c1 = 14
	local r1 = 0
	local r2 = 32
	local r3 = 64
	
	local c2 = 21
	local r4 = 16
	local r5 = 48
	
	self.Field = {}
	self.Field[1] = self:CreateField(r1,c1,false)
	self.Field[2] = self:CreateField(r1,-c1,true)
	self.Field[3] = self:CreateField(r2,c1,false)
	self.Field[4] = self:CreateField(r2,-c1,true)
	self.Field[5] = self:CreateField(r3,c1,false)
	self.Field[6] = self:CreateField(r3,-c1,true)
	self.Field[7] = self:CreateField(r4,c2,true)
	self.Field[8] = self:CreateField(r4,-c2,false)
	self.Field[9] = self:CreateField(r5,c2,true)
	self.Field[10] = self:CreateField(r5,-c2,false)
end

function ENT:CreateField( up, side, flip )
	local ent = ents.Create("prop_forcebarrierfield")
	if ent:IsValid() then
		local yaw = 90
		if flip then yaw = yaw * -1 end
		ent:SetPos(self:GetPos() + self:GetForward() * ( 20 + up ) + self:GetRight() * side)
		ent:SetAngles(Angle(self:GetAngles().p, self:GetAngles().y + yaw, 0))
		ent:SetOwner(self)
		ent:Spawn()
		ent.m_Health = self.m_Health * self.FieldHPScale
		ent.MaxHP = self.MaxHP * self.FieldHPScale
		ent:GhostAllPlayersInMe(5)
		return ent
	end
end

function ENT:FieldBalance()
	if self.Field then
		for k,v in pairs(self.Field) do
			if v:IsValid() then
				v.m_Health = self.m_Health * self.FieldHPScale
			end
		end
	end
end

function ENT:OnRemove()
	if self.Field then
		for k,v in pairs(self.Field) do
			if v:IsValid() then
				v:Remove()
			end
		end
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
				self:RealDamage(dmginfo:GetDamage())
			end
		end
	end
end

function ENT:RealDamage(dmg)
	local col = self:GetColor()
	col.g = math.Min((self.m_Health/self.MaxHP)*255,255)
	col.b = col.g
	self:SetColor(col)
	if self.Field then
		for k,v in pairs(self.Field) do
			if v:IsValid() then
				v.m_Health = v.m_Health - dmg * self.FieldHPScale
				if v.m_Health <= 0 then v.Destroyed = true end
			end
		end
	end
end

function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_forcebarrier")
	pl:GiveAmmo(1, "slam")

	pl.m_PackedForceBarriers = pl.m_PackedForceBarriers or {}
	table.insert(pl.m_PackedForceBarriers, 1, self.m_Health)

	self:Remove()
end

function ENT:Think()
	if self.Destroyed then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		util.Effect("Explosion", effectdata, true, true)
		self:Remove()
	end
end
