 -- Read the weapon_real_base if you really want to know what each action does

if (CLIENT) then
	SWEP.PrintName 		= "'Handyman' Handgun"
	SWEP.Description = "A very cheap weapon designed for caders as a sidearm."
	SWEP.ViewModelFOV		= 70
	SWEP.Slot 			= 1
	SWEP.SlotPos 		= 1

	SWEP.HUD3DBone = "slide"
	SWEP.HUD3DPos = Vector(3.5, 0, -0.800)
	SWEP.HUD3DAng = Angle(100, 0, 180)

	killicon.AddFont("weapon_real_cs_sg550", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

/*---------------------------------------------------------
Muzzle Effect + Shell Effect
---------------------------------------------------------*/
SWEP.MuzzleEffect			= "rg_muzzle_pistol" -- This is an extra muzzleflash effect
-- Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.ShellEffect			= "rg_shelleject" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models
/*-------------------------------------------------------*/

SWEP.Base 				= "weapon_zs_base"

SWEP.ViewModel = "models/weapons/v_makarov/v_pist_maka.mdl"
SWEP.WorldModel = "models/weapons/w_pist_maka.mdl"
SWEP.Category			= "Handgun"
SWEP.Primary.Sound = Sound("weapons/handy/mak.wav")
SWEP.Primary.Damage 		= 16
SWEP.Primary.Recoil 		= 0.75
SWEP.Primary.NumShots 		= 1
SWEP.ConeMax = 0.07
SWEP.ConeMin = 0.02
SWEP.Primary.ClipSize 		= 8
SWEP.Primary.Delay 		= 0.14
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.data 				= {}
SWEP.Primary.Automatic = false


SWEP.data.semi 			= {}

SWEP.data.auto 			= {}


SWEP.IronSightsPos = Vector(2.599, 0, 1.44)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.WalkSpeed = 200


function SWEP:Reload()

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.15 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false
end
	
end


function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	
	self.Reloadaftershoot = CurTime() + 1
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self:SetDeploySpeed(1)

	return true
end

function SWEP:PlayAttackSound()
	self.Owner:EmitSound("weapons/handy/mak.wav")
end

function SWEP:Precache()
	util.PrecacheSound("weapons/handy/mak.wav")
end

function SWEP:EmitFireSound()
	self:EmitSound("weapons/handy/mak.wav")
end