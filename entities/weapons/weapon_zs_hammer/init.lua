AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function SWEP:Reload()
	if CurTime() < self:GetNextPrimaryFire() then return end

	local owner = self.Owner
	if owner:GetBarricadeGhosting() then return end

	local startpos = owner:GetShootPos()
	local ent
	local dist
	local tr = owner:MeleeTrace(self.MeleeRange, self.MeleeSize, owner:GetMeleeFilter())
	local trent = tr.Entity
	if not trent:IsValid() or not trent:IsNailed() then return end

	for _, e in pairs(ents.FindByClass("prop_nail")) do
		if not e.m_PryingOut and e:GetParent() == trent then
			local edist = e:GetActualPos():Distance(tr.HitPos)
			if edist <= 8 and (not dist or edist < dist) then
				ent = e
				dist = edist
			end
		end
	end

	if not ent then return end

	local nailowner = player.GetByUniqueID(ent.OwnerUID)
	if nailowner and nailowner ~= owner and nailowner:Team() == TEAM_HUMAN and not gamemode.Call("PlayerIsAdmin", owner) and not gamemode.Call("CanRemoveOthersNail", owner, nailowner, ent) then return end

	self:SetNextPrimaryFire(CurTime() + 1)

	ent.m_PryingOut = true -- Prevents infinite loops

	if self.Alternate then
		self:SendWeaponAnim(ACT_VM_HITCENTER)
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
	self.Alternate = not self.Alternate

	owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

	owner:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(1,4)..".wav")

	ent:GetParent():RemoveNail(ent, nil, self.Owner)

	if nailowner and nailowner ~= owner and nailowner:Team() == TEAM_HUMAN then
		if not gamemode.Call("PlayerIsAdmin", owner) then
			owner:GivePenalty(30)
			owner:ReflectDamage(20)
		end

		if nailowner:NearestPoint(tr.HitPos):Distance(tr.HitPos) <= 768 and (nailowner:HasWeapon("weapon_zs_hammer") or nailowner:HasWeapon("weapon_zs_electrohammer")) then
			nailowner:GiveAmmo(1, self.Primary.Ammo)
		else
			owner:GiveAmmo(1, self.Primary.Ammo)
		end
	else
		owner:GiveAmmo(1, self.Primary.Ammo)
	end
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() then
		if hitent.HitByHammer and hitent:HitByHammer(self, self.Owner, tr) then
			return
		end

		if hitent:IsNailed() then
			local healstrength = GAMEMODE.NailHealthPerRepair * (self.Owner.HumanRepairMultiplier or 1) * self.HealStrength
			local oldhealth = hitent:GetBarricadeHealth()
			if oldhealth <= 0 or oldhealth >= hitent:GetMaxBarricadeHealth() or hitent:GetBarricadeRepairs() <= 0 then return end

			hitent:SetBarricadeHealth(math.min(hitent:GetMaxBarricadeHealth(), hitent:GetBarricadeHealth() + math.min(hitent:GetBarricadeRepairs(), healstrength)))
			local col = hitent:GetColor()
			col.g = math.Min((hitent:GetBarricadeHealth()/hitent:GetMaxBarricadeHealth())*255,255)
			col.b = col.g
			hitent:SetColor(col)
			local healed = hitent:GetBarricadeHealth() - oldhealth
			hitent:SetBarricadeRepairs(math.max(hitent:GetBarricadeRepairs() - healed, 0))
			self:PlayRepairSound(hitent)
			gamemode.Call("PlayerRepairedObject", self.Owner, hitent, healed, self)

			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetMagnitude(1)
			util.Effect("nailrepaired", effectdata, true, true)

			return true
		end
	end
end

