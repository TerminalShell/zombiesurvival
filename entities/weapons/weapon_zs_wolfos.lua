AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Wolfos' Handgun"
	SWEP.Description = "Automatic handgun. Right click fires a burst of bullets, but reduces fire rate by 60%. Be careful, runs out of ammo quickly!"
	SWEP.Slot = 1
	SWEP.SlotPos = 0

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.45, -0, -3)
	
	SWEP.HUD3DScale = 0.013

SWEP.VElements = {
	["slide"] = { type = "Model", model = "models/items/battery.mdl", bone = "ValveBiped.square", rel = "", pos = Vector(0, 0.55, -5), angle = Angle(0, 90, 0), size = Vector(0.6, 0.492, 1.401), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["secondclip"] = { type = "Model", model = "models/items/boxflares.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(0.2, 1.7, 3.5), angle = Angle(0, 90, 0), size = Vector(0.25, 0.25, 0.25), color = Color(0, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["wslide"] = { type = "Model", model = "models/items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0.8, 1.899, -3.1), angle = Angle(-97, -5, -3), size = Vector(0.5, 0.5, 1.029), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["asd"] = { type = "Model", model = "models/items/boxflares.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11, 2.049, -1), angle = Angle(83, 0, 0), size = Vector(0.30, 0.30, 0.30), color = Color(0, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }

}


end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

SWEP.Primary.Sound = Sound("npc/turret_floor/shoot1.wav")
SWEP.Primary.Damage = 16
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.170

SWEP.Primary.ClipSize = 24
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 0.11
SWEP.ConeMin = 0.06

SWEP.TracerName = "AR2Tracer"

SWEP.ReloadSound = "npc/sniper/reload1.wav"

SWEP.WalkSpeed = 200

SWEP.IronSightsPos=Vector(-6.08, 11, 3)
SWEP.IronSightsAng = Vector(0.15, -1, 1.5)

SWEP.Primary.DefaultNumShots = SWEP.Primary.NumShots
SWEP.Primary.DefaultDelay = SWEP.Primary.Delay
SWEP.Primary.IronsightsDelay = 0.150

function SWEP:SetIronsights(b)
	if self:GetIronsights() ~= b then
		if b then
			self.Primary.Delay = self.Primary.IronsightsDelay

			self:EmitSound("npc/roller/mine/rmine_blades_in1.wav", 30)
		else
			self.Primary.Delay = self.Primary.DefaultDelay

			self:EmitSound("npc/roller/mine/rmine_blades_out1.wav", 30)
		end
	end

	self.BaseClass.SetIronsights(self, b)
end

function SWEP:CanPrimaryAttack()
	if self:GetIronsights() and self:Clip1() == 1 then
		self:SetIronsights(false)
	end

	return self.BaseClass.CanPrimaryAttack(self)
end

util.PrecacheSound("npc/roller/mine/rmine_blades_in1.wav")
util.PrecacheSound("npc/roller/mine/rmine_blades_out1.wav")

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
	util.Effect("hit_supersonic", effectdata)

	GenericBulletCallback(attacker, tr, dmginfo)
end