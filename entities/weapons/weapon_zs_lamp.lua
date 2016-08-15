AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Lamp"
	SWEP.ViewModelFOV = 80
	SWEP.ViewModelFlip = false
		
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false
	SWEP.ViewModelBoneMods = {
		["Dummy14"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "Bip01 R Hand", rel = "", pos = Vector(4.743, -0.638, 8.631), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.837, 1.638, -10), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/V_Stunbaton.mdl"
SWEP.WorldModel = "models/props_interiors/Furniture_Lamp01a.mdl"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.MeleeDamage = 44
SWEP.MeleeRange = 68
SWEP.MeleeSize = 2

SWEP.Primary.Delay = 1

SWEP.WalkSpeed = 210

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.4
SWEP.SwingHoldType = "melee"

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, math.Rand(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_solid_impact_hard"..math.random(4, 5)..".wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end
