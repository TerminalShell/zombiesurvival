AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local oldRenderMode = nil
local oldColor = nil
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/weapons/v_hands.mdl")

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.status_human_holding = self

		owner:DrawWorldModel(false)
		owner:DrawViewModel(false)

		local wep = owner:GetActiveWeapon()
		if wep:IsValid() then
			wep:SendWeaponAnim(ACT_VM_HOLSTER)
			if wep.SetIronsights then
				wep:SetIronsights(false)
			end
		end
	end

	local object = self:GetObject()
	if object:IsValid() then
		for _, ent in pairs(ents.FindByClass("logic_pickupdrop")) do
			if ent.EntityToWatch == object:GetName() and ent:IsValid() then
				ent:Input("onpickedup", owner, object, "")
			end
		end

		oldRenderMode = RENDERMODE_NORMAL
		oldColor = Color(255,255,255,255)
		oldRenderMode = object:GetRenderMode()
		object:SetRenderMode(RENDERMODE_TRANSALPHA)
		oldColor = object:GetColor()
		object:SetColor(Color(oldColor.r, oldColor.g, oldColor.b, 160))
		
		local objectphys = object:GetPhysicsObject()
		if objectphys:IsValid() then
			objectphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			objectphys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)

			if objectphys:GetMass() < CARRY_DRAG_MASS and (object:OBBMins():Length() + object:OBBMaxs():Length() < CARRY_DRAG_VOLUME or object.NoVolumeCarryCheck) then
				objectphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
				object._OriginalMass = objectphys:GetMass()

				objectphys:EnableGravity(false)
				objectphys:SetMass(2)
			else
				self:SetIsHeavy(true)
				self:SetHingePos(object:NearestPoint(self:GetPullPos()))
			end

			object:CollisionRulesChanged()

			if owner:IsValid() then
				owner:SetSpeed(math.max(CARRY_SPEEDLOSS_MINSPEED, 190 - objectphys:GetMass() * CARRY_SPEEDLOSS_PERKG))
			end
		end
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.status_human_holding = nil

		owner:DrawWorldModel(true)
		owner:DrawViewModel(true)

		if owner:Alive() and owner:Team() ~= TEAM_UNDEAD then
			owner:ResetSpeed()

			local wep = owner:GetActiveWeapon()
			if wep:IsValid() then
				wep:SendWeaponAnim(ACT_VM_DRAW)
			end
		end
	end

	local object = self:GetObject()
	if object:IsValid() then
		object:SetRenderMode(oldRenderMode)
		object:SetColor(oldColor)
		local objectphys = object:GetPhysicsObject()
		if objectphys:IsValid() then
			objectphys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			objectphys:ClearGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			objectphys:ClearGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			objectphys:EnableGravity(true)
			if object._OriginalMass then
				objectphys:SetMass(object._OriginalMass)
				object._OriginalMass = nil
			end

			object:CollisionRulesChanged()
			if not self:GetIsHeavy() then
				object:GhostAllPlayersInMe(2.5, true)
			end
		end

		for _, ent in pairs(ents.FindByClass("logic_pickupdrop")) do
			if ent.EntityToWatch == object:GetName() and ent:IsValid() then
				ent:Input("ondropped", owner, object, "")
			end
		end
	end
end

concommand.Add("_zs_rotateang", function(sender, command, arguments)
	local x = tonumber(arguments[1])
	local y = tonumber(arguments[2])

	if x and y then
		sender.InputMouseX = math.Clamp(x * 0.2, -180, 180)
		sender.InputMouseY = math.Clamp(y * 0.2, -180, 180)
	end
end)

local ShadowParams = {secondstoarrive = 0.01, maxangular = 1000, maxangulardamp = 10000, maxspeed = 500, maxspeeddamp = 1000, dampfactor = 0.65, teleportdistance = 0}
function ENT:Think()
	local ct = CurTime()

	local frametime = ct - (self.LastThink or ct)
	self.LastThink = ct

	local object = self:GetObject()
	local owner = self:GetOwner()
	if not object:IsValid() or object:IsNailed() or not owner:IsValid() or not owner:Alive() then
		self:Remove()
		return
	end

	local shootpos = owner:GetShootPos()
	local nearestpoint = object:NearestPoint(shootpos)

	local objectphys = object:GetPhysicsObject()
	if object:GetMoveType() ~= MOVETYPE_VPHYSICS or not objectphys:IsValid() or owner:GetGroundEntity() == object then
		self:Remove()
		return
	end

	if self:GetIsHeavy() then
		if 64 < self:GetHingePos():Distance(self:GetPullPos()) then
			self:Remove()
			return
		end
	elseif 64 < nearestpoint:Distance(shootpos) then
		self:Remove()
		return
	end

	objectphys:Wake()

	if owner:KeyPressed(IN_ATTACK) then
		object:SetPhysicsAttacker(owner)

		self:Remove()
		return
	elseif self:GetIsHeavy() then
		local pullpos = self:GetPullPos()
		local hingepos = self:GetHingePos()
		objectphys:ApplyForceOffset(objectphys:GetMass() * frametime * 450 * (pullpos - hingepos):GetNormalized(), hingepos)
	elseif owner:KeyDown(IN_ATTACK2) and not owner:GetActiveWeapon().NoPropThrowing then
		owner:ConCommand("-attack2")
		objectphys:ApplyForceCenter(objectphys:GetMass() * math.Clamp(1.25 - math.min(1, (object:OBBMins():Length() + object:OBBMaxs():Length()) / CARRY_DRAG_VOLUME), 0.25, 1) * 500 * owner:GetAimVector())
		object:SetPhysicsAttacker(owner)

		self:Remove()
		return
	else
		if not self.ObjectPosition or not owner:KeyDown(IN_SPEED) then
			local obbcenter = object:OBBCenter()
			local objectpos = shootpos + owner:GetAimVector() * 48
			objectpos = objectpos - obbcenter.z * object:GetUp()
			objectpos = objectpos - obbcenter.y * object:GetRight()
			objectpos = objectpos - obbcenter.x * object:GetForward()
			self.ObjectPosition = objectpos
			self.ObjectAngles = object:GetAngles()
		end

		if owner:KeyDown(IN_WALK) and not owner:KeyDown(IN_SPEED) then
			self.ObjectAngles:RotateAroundAxis(owner:EyeAngles():Up(), owner.InputMouseX or 0)
			self.ObjectAngles:RotateAroundAxis(owner:EyeAngles():Right(), owner.InputMouseY or 0)
		end

		ShadowParams.pos = self.ObjectPosition
		ShadowParams.angle = self.ObjectAngles
		ShadowParams.deltatime = frametime
		objectphys:ComputeShadowControl(ShadowParams)
	end

	object:SetPhysicsAttacker(owner)

	self:NextThink(ct)
	return true
end
