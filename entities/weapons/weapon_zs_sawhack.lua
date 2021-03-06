AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Sawhack"
	SWEP.Description = "The combination of an axe and a sawblade makes for deadly encounters"

	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		/*["base1+"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "ValveBiped.Bip01", rel = "saw", pos = Vector(0, 0, -0.25), angle = Angle(270, 0, 0), size = Vector(0.1, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base1"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "ValveBiped.Bip01", rel = "saw", pos = Vector(0, 0, 0.394), angle = Angle(90, 0, 0), size = Vector(0.1, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },*/
		["saw"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(5.5, 14.5, 0), angle = Angle(0, 0, 0), size = Vector(0.4, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		/*["base1+"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "saw", pos = Vector(0, 0, -0.25), angle = Angle(270, 0, 0), size = Vector(0.1, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base1"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "saw", pos = Vector(0, 0, 0.394), angle = Angle(90, 0, 0), size = Vector(0.1, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },*/
		["saw"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(5.5, 14.5, 0), angle = Angle(0, 0, 0), size = Vector(0.4, 0.4, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.399, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.Spinzaku=5
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props/cs_militia/axe.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.Primary.Delay = 0.45

SWEP.MeleeDamage = 32
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.9
SWEP.MeleeKnockBack = 0

SWEP.WalkSpeed = 180

SWEP.SwingTime = 0.15
SWEP.SwingRotation = Angle(0, -35, -50)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.HoldType = "melee2"
SWEP.SwingHoldType = "melee2"

SWEP.HitDecal = "Manhackcut"
SWEP.HitAnim = ACT_VM_MISSCENTER

SWEP.NoHitSoundFlesh = true

function SWEP:Think()
	if CLIENT then
		self.VElements.saw.angle.yaw=(self.VElements.saw.angle.yaw+self.Spinzaku)%360
		self.WElements.saw.angle.yaw=(self.WElements.saw.angle.yaw+self.Spinzaku)%360
	end
	self.BaseClass.Think(self)
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(75, 80))
end

function SWEP:PlayHitSound()
	self:EmitSound("npc/manhack/grind"..math.random(5)..".wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav")
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitflesh then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(2)
			effectdata:SetScale(1)
		util.Effect("sparks", effectdata)
	end
end
