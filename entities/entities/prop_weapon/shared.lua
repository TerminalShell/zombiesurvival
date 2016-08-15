ENT.Type = "anim"
ENT.Base = "prop_baseoutlined"

ENT.NoNails = true

function ENT:Initialize()
	if SERVER then
		self.m_Health = 200

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMaterial("material")
			phys:EnableMotion(true)
			phys:Wake()
		end

		self:ItemCreated()
		
		if self.Special then
			local eid = self:EntIndex()
			local class = self:GetWeaponType()
			timer.Simple(0.1,function() BroadcastLua("if Entity("..eid..") then Entity("..eid.."):SetWeaponType('"..class.."') end") end)
		end
	end
end

function ENT:SetWeaponType(class)
	local weptab = weapons.GetStored(class)
	if weptab then
		if SERVER and weptab.WorldModel then
			self:SetModel(weptab.WorldModel)
		end
		if CLIENT and weptab.WElements then
			self.WElements = weptab.WElements
			self:Anim_Initialize()
		elseif weptab.WElements then
			self.Special=true
		end
	end

	if SERVER then self.m_WeaponClass = class end
end

function ENT:GetWeaponType()
	return self.m_WeaponClass
end

function ENT:HumanHoldable(pl)
	return pl:KeyDown(GAMEMODE.UtilityKey) or (pl:HasWeapon(self:GetWeaponType()) and self:GetClip1() == 0 and self:GetClip2() == 0)
end
