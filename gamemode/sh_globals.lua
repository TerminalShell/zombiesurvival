TEAM_ZOMBIE = 3
TEAM_UNDEAD = TEAM_ZOMBIE
TEAM_ZOMBIES = TEAM_ZOMBIE
TEAM_SURVIVORS = 4
TEAM_HUMAN = TEAM_SURVIVORS
TEAM_HUMANS = TEAM_HUMAN
TEAM_SPECTATE = 1

DISMEMBER_HEAD = 1
DISMEMBER_LEFTARM = 2
DISMEMBER_RIGHTARM = 4
DISMEMBER_LEFTLEG = 8
DISMEMBER_RIGHTLEG = 16

HM_MOSTZOMBIESKILLED = 1
HM_MOSTDAMAGETOUNDEAD = 2
HM_PACIFIST = 3
HM_MOSTHELPFUL = 4
HM_LASTHUMAN = 5
HM_OUTLANDER = 6
HM_GOODDOCTOR = 7
HM_HANDYMAN = 8
HM_SCARECROW = 9
HM_MOSTBRAINSEATEN = 10
HM_MOSTDAMAGETOHUMANS = 11
HM_LASTBITE = 12
HM_USEFULTOOPPOSITE = 13
HM_STUPID = 14
HM_SALESMAN = 15
HM_WAREHOUSE = 16
HM_BARRICADEDESTROYER = 17
HM_SPAWNPOINT = 18
HM_CROWFIGHTER = 19
HM_CROWBARRICADEDAMAGE = 20

FM_NONE = 0
FM_LOCALKILLOTHERASSIST = 1
FM_LOCALASSISTOTHERKILL = 2

DIR_FORWARD = 0
DIR_RIGHT = 1
DIR_BACK = 2
DIR_LEFT = 3

DEFAULT_VIEW_OFFSET = Vector(0, 0, 64)
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0, 0, 28)
DEFAULT_JUMP_POWER = 200
DEFAULT_STEP_SIZE = 18
DEFAULT_MASS = 80
DEFAULT_MODELSCALE = 1

-- Humans can not carry OR drag anything heavier than this (in kg.)
CARRY_MAXIMUM_MASS = 300
-- Humans can not carry anything with a volume more than this (OBBMins():Length() + OBBMaxs():Length()).
CARRY_MAXIMUM_VOLUME = 150
-- Objects with more mass than this will be dragged instead of carried.
CARRY_DRAG_MASS = 145
-- Anything bigger than this is dragged regardless of mass.
CARRY_DRAG_VOLUME = 120
-- Humans are slowed by this amount per kg carried...
CARRY_SPEEDLOSS_PERKG = 1.3
-- but can never be slower than this.
CARRY_SPEEDLOSS_MINSPEED = 88

GM.MaxLegDamage = 3

GM.UtilityKey = IN_SPEED
GM.MenuKey = IN_WALK -- I would use the spawn menu but it has no IN_ key assignment.

-- Cost multiplier for being near an arsenal crate.
GM.ArsenalCrateMultiplier = 0.8
GM.ArsenalCrateDiscount = 1 - GM.ArsenalCrateMultiplier
GM.ArsenalCrateDiscountPercentage = GM.ArsenalCrateDiscount * 100

-- Set all "SPEED_" presets to 50 so we can tell if a certain swep is configured incorrectly, excluding SPEED_NORMAL.

SPEED_SLOWEST = 50
SPEED_SLOWER = 50
SPEED_SLOW = 50

SPEED_NORMAL = 200

SPEED_FAST = 50
SPEED_FASTER = 50
SPEED_FASTEST = 50

GM.HumanGibs = {
Model("models/gibs/HGIBS.mdl"),
Model("models/gibs/HGIBS_spine.mdl"),

Model("models/gibs/HGIBS_rib.mdl"),
Model("models/gibs/HGIBS_scapula.mdl"),
Model("models/gibs/antlion_gib_medium_2.mdl"),
Model("models/gibs/Antlion_gib_Large_1.mdl"),
Model("models/gibs/Strider_Gib4.mdl")
}

GM.BannedProps = {
	"models/props_wasteland/kitchen_shelf001a.mdl"
}

GM.PropHealthMultipliers = {
}

GM.AmmoNames = {}
GM.AmmoNames["ar2"] = "Assault Rifle"
GM.AmmoNames["pistol"] = "Pistol"
GM.AmmoNames["smg1"] = "SMG"
GM.AmmoNames["357"] = "Rifle"
GM.AmmoNames["xbowbolt"] = "Bolts"
GM.AmmoNames["buckshot"] = "Buckshot"
GM.AmmoNames["sniperround"] = "Boards"
GM.AmmoNames["grenade"] = "Grenades"
GM.AmmoNames["thumper"] = "Turrets"
GM.AmmoNames["battery"] = "Medical Supplies"
GM.AmmoNames["gaussenergy"] = "Nails"
GM.AmmoNames["airboatgun"] = "Arsenal Crates"
GM.AmmoNames["helicoptergun"] = "Resupply Boxes"
GM.AmmoNames["striderminigun"] = "Beacons"
GM.AmmoNames["slam"] = "Force Fields"
--GM.AmmoNames["spotlamp"] = "Spot Lamps"

GM.AmmoTranslations = {}
GM.AmmoTranslations["weapon_physcannon"] = "pistol"
GM.AmmoTranslations["weapon_ar2"] = "ar2"
GM.AmmoTranslations["weapon_shotgun"] = "buckshot"
GM.AmmoTranslations["weapon_smg1"] = "smg1"
GM.AmmoTranslations["weapon_pistol"] = "pistol"
GM.AmmoTranslations["weapon_357"] = "357"
GM.AmmoTranslations["weapon_slam"] = "pistol"
GM.AmmoTranslations["weapon_crowbar"] = "pistol"
GM.AmmoTranslations["weapon_stunstick"] = "pistol"

GM.AmmoModels = {}
GM.AmmoModels["pistol"] = "models/Items/BoxSRounds.mdl" -- Pistols
GM.AmmoModels["smg1"] = "models/Items/BoxMRounds.mdl" -- SMGs
GM.AmmoModels["battery"] = "models/healthvial.mdl" -- Medical Kit charge
GM.AmmoModels["buckshot"] = "models/Items/BoxBuckshot.mdl" -- Buckshot
GM.AmmoModels["357"] = "models/Items/357ammobox.mdl" -- Slugs
GM.AmmoModels["xbowbolt"] = "models/Items/CrossbowRounds.mdl" -- Bolts
GM.AmmoModels["gaussenergy"] = "models/Items/CrossbowRounds.mdl" -- "models/hammermodels/nail1.mdl" -- Nails
GM.AmmoModels["grenade"] = "models/weapons/w_grenade.mdl" -- Grenades
GM.AmmoModels["thumper"] = "models/Combine_turrets/Floor_turret.mdl" -- Gun turrets
GM.AmmoModels["airboatgun"] = "models/Items/item_item_crate.mdl" -- Arsenal crates
GM.AmmoModels["striderminigun"] = "models/props_combine/combine_mine01.mdl" -- Message beacons
GM.AmmoModels["helicoptergun"] = "models/Items/ammocrate_ar2.mdl" -- Resupply boxes
GM.AmmoModels["slam"] = "models/props_lab/lab_flourescentlight002b.mdl" -- Force Field Emitters
GM.AmmoModels["spotlamp"] = "models/props_combine/combine_light001a.mdl"

GM.FanList = {

}
