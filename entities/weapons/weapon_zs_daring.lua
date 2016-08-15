
SWEP.Base 				= "weapon_zs_base"

SWEP.PrintName = "'Daring' Derringer"
SWEP.Description = "A very cheap weapon designed for caders as a sidearm. Deadly at very close range."
SWEP.Slot 			= 1
SWEP.SlotPos 		= 1
SWEP.ViewModelFOV			= 55
SWEP.ViewModelFlip		= false
SWEP.ViewModel 			= "models/weapons/v_daring/v_deringer.mdl"
SWEP.WorldModel 			= "models/weapons/w_deringer.mdl"

	SWEP.HUD3DBone = "weapon"
	SWEP.HUD3DPos = Vector(0.6, -0.5, 0.9)
	SWEP.HUD3DAng = Angle(-180, 0, 0)

SWEP.Primary.Sound 		= Sound("weapons/daring/daring.wav")
SWEP.Primary.Recoil		= 1
SWEP.Primary.Damage		= 14
SWEP.Primary.NumShots		= 4
SWEP.ConeMax = 0.14
SWEP.ConeMin = 0.105
SWEP.Primary.Delay 		= 0.7

SWEP.Primary.ClipSize		= 2					// Size of a clip
SWEP.Primary.DefaultClip	= 2					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

SWEP.ShellDelay			= 0

SWEP.IronSightsPos 		= Vector (-5.8429, 0, 2.2437)
SWEP.IronSightsAng 		= Vector (4.03, 0.0373, 0)
SWEP.RunArmOffset 		= Vector (-0.22, 0, 7.1964)
SWEP.RunArmAngle 		= Vector (-22.7972, 0.5712, 0)

SWEP.WalkSpeed = 200
GAMEMODE:SetupDefaultClip(SWEP.Primary)


function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )

	self:SetDeploySpeed(1)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:Precache()
   Desc: Use this function to precache stuff.
---------------------------------------------------------*/
function SWEP:Precache()

    	util.PrecacheSound("weapons/daring/daring.wav")

end

/*---------------------------------------------------------
   Name: SWEP:ReloadAnimation()
---------------------------------------------------------*/
function SWEP:ReloadAnimation()

	self.Weapon:DefaultReload(ACT_VM_RELOAD)

	timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
		if not IsFirstTimePredicted() then return end

		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP)

		self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())

		if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
			self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
		end
	end)
end

/*---------------------------------------------------------
   Name: SWEP:ShootAnimation()
---------------------------------------------------------*/
function SWEP:ShootAnimation()

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
		self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration() + 0.5)
	end

	if (self.Weapon:Clip1() > 0) then
		timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
			if not IsFirstTimePredicted() then return end

			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP)

			self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())

			if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
				self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
			end
		end)
	end
end