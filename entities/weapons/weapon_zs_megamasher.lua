AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Mega Masher"
	SWEP.ViewModelFOV = 75

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_wasteland/buoy01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, 1.8, -25), angle = Angle(0, 90, 270), size = Vector(0.2, 0.2, 0.14), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		/*["base"] = { type = "Model", model = "models/props_junk/iBeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.706, 2.761, -22), angle = Angle(13, -12.5, 0), size = Vector(0.15, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },*/
		["barrel"] = { type = "Model", model = "models/props_c17/oildrum001_explosive.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 3), angle = Angle(0, -90, 0), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_wasteland/buoy01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, 1.8, -35.5), angle = Angle(0, 90, 270), size = Vector(0.2, 0.2, 0.14), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		/*["base"] = { type = "Model", model = "models/props_junk/iBeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.706, 2.761, -22), angle = Angle(13, -12.5, 0), size = Vector(0.15, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },*/
		["barrel"] = { type = "Model", model = "models/props_c17/oildrum001_explosive.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 3), angle = Angle(0, -90, 3), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/v_sledgehammer/v_sledgehammer.mdl"
SWEP.WorldModel = "models/weapons/w_sledgehammer.mdl"

SWEP.MeleeDamage = 180
SWEP.MeleeRange = 75
SWEP.MeleeSize = 4
SWEP.MeleeKnockBack = SWEP.MeleeDamage * 2

SWEP.Primary.Delay = 2.25

SWEP.WalkSpeed = 150

SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 1.33
SWEP.SwingHoldType = "melee"

SWEP.Deployed = 0

function SWEP:Deploy()
	if CLIENT then
		self.Deployed = 1
		self:DeployPos()
		timer.Create("mm_deploy"..self:EntIndex(),0.05,20,function() self:DeployTime() end)
	end
	self.BaseClass.Deploy(self)
end

function SWEP:DeployTime()
	if CLIENT and self.Deployed > 0 then
		self.Deployed=self.Deployed-0.05
		self:DeployPos()
	end
end

function SWEP:DeployPos()
	local move = self.Deployed * 9.5
	self.VElements.base.pos.x = 15 - move
	self.WElements.base.pos.x = 15 - move
	self.VElements.barrel.pos.z = -move + 3
	self.WElements.barrel.pos.z = -move + 3
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(20, 25))
end

function SWEP:PlayHitSound()
	self:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(4)..".wav", 80, math.Rand(95, 105))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 80, math.Rand(90, 100))
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
	util.Effect("explosion", effectdata)
	if CLIENT then
		self.Deployed = 1
		self:DeployPos()
		timer.Create("mm_deploy"..self:EntIndex(),0.05,20,function() self:DeployTime() end)
	end
end
