SWEP.Base = "weapon_zs_zombiebase"

SWEP.MeleeDelay = 0.5
SWEP.MeleeReach = 48
SWEP.MeleeSize = 1.5
SWEP.MeleeDamage = 40
SWEP.MeleeDamageType = DMG_SLASH

SWEP.AlertDelay = 6

SWEP.Primary.Delay = 2

SWEP.Surging = false
SWEP.SurgeDelay = 0.5
SWEP.SurgeDuration = 1.4

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

function SWEP:Initialize()
	self:HideWorldModel()
end

function SWEP:Precache()
	util.PrecacheSound("npc/antlion/distract1.wav")
	util.PrecacheSound("ambient/machines/slicer1.wav")
	util.PrecacheSound("ambient/machines/slicer2.wav")
	util.PrecacheSound("ambient/machines/slicer3.wav")
	util.PrecacheSound("ambient/machines/slicer4.wav")
	util.PrecacheSound("npc/zombie/claw_miss1.wav")
	util.PrecacheSound("npc/zombie/claw_miss2.wav")
end

function SWEP:StopMoaningSound()
end

function SWEP:StartMoaningSound()
	self.Owner:EmitSound("zombiesurvival/wraithdeath"..math.random(1, 4)..".wav")
end

function SWEP:PlayHitSound()
	self.Owner:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 90, 80)
end

function SWEP:PlayMissSound()
	self.Owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 90, 80)
end

function SWEP:PlayAttackSound()
	self.Owner:EmitSound("npc/antlion/distract1.wav")
end

function SWEP:Swung()
	self.Owner:SetMoveType(MOVETYPE_WALK)

	self.BaseClass.Swung(self)
end

function SWEP:StartSwinging()
	self.Owner:SetMoveType(MOVETYPE_NONE)

	self.BaseClass.StartSwinging(self)
end

local function viewpunch(ent, power)
	if ent:IsValid() and ent:Alive() then
		ent:ViewPunch(Angle(math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1), math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1), math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1)) * power)
	end
end

function SWEP:DoAlert()
	local owner = self.Owner
	
	if SERVER then 
		self:PreSurge()
		self:DoSurge() 
	end
	timer.SimpleEx(self.SurgeDuration, function()
		self.Surging = false
		if SERVER then self:PostSurge() end
	end)

	//owner:EmitSound("npc/antlion/distract1.wav")
	owner:EmitSound("npc/stalker/go_alert2a.wav")
	//owner:ViewPunch(Angle(-20, 0, math.Rand(-10, 10)))

	owner:LagCompensation(true)

	local mouthpos = owner:EyePos() + owner:GetUp() * -3
	local screampos = mouthpos + owner:GetAimVector() * 16
	for _, ent in pairs(ents.FindInSphere(screampos, 200)) do
		if ent:IsPlayer() and ent:Team() ~= owner:Team() then
			local entearpos = ent:EyePos()
			local dist = screampos:Distance(entearpos)
			if dist <= 200 and TrueVisible(entearpos, screampos) then
				local power = math.Min(200/math.Max(1,dist),10) * 5
				ent:ViewPunch(Angle(math.random(0, power), math.random(0, power), math.random(0, power)))
				/*for i=1, 5 do
					timer.SimpleEx(0.15 * i, viewpunch, ent, power - i * 0.125)
				end*/
			end
		end
	end

	owner:LagCompensation(false)
end