function SWEP:SecondaryAttack()
	if self:GetPrimaryAmmoCount() <= 0 or CurTime() < self:GetNextPrimaryFire() or self.Owner:GetBarricadeGhosting() then return end

	local owner = self.Owner

	if GAMEMODE:IsClassicMode() then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "cant_do_that_in_classic_mode")
		return
	end

	local tr = owner:TraceLine(64, MASK_SOLID, owner:GetMeleeFilter())
	local trent = tr.Entity

	if not trent:IsValid()
	or not util.IsValidPhysicsObject(trent, tr.PhysicsBone)
	or trent:GetMoveType() ~= MOVETYPE_VPHYSICS and not trent:GetNailFrozen()
	or trent.NoNails
	or trent:IsNailed() and (#trent.Nails >= 8
	or trent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)
	or trent:GetMaxHealth() == 1 and trent:Health() == 0 and not trent.TotalHealth
	or not trent:IsNailed() and not trent:GetPhysicsObject():IsMoveable() then return end

	if tr.MatType == MAT_GRATE or tr.MatType == MAT_CLIP then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "impossible")
		return
	end
	if tr.MatType == MAT_GLASS then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "trying_to_put_nails_in_glass")
		return
	end

	if trent:IsValid() then
		for _, nail in pairs(ents.FindByClass("prop_nail")) do
			if nail:GetParent() == trent and nail:GetActualPos():Distance(tr.HitPos) <= 16 then
				owner:PrintMessage(HUD_PRINTCENTER, "Too close to another nail.")
				return
			end
		end

		if trent:GetBarricadeHealth() <= 0 and trent:GetMaxBarricadeHealth() > 0 then
			owner:PrintMessage(HUD_PRINTCENTER, "That obejct is too damaged to be used anymore.")
			return
		end
	end

	local aimvec = owner:GetAimVector()

	local trtwo = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + aimvec * 16, filter = {owner, trent}, mask = MASK_SOLID})

	if trtwo.HitSky then return end

	local ent = trtwo.Entity
	if trtwo.HitWorld
	or ent:IsValid() and util.IsValidPhysicsObject(ent, trtwo.PhysicsBone) and (ent:GetMoveType() == MOVETYPE_VPHYSICS or ent:GetNailFrozen()) and not ent.NoNails and not (not ent:IsNailed() and not ent:GetPhysicsObject():IsMoveable()) and not (ent:GetMaxHealth() == 1 and ent:Health() == 0 and not ent.TotalHealth) then
		if trtwo.MatType == MAT_GRATE or trtwo.MatType == MAT_CLIP then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "impossible")
			return
		end
		if trtwo.MatType == MAT_GLASS then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "trying_to_put_nails_in_glass")
			return
		end

		if ent and ent:IsValid() and (ent.NoNails or ent:IsNailed() and (#ent.Nails >= 8 or ent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)) then return end

		-- NEW
		if ent:GetBarricadeHealth() <= 0 and ent:GetMaxBarricadeHealth() > 0 then
			owner:PrintMessage(HUD_PRINTCENTER, "That object is too damaged to be used anymore.")
			return
		end
		-- NEW

		local cons = constraint.Weld(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone, 0, true)
		if cons ~= nil then
			for _, oldcons in pairs(constraint.FindConstraints(trent, "Weld")) do
				if oldcons.Ent1 == ent or oldcons.Ent2 == ent then
					cons = oldcons.Constraint
					break
				end
			end
		end

		if not cons then return end

		if self.Alternate then
			self:SendWeaponAnim(ACT_VM_HITCENTER)
		else
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
		end
		self.Alternate = not self.Alternate

		owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

		self:SetNextPrimaryFire(CurTime() + 1)
		self:TakePrimaryAmmo(1)

		trent:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".wav")

		local nail = ents.Create("prop_nail")
		if nail:IsValid() then
			nail:SetActualOffset(tr.HitPos, trent)
			nail:SetPos(tr.HitPos - aimvec * 8)
			nail:SetAngles(aimvec:Angle())
			nail:AttachTo(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone)
			nail:Spawn()
			nail:SetDeployer(owner)

			cons:DeleteOnRemove(nail)

			gamemode.Call("OnNailCreated", trent, ent, nail)
		end
	end
end
