AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "'Tiny' Slug Rifle"
	SWEP.Description = "This powerful rifle instantly kills any zombie with a head shot."
	SWEP.Slot = 3
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = false
	
	SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
	SWEP.HUD3DPos = Vector(-1.3, -1.1, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

SWEP.UseHands = true

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.Primary.Sound = Sound("Weapon_AWP.Single")
SWEP.Primary.Damage = 135
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.5
SWEP.ReloadDelay = 2.0
SWEP.NoDistanceReduction = true

SWEP.Primary.ClipSize = 2
SWEP.Primary.ClipMultiplier = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 0.12
SWEP.ConeMin = 0.005

SWEP.IronSightsPos = Vector(-7.011, 0, 2.60)
SWEP.IronSightsAng = Vector(0, -0.76, 0)

SWEP.WalkSpeed = 185

SWEP.NextReload = 0
function SWEP:Reload()
	if self.NextReload < CurTime() then
		self.NextReload = CurTime() + self.ReloadDelay

		if self:Clip1() < self.Primary.ClipSize and 0 < self.Owner:GetAmmoCount(self.Primary.Ammo) then
			self:SetNetworkedBool("reloading", true)
			self:DefaultReload(ACT_VM_RELOAD)
			self.Owner:DoReloadEvent()
			timer.SimpleEx(0.50, self.SendWeaponAnim, self, ACT_SHOTGUN_RELOAD_FINISH)
			self:SetNextPrimaryFire(CurTime() + self.ReloadDelay)
		end
	end
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	if tr.HitGroup == HITGROUP_HEAD then
		local ent = tr.Entity
		if ent:IsValid() and ent:IsPlayer() then
			ent.Gibbed = CurTime()
		end

		if gamemode.Call("PlayerShouldTakeDamage", ent, attacker) then
			ent:SetHealth(math.max(ent:Health() - 400, 1))
		end
	end

	GenericBulletCallback(attacker, tr, dmginfo)
end
