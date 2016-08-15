AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function RefreshCrateOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_resupplybox")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "ResupplyBox.PlayerDisconnected", RefreshCrateOwners)
hook.Add("OnPlayerChangedTeam", "ResupplyBox.OnPlayerChangedTeam", RefreshCrateOwners)

function ENT:Initialize()
	self:SetModel("models/Items/ammocrate_smg1.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetPlaybackRate(1)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetMaxCrateHealth(200)
	self:SetCrateHealth(self:GetMaxCrateHealth())

	local worldhint = ents.Create("point_worldhint")
	if worldhint:IsValid() then
		self.WorldHint = worldhint
		worldhint:SetPos(self:GetPos())
		worldhint:SetParent(self)
		worldhint:Spawn()
		worldhint:SetViewable(TEAM_HUMAN)
		worldhint:SetRange(7680)
		worldhint:SetHint(self:GetMessage())
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "maxcratehealth" then
		value = tonumber(value)
		if not value then return end

		self:SetMaxCrateHealth(value)
	elseif key == "cratehealth" then
		value = tonumber(value)
		if not value then return end

		self:SetCrateHealth(value)
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "setcratehealth" then
		self:KeyValue("cratehealth", args)
		return true
	elseif name == "setmaxcratehealth" then
		self:KeyValue("maxcratehealth", args)
		return true
	end
end

function ENT:SetCrateHealth(health)
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
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetCrateHealth(self:GetCrateHealth() - dmginfo:GetDamage())
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_resupply")
	pl:GiveAmmo(1, "helicoptergun")

	pl.m_PackedResupplyBoxes = pl.m_PackedResupplyBoxes or {}
	table.insert(pl.m_PackedResupplyBoxes, 1, {Health = self:GetCrateHealth()})

	self:Remove()
end

function ENT:Think()
	if self.Destroyed then
		self:Remove()
	elseif self.Close and CurTime() >= self.Close then
		self.Close = nil
		self:ResetSequence("open")
		self:EmitSound("items/ammocrate_close.wav")
	end
end

local NextUse = {}
function ENT:Use(activator, caller)
	if activator:Team() ~= TEAM_HUMAN or not activator:Alive() or GAMEMODE:GetWave() <= 0 then return end

	if not self:GetObjectOwner():IsValid() then
		self:SetObjectOwner(activator)
	end

	local owner = self:GetObjectOwner()
	local owneruid = owner:IsValid() and owner:UniqueID() or "nobody"
	local myuid = activator:UniqueID()

	if CurTime() < (NextUse[myuid] or 0) then
		activator:SplitMessage("There's no ammo here right now.")
		return
	end

	local ammotype
	local wep = activator:GetActiveWeapon()
	if not wep:IsValid() then
		ammotype = "pistol"
	end

	if not ammotype then
		ammotype = wep:GetPrimaryAmmoTypeString()
		if not GAMEMODE.AmmoResupply[ammotype] then
			ammotype = "pistol"
		end
	end

	NextUse[myuid] = CurTime() + 30

	umsg.Start("NextResupplyUse", activator)
		umsg.Float(NextUse[myuid])
	umsg.End()

	activator:GiveAmmo(GAMEMODE.AmmoResupply[ammotype], ammotype)
	if activator ~= owner and owner:IsValid() and owner:IsPlayer() and owner:Team() == TEAM_HUMAN then
		owner.ResupplyBoxUsedByOthers = owner.ResupplyBoxUsedByOthers + 1

		owner:AddPoints(1)
		umsg.Start("ReceivedCommission", owner)
			umsg.Entity(self)
			umsg.Entity(activator)
			umsg.Short(1)
		umsg.End()
	end

	if not self.Close then
		self:ResetSequence("close")
		self:EmitSound("items/ammocrate_open.wav")
	end
	self.Close = CurTime() + 3
end

function ENT:SetMessageID(id)
	self:SetDTInt(0, id)
	self.WorldHint:SetHint(self:GetMessage())
end