AddCSLuaFile()

SWEP.Base = "weapon_zs_zombie"

if CLIENT then
	SWEP.PrintName = "Blaze Cadaver"
end

SWEP.ViewModel = Model("models/Weapons/v_zombiearms.mdl")

SWEP.Primary.Delay = 3
SWEP.NextThrow = 0

SWEP.Secondary.Delay = 1
SWEP.Secondary.Automatic = true
SWEP.NextSurge = 0
SWEP.Surging = false

SWEP.FireDamage = 10
SWEP.CoolDamage = 6
SWEP.SurgeDamage = 1
SWEP.FireRange = 125

SWEP.NextFlame = 0
SWEP.SurgeTime = 0

SWEP.Wet = false

function SWEP:Reload()
	return false
end

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to Throw Fire.")

	draw.SimpleText("Left Click to Throw Fire.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to Surge.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end

function SWEP:Think()
	if SERVER then
--[[		if self.Surging then
			if self.SurgePos and self.SurgePos:Distance(self.Owner:GetPos())>350 then
				timer.Create( "stopflying"..self.Owner:EntIndex(), 0.01, 25, function()
					if(self.Owner and self.Owner:IsValid()) then
						self.Owner:SetLocalVelocity(self.Owner:GetVelocity()*0.9)
					end
				end)
				self.Surging = false
				self.SurgePos = nil
			end
		end]]
		if self.NextFlame <= CurTime() then
			self.NextFlame = CurTime() + 1
			if self.Owner:WaterLevel() >= 1 then
				self.Owner:TakeDamage(15 * self.Owner:WaterLevel(), self.Owner, self)
				self.Wet = true
			else
				self.Wet = false
			end

			if self.Owner:WaterLevel() <= 1 then		
				-- Blazing
				if self.SurgeTime < CurTime() then
					self.Owner:player.Blazing
					self.Owner:SetWalkSpeed(180)
					local damage = math.max(self.FireDamage - math.floor(self.FireDamage * (dist/self.FireRange)),1)
				end
				-- Cooling
				if self.SurgeTime >= CurTime() and self.SurgeTime < CurTime() + 5 then
					self.Owner:player.Cooling
					self.Owner:SetWalkSpeed(205)
					local damage = math.max(self.CoolDamage - math.floor(self.CoolDamage * (dist/self.FireRange)),1)
				end
				-- Surging
				if self.SurgeTime >= CurTime() and self.SurgeTime < CurTime() + 5 then
					self.Owner:player.Surging
					self.Owner:SetWalkSpeed(220)
					local damage = math.max(self.SurgeDamage - math.floor(self.SurgeDamage * (dist/self.FireRange)),1)
				end
			
				local origin = self.Owner:LocalToWorld(self.Owner:OBBCenter())
				self.Owner:GiveStatus('blazing',1)
				for _, ent in pairs(ents.FindInSphere(origin, self.FireRange)) do
					if ent:IsPlayer() and ent:Team() ~= self.Owner:Team() and ent:Alive() and TrueVisible(origin, ent:NearestPoint(origin)) then
						local dist = origin:Distance(ent:GetPos())
						ent:TakeDamage(damage, self.Owner, self)
						ent:GiveStatus('blazing',math.min(damage * 0.25, 1))
					end
				end
			end
		end
	end
	return self.BaseClass.Think(self)
end

function SWEP:PrimaryAttack()
	if self.NextThrow > CurTime() or self.Wet then return end
	self.NextThrow = CurTime() + self.Primary.Delay
	self:EmitSound("ambient/fire/mtov_flame2.wav", 100, 100)
	self:StartSwinging()
	//self.BaseClass.PrimaryAttack(self)
end

function SWEP:Swung()
	self.Owner:LagCompensation(true)

	if self.Owner:GetStatus('blazing',1) then
		local ent = ents.Create("projectile_fireball")
		if ent:IsValid() then
			ent:SetOwner(self.Owner)
			local aimvec = self.Owner:GetAimVector()
			aimvec.z = math.max(aimvec.z, -0.25)
			aimvec:Normalize()
			local vStart = self.Owner:GetShootPos()
			local tr = util.TraceLine({start=vStart, endpos=vStart + self.Owner:GetAimVector() * 30, filter=self.Owner})
			if tr.Hit then
				ent:SetPos(tr.HitPos + tr.HitNormal * 4)
			else
				ent:SetPos(tr.HitPos)
			end
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(aimvec * 700)
			end
		end
	end

	self:PlayMissSound()
	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	if self.NextSurge > CurTime() or self.Wet then return end
    if !self.Owner:GetGroundEntity():IsValid() and !self.Owner:GetGroundEntity():IsWorld() then return end
	self.NextSurge = CurTime() + self.Secondary.Delay
	if self.SurgeTime >= CurTime() + 5 or self.SurgeTime < CurTime() then
		self.SurgeTime = CurTime() + 7
	end

	self:EmitSound("ambient/fire/gascan_ignite1.wav", 150, 150)
	end
	//self.BaseClass.SecondaryAttack(self)
end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/Charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

function SWEP:PlayHitSound()
	return false
end

/*function SWEP:PlayMissSound()
	self.Owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav")
end*/

function SWEP:PlayAttackSound()
	return false
end

function SWEP:StartMoaning()
	return false
end

function SWEP:StopMoaning()
	return false
end

function SWEP:IsMoaning()
	return false
end