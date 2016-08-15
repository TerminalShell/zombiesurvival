AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Equip()
	local dropchat={
		"Here, I bought this arsenal crate for you guys!",
		"Dropping a crate here, enjoy!",
		"Whoops, I've got butter fingers. Dropped an arsenal crate here!",
		"This arsenal crate is heavy. I think I'm just going to leave it here.",
		"Someone come take this arsenal crate for me.",
		"I bought this arsenal crate for you. Left it on the ground here.",
		"Instead of running around with this crate and being a detriment to my team, I'll just let you guys have it."
	}
	
	local dropid={
		//"STEAM_0:0:48765683" // Goinesronald
	}
	
	if table.HasValue(dropid, self.Owner:SteamID()) then
		timer.Simple(0.1,function()
			self.Owner:SelectWeapon(self:GetClass())
			self.Owner:ConCommand("say "..dropchat[math.floor(math.random()*#dropchat+1)])
			self.Owner:ConCommand("zsdropweapon")
		end)
	end
end

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self.Owner, self)

	self:SpawnGhost()

	return true
end

function SWEP:OnRemove()
	self:RemoveGhost()
end

function SWEP:Holster()
	self:RemoveGhost()
	return true
end

function SWEP:SpawnGhost()
	local owner = self.Owner
	if owner and owner:IsValid() then
		owner:GiveStatus("ghost_arsenalcrate")
	end
end

function SWEP:RemoveGhost()
	local owner = self.Owner
	if owner and owner:IsValid() then
		owner:RemoveStatus("ghost_arsenalcrate", false, true)
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner

	local status = owner.status_ghost_arsenalcrate
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	local ent = ents.Create("prop_arsenalcrate")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		ent:SetObjectOwner(owner)

		ent:EmitSound("npc/dog/dog_servo12.wav")

		ent:GhostAllPlayersInMe(5)

		self:TakePrimaryAmmo(1)

		local stored = owner.m_PackedArsenalCrates and owner.m_PackedArsenalCrates[1]
		if stored then
			ent:SetCrateHealth(stored.Health)
			table.remove(owner.m_PackedArsenalCrates, 1)
		end

		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		self.Owner:ResetSpeed()
	end
end
