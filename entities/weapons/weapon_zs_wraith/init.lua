AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.MoanDelay = 3

SWEP.OwnerOffset = Vector(0,0,7)
SWEP.OwnerAngles = Vector(0,0,0)

function SWEP:PreSurge()
	self.Owner:SetWalkSpeed(1)
	self.Owner:SetJumpPower(0)
end

function SWEP:PostSurge()
	self.Owner:SetWalkSpeed(GAMEMODE.ZombieClasses['Wraith'].Speed)
	self.Owner:SetJumpPower(200)
end

function SWEP:Deploy()
	self.Owner:SetColor(Color(254, 254, 254, 255))

	return self.BaseClass.Deploy(self)
end

function SWEP:ChildThink()
	if self.Surging then
		local vStart = self.OwnerOffset + self.Owner:GetPos()
		local tr = {}
		tr.start = vStart
		tr.endpos = vStart + self.OwnerAngles
		tr.filter = self.Owner
		local trace = util.TraceLine(tr)
		local ent = trace.Entity

		if ent and ent:IsValid() then
			if ent:GetClass() == "func_breakable_surf" then
				ent:Fire("break", "", 0)
			else
				local phys = ent:GetPhysicsObject()
				if ent:IsPlayer() then
					local vel = self.Owner:EyeAngles():Forward() * 650
					vel.z = 150
					ent:SetVelocity(vel)
					ent:ViewPunch(Angle(math.random(0, 80), math.random(0, 80), math.random(0, 80)))
					ent:TakeDamage(10, self.Owner)
				elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
					local vel = self.Owner:GetAimVector() * 1000
					phys:ApplyForceOffset(vel, (self.Owner:TraceLine(65).HitPos + ent:GetPos()) / 2)
					ent:SetPhysicsAttacker(self.Owner)
				end
			end
			self.Surging = false
			self.Owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
			self.Owner:ViewPunch(Angle(math.random(0, 70), math.random(0, 70), math.random(0, 70)))
		elseif trace.HitWorld then
			self.Owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
			self.Surging = false
		elseif self.SurgePos and self.SurgePos:Distance(self.Owner:GetPos())>300 then
			timer.Create( "stopflying"..self.Owner:EntIndex(), 0.01, 25, function()
				if(self.Owner and self.Owner:IsValid()) then
					self.Owner:SetLocalVelocity(self.Owner:GetVelocity()*0.9)
				end
			end)
			self.Surging = false
			self.SurgePos = nil
		end
	end
end

function SWEP:DoSurge()
	if !self.Owner or !self.Owner:IsValid() then return end
    if !self.Owner:GetGroundEntity():IsValid() and !self.Owner:GetGroundEntity():IsWorld() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	//self:StartSwinging()
	//self.Owner:SetMoveType(MOVETYPE_WALK)
	timer.Simple(self.SurgeDelay,function()
		if(self.Owner and self.Owner:IsValid()) then
			self.Surging = true
			self.Owner:EmitSound("ambient/machines/slicer4.wav",120,80)
			//self.Owner:EmitSound("npc/antlion/distract1.wav")
			local ang = self.Owner:GetAimVector()
			ang.z = 0
			self.OwnerAngles = ang * 85
			if(self.Owner:GetGroundEntity():IsValid() or self.Owner:GetGroundEntity():IsWorld() or self.Owner:WaterLevel() > 0) then
				self.SurgePos = self.Owner:GetPos()
				self.Owner:SetLocalVelocity(self.Owner:GetForward()*2500)
			end
		end
	end)
end