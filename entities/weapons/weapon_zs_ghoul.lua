AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Ghoul"
end

SWEP.Base = "weapon_zs_zombiebase"

SWEP.MeleeDamage = 26
SWEP.MeleeForceScale = 0.1
SWEP.SlowDownScale = 2.25

function SWEP:DrawHUD()
	surface.SetFont("ZSHUDFontSmall")
	local nTEXW, nTEXH = surface.GetTextSize("Right Click to Throw Flesh.")

	draw.SimpleText("Left Click to Attack", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 3, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Right Click to Throw Flesh.", "ZSHUDFontSmall", w - nTEXW * 0.5 - 24, h - nTEXH * 2, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end

function SWEP:ApplyMeleeDamage(ent, trace, damage)
	ent:PoisonDamage(damage, self.Owner, self, trace.HitPos)
end

function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

function SWEP:PlayAlertSound()
	self.Owner:EmitSound("npc/fast_zombie/fz_alert_close1.wav", 75, math.Rand(70, 80))
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self.Owner:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
end

local function DoFleshThrow(pl, wep)
	if pl:IsValid() and pl:Alive() and wep:IsValid() then
		pl:ResetSpeed()

		if SERVER then
			local startpos = pl:GetShootPos()
			local aimang = pl:EyeAngles()

			for i=1, 4 do
				local ang = Angle(aimang.p, aimang.y, aimang.r)
				ang:RotateAroundAxis(ang:Up(), math.Rand(-8, 8))
				ang:RotateAroundAxis(ang:Right(), math.Rand(-8, 8))
				local heading = ang:Forward()

				local ent = ents.Create("projectile_poisonflesh")
				if ent:IsValid() then
					ent:SetPos(startpos)
					ent:SetOwner(pl)
					ent:Spawn()
					ent:SetTeamID(pl:Team())
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(heading * math.Rand(320, 380))
					end
				end
			end

			pl:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))
		end

		pl:RawCapLegDamage(CurTime() + 2)
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or IsValid(self.Owner.FeignDeath) then return end

	self:SetNextSecondaryFire(CurTime() + 3)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self.Owner:DoAttackEvent()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))
	self.Owner:RawCapLegDamage(CurTime() + 3)
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	timer.SimpleEx(0.7, DoFleshThrow, self.Owner, self)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
