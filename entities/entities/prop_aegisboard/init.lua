AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_debris/wood_board05a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:SetMaxBoardHealth(600)
	self:SetBoardHealth(self:GetMaxBoardHealth())
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "maxboardhealth" then
		value = tonumber(value)
		if not value then return end

		self:SetMaxBoardHealth(value)
	elseif key == "boardhealth" then
		value = tonumber(value)
		if not value then return end

		self:SetBoardHealth(value)
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "setboardhealth" then
		self:KeyValue("boardhealth", args)
		return true
	elseif name == "setmaxboardhealth" then
		self:KeyValue("maxboardhealth", args)
		return true
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
		self:SetBoardHealth(self:GetBoardHealth() - dmginfo:GetDamage())
	end
end

function ENT:SetBoardHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			ent:SetModel(self:GetModel())
			ent:SetMaterial(self:GetMaterial())
			ent:SetAngles(self:GetAngles())
			ent:SetPos(self:GetPos())
			ent:SetSkin(self:GetSkin() or 0)
			ent:SetColor(self:GetColor())
			ent:Spawn()
			ent:Fire("break", "", 0)
			ent:Fire("kill", "", 0.1)
		end
	else
		local col = self:GetColor()
		col.g = math.Min((self:GetBoardHealth()/self:GetMaxBoardHealth())*255,255)
		col.b = col.g
		self:SetColor(col)
	end
end

function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_aegis")
	pl:GiveAmmo(1, "SniperRound")

	pl.m_PackedAegis = pl.m_PackedAegis or {}
	table.insert(pl.m_PackedAegis, 1, self:GetBoardHealth())

	self:Remove()
end

function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end
end
