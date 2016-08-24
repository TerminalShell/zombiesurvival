-- Weapon sets that humans can start with if they choose RANDOM.
GM.StartLoadouts = {
	{"weapon_zs_battleaxe", "weapon_zs_knife"},
	{"weapon_zs_owens", "weapon_zs_knife"},
	{"weapon_zs_owens", "weapon_zs_plank"},
	{"weapon_zs_peashooter", "weapon_zs_axe"},
	{"weapon_zs_battleaxe", "weapon_zs_plank"},
	{"weapon_zs_battleaxe", "weapon_zs_axe"},
	{"weapon_zs_owens", "weapon_zs_axe"},
	{"weapon_zs_peashooter", "weapon_zs_knife"},
	{"weapon_zs_battleaxe", "weapon_zs_pan"}
}

-- Weapon, Ammo, and Powerup unlocks
GM.Wut = {40,80,160,285,400} // Weapon Unlock Tiers, hehe...
GM.WeaponUnlock = {}
GM.WeaponUnlock[1] = {"weapon_zs_deagle","weapon_zs_glock","weapon_zs_ricochet","weapon_zs_eraser", "weapon_zs_wolfos"} -- Tier 2 Pistols
GM.WeaponUnlock[2] = {"weapon_zs_machinery","weapon_zs_sprayer","weapon_zs_shredder","weapon_zs_bulletstorm"} -- SMG's
GM.WeaponUnlock[3] = {"weapon_zs_defender","weapon_zs_reaper","weapon_zs_akbar"} -- Tier 1 Rifles
GM.WeaponUnlock[4] = {"weapon_zs_annabelle","weapon_zs_stalker","weapon_zs_inferno"} -- Tier 2 Rifles
GM.WeaponUnlock[5] = {"weapon_zs_sweeper","weapon_zs_boomstick","weapon_zs_crossbow","weapon_zs_tinyslug"} -- Tier 3 Rifles

GM.Aut = {100,140,200,245,325,450,600,800,1000} // Ammo Unlock Tiers

GM.Put = {120,225,360,500,700,900} // Powerup Unlock Tiers, hehe...
GM.PowerupUnlock = {}
GM.PowerupUnlock[1] = {"health","regen"}
GM.PowerupUnlock[2] = {"health","regen"}
GM.PowerupUnlock[3] = {"health","regen"}
GM.PowerupUnlock[4] = {"health","regen"}
GM.PowerupUnlock[5] = {"health","regen"}
GM.PowerupUnlock[6] = {"health","regen"}

ITEMCAT_GUNS = 1
ITEMCAT_AMMO = 2
ITEMCAT_MELEE = 3
ITEMCAT_TOOLS = 4
ITEMCAT_OTHER = 5
ITEMCAT_RETURNS = 6

GM.ItemCategories = {
	[ITEMCAT_GUNS] = "Guns",
	[ITEMCAT_AMMO] = "Ammunition",
	[ITEMCAT_MELEE] = "Melee Weapons",
	[ITEMCAT_TOOLS] = "Tools",
	[ITEMCAT_OTHER] = "Other",
	[ITEMCAT_RETURNS] = "Returns"
}

--[[
Humans select what weapons (or other things) they want to start with and can even save favorites. Each object has a number of 'Worth' points.
Signature is a unique signature to give in case the item is renamed or reordered. Don't use a number or a string number!
A human can only use 100 points (default) when they join. Redeeming or joining late starts you out with a random loadout from above.
SWEP is a swep given when the player spawns with that perk chosen.
Callback is a function called. Model is a display model. If model isn't defined then the SWEP model will try to be used.
swep, callback, and model can all be nil or empty
]]
GM.Items = {}
function GM:AddItem(signature, name, desc, category, worth, swep, callback, model, worthshop, pointshop)
	local tab = {Signature = signature, Name = name, Description = desc, Category = category, Worth = worth or 0, SWEP = swep, Callback = callback, Model = model, WorthShop = worthshop, PointShop = pointshop}
	self.Items[#self.Items + 1] = tab

	return tab
end

function GM:AddStartingItem(signature, name, desc, category, points, worth, callback, model)
	return self:AddItem(signature, name, desc, category, points, worth, callback, model, true, false)
end

function GM:AddPointShopItem(signature, name, desc, category, points, worth, callback, model)
	return self:AddItem("ps_"..signature, name, desc, category, points, worth, callback, model, false, true)
end

-- Weapons are registered after the gamemode.
timer.Simple(0, function()
	for _, tab in pairs(GAMEMODE.Items) do
		if not tab.Description and tab.SWEP then
			local sweptab = weapons.GetStored(tab.SWEP)
			if sweptab then
				tab.Description = sweptab.Description
			end
		end
	end
end)

-- How much ammo is considered one 'clip' of ammo? For use with setting up weapon defaults. Works directly with zs_survivalclips
GM.AmmoCache = {}
GM.AmmoCache["ar2"] = 60 -- Assault rifles.
GM.AmmoCache["alyxgun"] = 24 -- Not used.
GM.AmmoCache["pistol"] = 32 -- Pistols.
GM.AmmoCache["smg1"] = 60 -- SMG's and some rifles.
GM.AmmoCache["357"] = 24 -- Rifles
GM.AmmoCache["xbowbolt"] = 4 -- Crossbows
GM.AmmoCache["buckshot"] = 10 -- Shotguns
GM.AmmoCache["ar2altfire"] = 1 -- Not used.
GM.AmmoCache["slam"] = 1 -- Force Field Emitters.
GM.AmmoCache["rpg_round"] = 1 -- Not used. Rockets?
GM.AmmoCache["smg1_grenade"] = 1 -- Not used.
GM.AmmoCache["sniperround"] = 2 -- Barricade Kit
GM.AmmoCache["sniperpenetratedround"] = 1 -- Remote Det pack.
GM.AmmoCache["grenade"] = 1 -- Grenades.
GM.AmmoCache["thumper"] = 1 -- Gun turret.
GM.AmmoCache["gravity"] = 1 -- Unused.
GM.AmmoCache["battery"] = 10 -- Used with the Medical Kit.
GM.AmmoCache["gaussenergy"] = 1 -- Nails used with the Carpenter's Hammer.
GM.AmmoCache["combinecannon"] = 1 -- Not used.
GM.AmmoCache["airboatgun"] = 1 -- Arsenal crates.
GM.AmmoCache["striderminigun"] = 1 -- Message beacons.
GM.AmmoCache["helicoptergun"] = 1 --Resupply boxes.
--GM.AmmoCache["spotlamp"] = 1 --Spotlamps

-- These ammo types available at ammunition boxes.
GM.AmmoResupply = {}
GM.AmmoResupply["ar2"] = 60
GM.AmmoResupply["alyxgun"] = 24
GM.AmmoResupply["pistol"] = 32
GM.AmmoResupply["smg1"] = 60
GM.AmmoResupply["357"] = 24
GM.AmmoResupply["gaussenergy"] = 1
GM.AmmoResupply["buckshot"] = 10
GM.AmmoResupply["battery"] = 50
GM.AmmoResupply["SniperRound"] = 2
GM.AmmoResupply["xbowbolt"] = 4

GM:AddStartingItem("daring", "'Daring' Derringer", nil, ITEMCAT_GUNS, 10, "weapon_zs_daring")
GM:AddStartingItem("handyman", "'Handyman' Handgun", nil, ITEMCAT_GUNS, 15, "weapon_zs_handyman")
GM:AddStartingItem("pshtr", "'Peashooter' Handgun", nil, ITEMCAT_GUNS, 40, "weapon_zs_peashooter")
GM:AddStartingItem("btlax", "'Battleaxe' Handgun", nil, ITEMCAT_GUNS, 40, "weapon_zs_battleaxe")
GM:AddStartingItem("owens", "'Owens' Handgun", nil, ITEMCAT_GUNS, 40, "weapon_zs_owens")
GM:AddStartingItem("blstr", "'Blaster' Shotgun", nil, ITEMCAT_GUNS, 55, "weapon_zs_blaster")
GM:AddStartingItem("tossr", "'Tosser' SMG", nil, ITEMCAT_GUNS, 50, "weapon_zs_tosser")
GM:AddStartingItem("stbbr", "'Stubber' Rifle", nil, ITEMCAT_GUNS, 55, "weapon_zs_stubber")
GM:AddStartingItem("crklr", "'Crackler' Assault Rifle", nil, ITEMCAT_GUNS, 50, "weapon_zs_crackler")

GM:AddStartingItem("4pcp", "Extra Pistol Ammo", "Extra pistol ammunition", ITEMCAT_AMMO, 15, nil, function(pl) pl:GiveAmmo((GAMEMODE.AmmoCache["pistol"]) * 4, "pistol", true) end, "models/Items/BoxSRounds.mdl")
GM:AddStartingItem("4sgcp", "Extra Shotgun Ammo", "Extra shotgun ammunition", ITEMCAT_AMMO, 15, nil, function(pl) pl:GiveAmmo((GAMEMODE.AmmoCache["buckshot"]) * 4, "buckshot", true) end, "models/Items/BoxBuckshot.mdl")
GM:AddStartingItem("4smgcp", "Extra SMG Ammo", "Extra submachine gun ammunition", ITEMCAT_AMMO, 15, nil, function(pl) pl:GiveAmmo((GAMEMODE.AmmoCache["smg1"]) * 4, "smg1", true) end, "models/Items/BoxMRounds.mdl")
GM:AddStartingItem("4arcp", "Extra Assault Rifle Ammo", "Extra assault rifle ammunition", ITEMCAT_AMMO, 15, nil, function(pl) pl:GiveAmmo((GAMEMODE.AmmoCache["ar2"]) * 4, "ar2", true) end, "models/Items/BoxMRounds.mdl")
GM:AddStartingItem("4rcp", "Extra Rifle Ammo", "Extra rifle ammunition", ITEMCAT_AMMO, 15, nil, function(pl) pl:GiveAmmo((GAMEMODE.AmmoCache["357"]) * 4, "357", true) end, "models/Items/357ammobox.mdl")

GM:AddStartingItem("csknf", "Knife", nil, ITEMCAT_MELEE, 10, "weapon_zs_knife")
GM:AddStartingItem("zpplnk", "Plank", nil, ITEMCAT_MELEE, 10, "weapon_zs_plank")
GM:AddStartingItem("zpfryp", "Frying Pan", nil, ITEMCAT_MELEE, 20, "weapon_zs_pan")
GM:AddStartingItem("zpcpot", "Cooking Pot", nil, ITEMCAT_MELEE, 20, "weapon_zs_pot")
GM:AddStartingItem("zpaxe", "Axe", nil, ITEMCAT_MELEE, 30, "weapon_zs_axe")
GM:AddStartingItem("crwbar", "Crowbar", nil, ITEMCAT_MELEE, 30, "weapon_zs_crowbar")
GM:AddStartingItem("stnbtn", "Stun Baton", nil, ITEMCAT_MELEE, 45, "weapon_zs_stunstick")

GM:AddStartingItem("msgbeacon", "Message Beacon", nil, ITEMCAT_TOOLS, 5, "weapon_zs_beacon").Countables = "prop_messagebeacon"
GM:AddStartingItem("12nails", "Box of 12 nails", "An extra box of nails for all your barricading needs.", ITEMCAT_TOOLS, 25, nil, function(pl) pl:GiveAmmo(12, "GaussEnergy", true) end, "models/Items/BoxMRounds.mdl")
GM:AddStartingItem("junkpack", "Junk Pack", nil, ITEMCAT_TOOLS, 30, "weapon_zs_junk")
GM:AddStartingItem("grenade", "Grenade", nil, ITEMCAT_OTHER, 30, "weapon_zs_grenade")
GM:AddStartingItem("100mkit", "100 Medical Kit power", "100 extra power for the Medical Kit.", ITEMCAT_TOOLS, 30, nil, function(pl) pl:GiveAmmo(100, "Battery", true) end, "models/healthvial.mdl")
GM:AddStartingItem("detpck", "Detonation Pack", nil, ITEMCAT_OTHER, 35, "weapon_zs_detpack").Countables = "prop_detpack"
GM:AddStartingItem("crphmr", "Carpenter's Hammer", nil, ITEMCAT_TOOLS, 45, "weapon_zs_hammer").NoClassicMode = true
GM:AddStartingItem("medkit", "Medical Kit", nil, ITEMCAT_TOOLS, 50, "weapon_zs_medkit")
GM:AddStartingItem("arscrate", "Arsenal Crate", nil, ITEMCAT_TOOLS, 70, "weapon_zs_arsenal").Countables = "prop_arsenalcrate"
GM:AddStartingItem("resupplybox", "Resupply Box", nil, ITEMCAT_TOOLS, 70, "weapon_zs_resupply").Countables = "prop_resupplybox"
local item = GM:AddStartingItem("infturret", "Infrared Gun Turret", nil, ITEMCAT_TOOLS, 70, "weapon_zs_turret")item.Countables = "prop_gunturret" item.NoClassicMode = true
--GM:AddStartingItem("spotlamp", "Spot Lamp", nil, ITEMCAT_TOOLS, 85, "weapon_zs_spotlamp").Countables = "prop_spotlamp"
--GM:AddStartingItem("ffemitter", "Force Field Emitter", nil, ITEMCAT_TOOLS, 85, "weapon_zs_forcefield").Countables = "prop_ffemitter"

GM:AddStartingItem("10hp", "Fit", "Increases survivability by increasing maximum health by a small amount.", ITEMCAT_OTHER, 10, nil, function(pl) pl:SetMaxHealth(pl:GetMaxHealth() + 10) pl:SetHealth(pl:GetMaxHealth()) end, "models/healthvial.mdl")
GM:AddStartingItem("25hp", "Tough", "Increases survivability by increasing maximum health.", ITEMCAT_OTHER, 20, nil, function(pl) pl:SetMaxHealth(pl:GetMaxHealth() + 25) pl:SetHealth(pl:GetMaxHealth()) end, "models/items/healthkit.mdl")
GM:AddStartingItem("bfhandy", "Handy", "Gives a 25% bonus to all repair rates.", ITEMCAT_OTHER, 25, nil, function(pl) pl.HumanRepairMultiplier = (pl.HumanRepairMultiplier or 1) + 0.25 end, "models/props_c17/tools_wrench01a.mdl")
GM:AddStartingItem("bfpediatrician", "Pediatrician", "Increases the rate by which you can heal yourself and others with the Medical Kit by 30%.", ITEMCAT_OTHER, 25, nil, function(pl) pl.HumanHealMultiplier = (pl.HumanHealMultiplier or 1) + 0.3 end, "models/healthvial.mdl")
GM:AddStartingItem("bfresist", "Resistant", "Poison will regenerate over time a bit faster.", ITEMCAT_OTHER, 20, nil, function(pl) pl.BuffResistant = true end, "models/healthvial.mdl")
GM:AddStartingItem("bfregen", "Regenerative", "You will regenerate 5 health for every minute you receive no damage.", ITEMCAT_OTHER, 25, nil, function(pl) pl.BuffRegenerative = true end, "models/healthvial.mdl")

GM:AddStartingItem("dbfweak", "Weakness", "Reduces health by 30 in exchange for Worth.", ITEMCAT_RETURNS, -15, nil, function(pl) pl:SetMaxHealth(math.max(1, pl:GetMaxHealth() - 30)) pl:SetHealth(pl:GetMaxHealth()) pl.IsWeak = true end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfslow", "Slowness", "Reduces speed by a significant amount in exchange for Worth.", ITEMCAT_RETURNS, -5, nil, function(pl) pl.HumanSpeedAdder = (pl.HumanSpeedAdder or 1) - 20 pl:ResetSpeed() pl.IsSlow = true end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfpalsy", "Palsy", "Reduces aiming ability while hurt in exchange for Worth.", ITEMCAT_RETURNS, -5, nil, function(pl) pl:SetPalsy(true) end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfhemo", "Hemophilia", "Disallows being healed in exchange for Worth.", ITEMCAT_RETURNS, -15, nil, function(pl) pl:SetHemophilia(true) end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfunluc", "Banned for Life", "Disallows point purchases in exchange for Worth.", ITEMCAT_RETURNS, -25, nil, function(pl) pl:SetUnlucky(true) end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfclumsy", "Clumsy", "Makes you extremely easy to knock down in exchange for Worth.", ITEMCAT_RETURNS, -25, nil, function(pl) pl.Clumsy = true end, "models/gibs/HGIBS.mdl")
GM:AddStartingItem("dbfnoghosting", "Wide Load", "Prevents you from ghosting through props in exchange for Worth.", ITEMCAT_RETURNS, -25, nil, function(pl) pl.NoGhosting = true end, "models/gibs/HGIBS.mdl").NoClassicMode = true

GM:AddPointShopItem("daring", "'Daring' Handgun", nil, ITEMCAT_GUNS, 10, "weapon_zs_daring")
GM:AddPointShopItem("handyman", "'Handyman' Handgun", nil, ITEMCAT_GUNS, 15, "weapon_zs_handyman")
GM:AddPointShopItem("deagle", "'Zombie Drill' Desert Eagle", nil, ITEMCAT_GUNS, 30, "weapon_zs_deagle")
GM:AddPointShopItem("glock3", "'Crossfire' Glock 3", nil, ITEMCAT_GUNS, 30, "weapon_zs_glock")
GM:AddPointShopItem("magnum", "'Ricochet' Magnum", nil, ITEMCAT_GUNS, 35, "weapon_zs_ricochet")
GM:AddPointShopItem("eraser", "'Eraser' Tactical Pistol", nil, ITEMCAT_GUNS, 35, "weapon_zs_eraser")
GM:AddPointShopItem("wolfo", "'Wolfos' Handgun", nil, ITEMCAT_GUNS, 40, "weapon_zs_wolfos")

GM:AddPointShopItem("machinery", "'Machinery' SMG", nil, ITEMCAT_GUNS, 60, "weapon_zs_machinery")
GM:AddPointShopItem("uzi", "'Sprayer' Uzi 9mm", nil, ITEMCAT_GUNS, 70, "weapon_zs_sprayer")
GM:AddPointShopItem("shredder", "'Shredder' SMG", nil, ITEMCAT_GUNS, 70, "weapon_zs_shredder")
GM:AddPointShopItem("bulletstorm", "'Bullet Storm' SMG", nil, ITEMCAT_GUNS, 70, "weapon_zs_bulletstorm")

GM:AddPointShopItem("defender", "'Defender' Galil", nil, ITEMCAT_GUNS, 75, "weapon_zs_defender")
GM:AddPointShopItem("reaper", "'Reaper' UMP", nil, ITEMCAT_GUNS, 80, "weapon_zs_reaper")
GM:AddPointShopItem("akbar", "'Akbar' Assault Rifle", nil, ITEMCAT_GUNS, 80, "weapon_zs_akbar")
GM:AddPointShopItem("pulserifle", "'Adonis' Pulse Rifle", nil, ITEMCAT_GUNS, 80, "weapon_zs_adonis")

GM:AddPointShopItem("annabelle", "'Annabelle' Rifle", nil, ITEMCAT_GUNS, 100, "weapon_zs_annabelle")
GM:AddPointShopItem("stalker", "'Stalker' Assault Rifle", nil, ITEMCAT_GUNS, 125, "weapon_zs_stalker")
GM:AddPointShopItem("inferno", "'Inferno' Assault Rifle", nil, ITEMCAT_GUNS, 125, "weapon_zs_inferno")

GM:AddPointShopItem("sweeper", "'Sweeper' Shotgun", nil, ITEMCAT_GUNS, 150, "weapon_zs_sweeper")

GM:AddPointShopItem("crossbow", "'Impaler' Crossbow", nil, ITEMCAT_GUNS, 180, "weapon_zs_crossbow")
GM:AddPointShopItem("slugrifle", "'Tiny' Slug Rifle", nil, ITEMCAT_GUNS, 200, "weapon_zs_tinyslug")

GM:AddPointShopItem("boomstick", "Boom Stick", nil, ITEMCAT_GUNS, 300, "weapon_zs_boomstick")

GM:AddPointShopItem("pistolammo", "pistol ammo box", nil, ITEMCAT_AMMO, 6, nil, function(pl) pl:GiveAmmo(GAMEMODE.AmmoCache["pistol"] or 12, "pistol", true) end, "models/Items/BoxSRounds.mdl")
GM:AddPointShopItem("shotgunammo", "shotgun ammo box", nil, ITEMCAT_AMMO, 7, nil, function(pl) pl:GiveAmmo(GAMEMODE.AmmoCache["buckshot"] or 8, "buckshot", true) end, "models/Items/BoxBuckshot.mdl")
GM:AddPointShopItem("smgammo", "SMG ammo box", nil, ITEMCAT_AMMO, 7, nil, function(pl) pl:GiveAmmo(GAMEMODE.AmmoCache["smg1"] or 30, "smg1", true) end, "models/Items/BoxMRounds.mdl")
GM:AddPointShopItem("assaultrifleammo", "assault rifle ammo box", nil, ITEMCAT_AMMO, 7, nil, function(pl) pl:GiveAmmo(GAMEMODE.AmmoCache["ar2"] or 30, "ar2", true) end, "models/Items/BoxMRounds.mdl")
GM:AddPointShopItem("rifleammo", "rifle ammo box", nil, ITEMCAT_AMMO, 7, nil, function(pl) pl:GiveAmmo(GAMEMODE.AmmoCache["357"] or 6, "357", true) end, "models/Items/357ammobox.mdl")
GM:AddPointShopItem("crossbowammo", "crossbow bolt", nil, ITEMCAT_AMMO, 5, nil, function(pl) pl:GiveAmmo(4, "XBowBolt", true) end, "models/Items/CrossbowRounds.mdl")

GM:AddPointShopItem("knife", "Knife", nil, ITEMCAT_MELEE, 5, "weapon_zs_knife")
GM:AddPointShopItem("axe", "Axe", nil, ITEMCAT_MELEE, 20, "weapon_zs_axe")
GM:AddPointShopItem("crowbar", "Crowbar", nil, ITEMCAT_MELEE, 20, "weapon_zs_crowbar")
GM:AddPointShopItem("stunbaton", "Stun Baton", nil, ITEMCAT_MELEE, 25, "weapon_zs_stunstick")
GM:AddPointShopItem("shovel", "Shovel", nil, ITEMCAT_MELEE, 30, "weapon_zs_shovel")
GM:AddPointShopItem("sledgehammer", "Sledge Hammer", nil, ITEMCAT_MELEE, 45, "weapon_zs_sledge")

GM:AddPointShopItem("msgbeacon", "Message Beacon", "Display helpful messages for your comrades.", ITEMCAT_TOOLS, 5, "weapon_zs_beacon").Countables = "prop_messagebeacon"
GM:AddPointShopItem("nail", "Pack of Nails", "Four nails!", ITEMCAT_TOOLS, 10, nil, function(pl) pl:GiveAmmo(4, "GaussEnergy", true) end, "models/crossbow_bolt.mdl").NoClassicMode = true
GM:AddPointShopItem("emergencyboard", "Emergency Board", nil, ITEMCAT_TOOLS, 35, "weapon_zs_emergencyboard")
GM:AddPointShopItem("10mkit", "10 Medical Kit power", "10 extra power for the Medical Kit.", ITEMCAT_TOOLS, 5, nil, function(pl) pl:GiveAmmo(10, "Battery", true) end, "models/healthvial.mdl")
GM:AddPointShopItem("crphmr", "Carpenter's Hammer", nil, ITEMCAT_TOOLS, 50, "weapon_zs_hammer").NoClassicMode = true
GM:AddPointShopItem("arsenalcrate", "Arsenal Crate", nil, ITEMCAT_TOOLS, 75, "weapon_zs_arsenal")
GM:AddPointShopItem("resupplybox", "Resupply Box", nil, ITEMCAT_TOOLS, 100, "weapon_zs_resupply")
GM:AddPointShopItem("infturret", "Infrared Gun Turret", nil, ITEMCAT_TOOLS, 75, "weapon_zs_turret").NoClassicMode = true
GM:AddPointShopItem("barricadekit", "'Aegis' Barricade Kit", nil, ITEMCAT_TOOLS, 125, "weapon_zs_aegis")
GM:AddPointShopItem("medkit", "Medical Kit", nil, ITEMCAT_TOOLS, 100, "weapon_zs_medkit")

GM:AddPointShopItem("grenade", "Grenade", nil, ITEMCAT_OTHER, 60, "weapon_zs_grenade")
GM:AddPointShopItem("detpck", "Detonation Pack", nil, ITEMCAT_OTHER, 70, "weapon_zs_detpack")
GM:AddPointShopItem("a bust-on-a-stick", "A Bust-On-A-Stick", nil, ITEMCAT_OTHER, 50, "weapon_zs_bust")
GM:AddPointShopItem("a sawhack", "A Sawhack", nil, ITEMCAT_OTHER, 60, "weapon_zs_sawhack")
GM:AddPointShopItem("a mega masher", "A Mega Masher", nil, ITEMCAT_OTHER, 80, "weapon_zs_megamasher")
GM:AddPointShopItem("an electrohammer", "An Electrohammer", nil, ITEMCAT_OTHER, 80, "weapon_zs_electrohammer")
GM:AddPointShopItem("a razor blade", "A Razor Blade", nil, ITEMCAT_OTHER, 30, "weapon_zs_razor")

local function genericcallback(pl, magnitude) return pl:Name(), magnitude end
GM.HonorableMentions = {}
GM.HonorableMentions[HM_MOSTZOMBIESKILLED] = {Name = "Most zombies killed", String = "by %s, with %d killed zombies.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_LASTHUMAN] = {Name = "Last Human", String = "goes to %s for being the last person alive.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD] = {Name = "Most damage to undead", String = "goes to %s, with a total of %d damage dealt to the undead.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTHELPFUL] = {Name = "Most helpful", String = "goes to %s for assisting in the disposal of %d zombies.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_PACIFIST] = {Name = "Pacifist", String = "goes to %s for not killing a single zombie and still surviving!", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_OUTLANDER] = {Name = "Outlander", String = "goes to %s for getting killed %d feet away from a zombie spawn.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_GOODDOCTOR] = {Name = "Good Doctor", String = "goes to %s for healing their team for %d points of health.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_HANDYMAN] = {Name = "Handy Man", String = "goes to %s for getting %d barricade assistance points.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_SCARECROW] = {Name = "Scarecrow", String = "goes to %s for killing %d poor crows.", Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_MOSTBRAINSEATEN] = {Name = "Most brains eaten", String = "by %s, with %d brains eaten.", Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS] = {Name = "Most damage to humans", String = "goes to %s, with a total of %d damage given to living players.", Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_LASTBITE] = {Name = "Last Bite", String = "goes to %s for ending the round.", Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_USEFULTOOPPOSITE] = {Name = "Most useful to opposite team", String = "goes to %s for giving up a whopping %d kills!", Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_STUPID] = {Name = "Stupid", String = "is what %s is for getting killed %d feet away from a zombie spawn.", Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_SALESMAN] = {Name = "Salesman", String = "is what %s is for having %d points worth of items taken from their arsenal crate.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_WAREHOUSE] = {Name = "Warehouse", String = "describes %s well since they had their resupply boxes used %d times.", Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_SPAWNPOINT] = {Name = "Spawn Point", String = "goes to %s for having %d zombies spawn on them.", Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_CROWFIGHTER] = {Name = "Crow Fighter", String = "goes to %s for annihilating %d of his crow brethren.", Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_CROWBARRICADEDAMAGE] = {Name = "Minor Annoyance", String = "is what %s is for dealing %d damage to barricades while a crow.", Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_BARRICADEDESTROYER] = {Name = "Barricade Destroyer", String = "goes to %s for doing %d damage to barricades.", Callback = genericcallback, Color = COLOR_LIMEGREEN}

GM.ValidBeaconMessages = {
"MEET UP HERE!",
"BARRICADE HERE!",
"DEFEND HERE!",
"REPAIR THIS BARRICADE!",
"HEALTH STATION HERE!",
"GET READY TO RUN!",
"AMMO HERE!",
"DON'T BARRICADE HERE!",
"AVOID THIS LOCATION!",
"FOCUS ON THE BOSS!"
}

GM.SpecialBeaconMessages = {
"",
}

-- Don't let humans use these models for obvious reasons.
GM.RestrictedModels = {}
GM.RestrictedModels["models/player/zombie_classic.mdl"] = true
GM.RestrictedModels["models/player/zombine.mdl"] = true
GM.RestrictedModels["models/player/zombie_soldier.mdl"] = true
GM.RestrictedModels["models/player/zombie_fast.mdl"] = true
GM.RestrictedModels["models/player/corpse1.mdl"] = true
GM.RestrictedModels["models/player/charple.mdl"] = true
GM.RestrictedModels["models/player/skeleton.mdl"] = true

-- If a person has no player model then use one of these.
GM.RandomPlayerModels = {}
for name, mdl in pairs(player_manager.AllValidModels()) do
	if not GM.RestrictedModels[string.lower(mdl)] then
		table.insert(GM.RandomPlayerModels, name)
	end
end

-- Utility function to setup a weapon's DefaultClip.
function GM:SetupDefaultClip(tab)
	tab.DefaultClip = math.ceil(tab.ClipSize * self.SurvivalClips * (tab.ClipMultiplier or 1))
end

GM.StartingWorth = CreateConVar("zs_startingworth", "100", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Specifies the amount of Worth humans are able to choose their starting loadout with. A value of 0 means no Worth enabled."):GetInt()
cvars.AddChangeCallback("zs_startingworth", function(cvar, oldvalue, newvalue)
	GAMEMODE.StartingWorth = math.max(0, tonumber(newvalue) or 0)
end)

GM.DefaultRedeem = 4 --CreateConVar("zs_redeem", "4", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The amount of kills a zombie needs to do in order to redeem. Set to 0 to disable."):GetInt()
--cvars.AddChangeCallback("zs_redeem", function(cvar, oldvalue, newvalue)
--	GAMEMODE.DefaultRedeem = math.max(0, tonumber(newvalue) or 0)
--end)

GM.WaveOneZombies = math.ceil(100 * CreateConVar("zs_waveonezombies", "0.3", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The percentage of players that will start as zombies when the game begins."):GetFloat()) * 0.01
cvars.AddChangeCallback("zs_waveonezombies", function(cvar, oldvalue, newvalue)
	GAMEMODE.WaveOneZombies = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.NumberOfWaves = 10

--GM.NumberOfWaves = CreateConVar("zs_numberofwaves", "10", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Number of waves in a game."):GetInt()
--cvars.AddChangeCallback("zs_numberofwaves", function(cvar, oldvalue, newvalue)
--	GAMEMODE.NumberOfWaves = 10
--end)

-- This is controlled by logic_waves.
function GM:GetNumberOfWaves()
	return GetGlobalInt("numwaves", GetGlobalBool("classicmode") and 10 or self.NumberOfWaves)
end

function GM:GetWaveOneLength()
	return GetGlobalBool("classicmode") and self.WaveOneLengthClassic or self.WaveOneLength
end

GM.MedkitPointsPerHealth = CreateConVar("zs_medkitpointsperhealth", "10", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Specifies the amount of healing for players to be given a point. For use with the medkit and such."):GetInt()
cvars.AddChangeCallback("zs_medkitpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.MedkitPointsPerHealth = tonumber(newvalue) or 1
end)

GM.RepairPointsPerHealth = CreateConVar("zs_repairpointsperhealth", "30", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Specifies the amount of repairing for players to be given a point. For use with nails and such."):GetInt()
cvars.AddChangeCallback("zs_repairpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.RepairPointsPerHealth = tonumber(newvalue) or 1
end)

GM.SurvivalClips = CreateConVar("zs_survivalclips", "6", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "How many clips of ammo guns from the Worth menu start with. Some guns such as shotguns and sniper rifles have multipliers on this."):GetInt()
cvars.AddChangeCallback("zs_survivalclips", function(cvar, oldvalue, newvalue)
	GAMEMODE.SurvivalClips = tonumber(newvalue) or 1
end)

-- Game feeling too easy? Just change these values!
GM.ZombieSpeedMultiplier = math.ceil(100 * CreateConVar("zs_zombiespeedmultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Zombie running speed will be scaled by this value."):GetFloat()) * 0.01
cvars.AddChangeCallback("zs_zombiespeedmultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieSpeedMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- This is a resistance, not for claw damage. 0.5 will make zombies take half damage, 0.25 makes them take 1/4, etc.
GM.ZombieDamageMultiplier = math.ceil(100 * CreateConVar("zs_zombiedamagemultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Scales the amount of damage that zombies take. Use higher values for easy zombies, lower for harder."):GetFloat()) * 0.01
cvars.AddChangeCallback("zs_zombiedamagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.TimeLimit = CreateConVar("zs_timelimit", "25", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Time in minutes before the game will change maps. It will not change maps if a round is currently in progress but after the current round ends. -1 means never switch maps. 0 means always switch maps."):GetInt() * 60
cvars.AddChangeCallback("zs_timelimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.TimeLimit = tonumber(newvalue) or 15
	if GAMEMODE.TimeLimit ~= -1 then
		GAMEMODE.TimeLimit = GAMEMODE.TimeLimit * 60
	end
end)

GM.RoundLimit = CreateConVar("zs_roundlimit", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY, "How many times the game can be played on the same map. -1 means infinite or only use time limit. 0 means once."):GetInt()
cvars.AddChangeCallback("zs_roundlimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.RoundLimit = tonumber(newvalue) or 3
end)

-- Initial length for wave 1.
GM.WaveOneLength = 120

-- For Classic Mode
GM.WaveOneLengthClassic = 120

-- Add this many seconds for each additional wave.
GM.TimeAddedPerWave = 0

-- For Classic Mode
GM.TimeAddedPerWaveClassic = 0

-- New players are put on the zombie team if the current wave is this or higher. Do not put it lower than 1 or you'll break the game.
GM.NoNewHumansWave = 6

-- Humans can not commit suicide if the current wave is this or lower.
GM.NoSuicideWave = 0

-- How long 'wave 0' should last in seconds. This is the time you should give for new players to join and get ready.
GM.WaveZeroLength = 135

-- Time humans have between waves to do stuff without NEW zombies spawning. Any dead zombies will be in spectator (crow) view and any living ones will still be living.
GM.WaveIntermissionLength = 30

-- For Classic Mode
GM.WaveIntermissionLengthClassic = 40

-- Time in seconds between end round and next map.
GM.EndGameTime = 30

-- Put your unoriginal, 5MB Rob Zombie and Metallica music here.
LASTHUMANSOUND = Sound("lasthumanm.ogg")

-- Sound played when humans all die.
ALLLOSESOUND = Sound("humanslosefqd.ogg")

-- Sound played when humans survive.
HUMANWINSOUND = Sound("humanwin.ogg")

-- Sound played to a person when they die as a human.
DEATHSOUND = Sound("music/stingers/HL1_stinger_song28.mp3")
