--[[

Zombie Survival
by William "JetBoom" Moodhe
williammoodhe@gmail.com -or- jetboom@noxiousnet.com
http://www.noxiousnet.com/

Further credits displayed by pressing F1 in-game.
This was my first ever gamemode. A lot of stuff is from years ago and some stuff is very recent.

]]

-- TODO: If humans win then fade to white while view flies up in the sky. Show black clouds floating around. Remaining humans win with particle shit coming out of it or something like that.
-- TODO: Redeeming flashes your screen white, plays ringing DSP.
-- TODO: Finish replacing all static strings with translate library.

-- CRAFTING AND ITEM IDEAS
--[[
ITEMS
nighkeez: you run a bit faster while wearing them. Also attaches white boot props to your feet.
AWTH barrel: if it so much as bangs in to something then it blows up with a huge explosion (like fire bomb size).
stabber: stubber with a knife in the barrel. A melee weapon with very low size but high reach.
hot milk: puts you to sleep for a stupid amount of time and you regenerate health a little bit.
gelbanana: green gel banana. using it gives you 8 health.
body armor: nullifies one hit that does 20 or more damage and then immediately breaks.

RECIPEES
boot prop + boot prop = nighkeez
nighkeez + bananas prop = clown shoes
explosive barrel + explosive barrel = big explosive barrel
oxygen canister + big explosive barrel = AWTH barrel
stubber + knife = stabber
milk + heat source = hot milk
ammonia + bleach = mustard gas on the spot. spams yellow fumes everywhere and lethally poisons the user.
bananas + microwave = gelbanana
metal barrel + something = body armor
--]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("sh_translate.lua")
AddCSLuaFile("sh_colors.lua")
AddCSLuaFile("sh_serialization.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("sh_crafts.lua")
AddCSLuaFile("sh_util.lua")
AddCSLuaFile("sh_options.lua")
AddCSLuaFile("sh_zombieclasses.lua")
AddCSLuaFile("sh_animations.lua")

AddCSLuaFile("cl_voice.lua")
AddCSLuaFile("cl_util.lua")
AddCSLuaFile("cl_options.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("cl_postprocess.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_floatingscore.lua")
AddCSLuaFile("cl_dermaskin.lua")
AddCSLuaFile("cl_hint.lua")

AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_player_extend_cl.lua")
AddCSLuaFile("obj_weapon_extend.lua")
AddCSLuaFile("obj_entity_extend.lua")

AddCSLuaFile("vgui/dgamestate.lua")
AddCSLuaFile("vgui/dteamcounter.lua")
AddCSLuaFile("vgui/dmodelpanelex.lua")
AddCSLuaFile("vgui/dammocounter.lua")
AddCSLuaFile("vgui/dpingmeter.lua")
AddCSLuaFile("vgui/dteamheading.lua")
AddCSLuaFile("vgui/dsidemenu.lua")

AddCSLuaFile("vgui/pmainmenu.lua")
AddCSLuaFile("vgui/poptions.lua")
AddCSLuaFile("vgui/phelp.lua")
AddCSLuaFile("vgui/pclassselect.lua")
AddCSLuaFile("vgui/pweapons.lua")
AddCSLuaFile("vgui/pendboard.lua")
AddCSLuaFile("vgui/pworth.lua")
AddCSLuaFile("vgui/ppointshop.lua")

AddCSLuaFile("cl_splitmessage.lua")

AddCSLuaFile("cl_hitdamagenumbers.lua")

include("shared.lua")
include("sv_options.lua")
include("sv_crafts.lua")
include("obj_entity_extend_sv.lua")
include("obj_player_extend_sv.lua")
include("mapeditor.lua")
include("sv_playerspawnentities.lua")

include("sv_hitdamagenumbers.lua")

if file.Exists(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

function BroadcastLua(code)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(code)
	end
end

player.GetByUniqueID = player.GetByUniqueID or function(uid)
	for _, pl in pairs(player.GetAll()) do
		if pl:UniqueID() == uid then return pl end
	end
end

function GM:WorldHint(hint, pos, ent, lifetime, filter)
	umsg.Start("worldhint", filter)
		umsg.String(hint)
		umsg.Vector(pos or ent and ent:IsValid() and ent:GetPos() or vector_origin)
		umsg.Entity(ent or NULL)
		umsg.Float(lifetime or 8)
	umsg.End()
end

function GM:CreateGibs(pos, headoffset)
	headoffset = headoffset or 0

	local headpos = Vector(pos.x, pos.y, pos.z + headoffset)
	for i = 1, 2 do
		local ent = ents.Create("prop_playergib")
		if ent:IsValid() then
			ent:SetPos(headpos + VectorRand() * 5)
			ent:SetAngles(VectorRand():Angle())
			ent:SetGibType(i)
			ent:Spawn()
		end
	end

	for i=1, 4 do
		local ent = ents.Create("prop_playergib")
		if ent:IsValid() then
			ent:SetPos(pos + VectorRand() * 12)
			ent:SetAngles(VectorRand():Angle())
			ent:SetGibType(math.random(3, #GAMEMODE.HumanGibs))
			ent:Spawn()
		end
	end
end

function GM:TryHumanPickup(pl, entity)
	if entity:IsValid() and not entity.m_NoPickup then
		local entclass = entity:GetClass()
		if (string.sub(entclass, 1, 12) == "prop_physics" or entclass == "func_physbox" or entity.HumanHoldable and entity:HumanHoldable(pl)) and pl:Team() == TEAM_HUMAN and not entity:IsNailed() and pl:Alive() and entity:GetMoveType() == MOVETYPE_VPHYSICS and entity:GetPhysicsObject():IsValid() and entity:GetPhysicsObject():GetMass() <= CARRY_MAXIMUM_MASS and entity:GetPhysicsObject():IsMoveable() and entity:OBBMins():Length() + entity:OBBMaxs():Length() <= CARRY_MAXIMUM_VOLUME then
			local holder, status = entity:GetHolder()
			if not holder and not pl:IsHolding() and (pl.NextHold or 0) <= CurTime() and pl:GetShootPos():Distance(entity:NearestPoint(pl:GetShootPos())) <= 64 and pl:GetGroundEntity() ~= entity then
				local newstatus = ents.Create("status_human_holding")
				if newstatus:IsValid() then
					pl.NextHold = CurTime() + 0.25
					pl.NextUnHold = CurTime() + 0.05
					newstatus:SetPos(pl:GetShootPos())
					newstatus:SetOwner(pl)
					newstatus:SetParent(pl)
					newstatus:SetObject(entity)
					newstatus:Spawn()
				end
			end
		end
	end
end

function GM:AddResources()
	resource.AddFile("resource/fonts/typenoskidi.ttf")

	for _, filename in pairs(file.Find("materials/zombiesurvival/*.vmt", "GAME")) do
		resource.AddFile("materials/zombiesurvival/"..filename)
	end

	for _, filename in pairs(file.Find("materials/zombiesurvival/killicons/*.vmt", "GAME")) do
		resource.AddFile("materials/zombiesurvival/killicons/"..filename)
	end

	resource.AddFile("materials/zombiesurvival/filmgrain/filmgrain.vmt")
	resource.AddFile("materials/zombiesurvival/filmgrain/filmgrain.vtf")

	for _, filename in pairs(file.Find("sound/zombiesurvival/*.wav", "GAME")) do
		resource.AddFile("sound/zombiesurvival/"..filename)
	end

	local _____, dirs = file.Find("sound/zombiesurvival/beats/*", "GAME")
	for _, dirname in pairs(dirs) do
		for __, filename in pairs(file.Find("sound/zombiesurvival/beats/"..dirname.."/*.wav", "GAME")) do
			resource.AddFile("sound/zombiesurvival/beats/"..dirname.."/"..filename)
		end
	end

	for _, filename in pairs(file.Find("sound/zombiesurvival/*.mp3", "GAME")) do
		resource.AddFile("sound/zombiesurvival/"..filename)
	end

//CUSTOM

	resource.AddFile("models/weapons/v_makarov/v_pist_maka.mdl")
	resource.AddFile("models/weapons/w_pist_maka.mdl")
	resource.AddFile("materials/weapons/v_makarov/grip.vmt")
	resource.AddFile("materials/weapons/v_makarov/grip.vtf")
	resource.AddFile("materials/weapons/v_makarov/main.vmt")
	resource.AddFile("materials/weapons/v_makarov/main.vtf")
	resource.AddFile("materials/weapons/v_makarov/sights.vtf")
	resource.AddFile("materials/weapons/v_makarov/sights.vmt")
	resource.AddFile("materials/weapons/w_pist_maka.mdl")
	resource.AddFile("materials/models/weapons/v_models/makarov/main.vtf")
	resource.AddFile("materials/models/weapons/v_models/makarov/main.vmt")
	resource.AddFile("materials/models/weapons/v_models/makarov/grip.vtf")
	resource.AddFile("materials/models/weapons/v_models/makarov/grip.vmt")
	resource.AddFile("materials/models/weapons/v_models/makarov/sights.vmt")
	resource.AddFile("materials/models/weapons/v_models/makarov/sights.vtf")
	resource.AddFile("materials/models/weapons/w_models/makarov/main.vtf")
	resource.AddFile("materials/models/weapons/w_models/makarov/main.vmt")
	resource.AddFile("materials/models/weapons/w_models/makarov/grip.vtf")
	resource.AddFile("materials/models/weapons/w_models/makarov/grip.vmt")
	resource.AddFile("materials/models/weapons/w_models/makarov/sights.vmt")
	resource.AddFile("materials/models/weapons/w_models/makarov/sights.vtf")
	resource.AddFile("weapons/handy/mak.wav")
	resource.AddFile("models/weapons/v_daring/v_deringer.mdl")
	resource.AddFile("models/weapons/w_deringer.mdl")
	resource.AddFile("materials/models/weapons/v_deringer/derringer.vmt")
	resource.AddFile("materials/models/weapons/v_deringer/derringer.vtf")
	resource.AddFile("materials/models/weapons/v_deringer/derringer_ref.vtf")
	resource.AddFile("materials/models/weapons/v_deringer/derringer_ref.vmt")
	resource.AddFile("materials/models/weapons/v_hands.vmt")
	resource.AddFile("materials/models/weapons/v_hands.vtf")
	resource.AddFile("materials/models/weapons/v_hands_exp.vtf")
	resource.AddFile("materials/models/weapons/v_hands_exp.vmt")
	resource.AddFile("materials/models/weapons/v_sleeve.vtf")
	resource.AddFile("materials/models/weapons/v_sleeve.vmt")
	resource.AddFile("sound/weapons/daring/daring.wav")
	resource.AddFile("sound/weapons/handy/mak.wav")
	resource.AddFile("sound/laststand.mp3")
	resource.AddFile("sound/humanslosefqd.mp3")
	resource.AddFile("sound/slamstand.mp3")


//CUSTOM

	resource.AddFile("materials/killicon/redeem.vtf")
	resource.AddFile("materials/killicon/redeem.vmt")
	resource.AddFile("materials/killicon/zs_axe.vtf")
	resource.AddFile("materials/killicon/zs_keyboard.vtf")
	resource.AddFile("materials/killicon/zs_sledgehammer.vtf")
	resource.AddFile("materials/killicon/zs_fryingpan.vtf")
	resource.AddFile("materials/killicon/zs_pot.vtf")
	resource.AddFile("materials/killicon/zs_plank.vtf")
	resource.AddFile("materials/killicon/zs_hammer.vtf")
	resource.AddFile("materials/killicon/zs_shovel.vtf")
	resource.AddFile("materials/killicon/zs_axe.vmt")
	resource.AddFile("materials/killicon/zs_keyboard.vmt")
	resource.AddFile("materials/killicon/zs_sledgehammer.vmt")
	resource.AddFile("materials/killicon/zs_fryingpan.vmt")
	resource.AddFile("materials/killicon/zs_pot.vmt")
	resource.AddFile("materials/killicon/zs_plank.vmt")
	resource.AddFile("materials/killicon/zs_hammer.vmt")
	resource.AddFile("materials/killicon/zs_shovel.vmt")
	resource.AddFile("models/weapons/v_hands.mdl")
	resource.AddFile("models/weapons/v_zombiearms.mdl")
	resource.AddFile("materials/models/weapons/v_zombiearms/Zombie_Classic_sheet.vmt")
	resource.AddFile("materials/models/weapons/v_zombiearms/Zombie_Classic_sheet.vtf")
	resource.AddFile("materials/models/weapons/v_zombiearms/Zombie_Classic_sheet_normal.vtf")
	resource.AddFile("materials/models/weapons/v_zombiearms/ghoulsheet.vmt")
	resource.AddFile("materials/models/weapons/v_zombiearms/ghoulsheet.vtf")
	resource.AddFile("models/weapons/v_fza.mdl")
	resource.AddFile("models/weapons/v_pza.mdl")
	resource.AddFile("materials/models/weapons/v_fza/fast_zombie_sheet.vmt")
	resource.AddFile("materials/models/weapons/v_fza/fast_zombie_sheet.vtf")
	resource.AddFile("materials/models/weapons/v_fza/fast_zombie_sheet_normal.vtf")
	resource.AddFile("models/weapons/v_annabelle.mdl")
	resource.AddFile("materials/models/weapons/w_annabelle/gun.vtf")
	resource.AddFile("materials/models/weapons/sledge.vtf")
	resource.AddFile("materials/models/weapons/sledge.vmt")
	resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vtf")
	resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vmt")
	resource.AddFile("materials/models/weapons/hammer2.vtf")
	resource.AddFile("materials/models/weapons/hammer2.vmt")
	resource.AddFile("materials/models/weapons/hammer.vtf")
	resource.AddFile("materials/models/weapons/hammer.vmt")
	resource.AddFile("models/weapons/w_sledgehammer.mdl")
	resource.AddFile("models/weapons/v_sledgehammer/v_sledgehammer.mdl")
	resource.AddFile("models/weapons/w_hammer.mdl")
	resource.AddFile("models/weapons/v_hammer/v_hammer.mdl")
	resource.AddFile("materials/models/weapons/v_pza/Blackcrab_sheet.vmt")
	resource.AddFile("materials/models/weapons/v_pza/Blackcrab_sheet.vtf")
	resource.AddFile("materials/models/weapons/v_pza/Blackcrab_sheet_normal.vtf")
	resource.AddFile("materials/models/weapons/v_pza/PoisonZombie_sheet_normal.vtf")
	resource.AddFile("materials/models/weapons/v_pza/PoisonZombie_sheet.vtf")
	resource.AddFile("materials/models/weapons/v_pza/PoisonZombie_sheet.vmt")


	resource.AddFile("models/weapons/v_aegiskit.mdl")

	resource.AddFile("materials/models/weapons/v_hand/armtexture.vmt")

	resource.AddFile("models/wraith_zsv1.mdl")
	for _, filename in pairs(file.Find("materials/models/wraith1/*.vmt", "GAME")) do
		resource.AddFile("materials/models/wraith1/"..filename)
	end
	for _, filename in pairs(file.Find("materials/models/wraith1/*.vtf", "GAME")) do
		resource.AddFile("materials/models/wraith1/"..filename)
	end

	resource.AddFile("models/weapons/v_supershorty/v_supershorty.mdl")
	resource.AddFile("models/weapons/w_supershorty.mdl")
	for _, filename in pairs(file.Find("materials/weapons/v_supershorty/*.vmt", "GAME")) do
		resource.AddFile("materials/weapons/v_supershorty/"..filename)
	end
	for _, filename in pairs(file.Find("materials/weapons/v_supershorty/*.vtf", "GAME")) do
		resource.AddFile("materials/weapons/v_supershorty/"..filename)
	end
	for _, filename in pairs(file.Find("materials/weapons/w_supershorty/*.vmt", "GAME")) do
		resource.AddFile("materials/weapons/w_supershorty/"..filename)
	end
	for _, filename in pairs(file.Find("materials/weapons/w_supershorty/*.vtf", "GAME")) do
		resource.AddFile("materials/weapons/w_supershorty/"..filename)
	end
	for _, filename in pairs(file.Find("materials/weapons/survivor01_hands/*.vmt", "GAME")) do
		resource.AddFile("materials/weapons/survivor01_hands/"..filename)
	end
	for _, filename in pairs(file.Find("materials/weapons/survivor01_hands/*.vtf", "GAME")) do
		resource.AddFile("materials/weapons/survivor01_hands/"..filename)
	end

	for _, filename in pairs(file.Find("materials/models/weapons/v_pza/*.*", "GAME")) do
		resource.AddFile("materials/models/weapons/v_pza/"..string.lower(filename))
	end

	resource.AddFile("sound/weapons/melee/golf club/golf_hit-01.wav")
	resource.AddFile("sound/weapons/melee/golf club/golf_hit-02.wav")
	resource.AddFile("sound/weapons/melee/golf club/golf_hit-03.wav")
	resource.AddFile("sound/weapons/melee/golf club/golf_hit-04.wav")
	resource.AddFile("sound/weapons/melee/crowbar/crowbar_hit-1.wav")
	resource.AddFile("sound/weapons/melee/crowbar/crowbar_hit-2.wav")
	resource.AddFile("sound/weapons/melee/crowbar/crowbar_hit-3.wav")
	resource.AddFile("sound/weapons/melee/crowbar/crowbar_hit-4.wav")
	resource.AddFile("sound/weapons/melee/shovel/shovel_hit-01.wav")
	resource.AddFile("sound/weapons/melee/shovel/shovel_hit-02.wav")
	resource.AddFile("sound/weapons/melee/shovel/shovel_hit-03.wav")
	resource.AddFile("sound/weapons/melee/shovel/shovel_hit-04.wav")
	resource.AddFile("sound/weapons/melee/frying_pan/pan_hit-01.wav")
	resource.AddFile("sound/weapons/melee/frying_pan/pan_hit-02.wav")
	resource.AddFile("sound/weapons/melee/frying_pan/pan_hit-03.wav")
	resource.AddFile("sound/weapons/melee/frying_pan/pan_hit-04.wav")
	resource.AddFile("sound/weapons/melee/keyboard/keyboard_hit-01.wav")
	resource.AddFile("sound/weapons/melee/keyboard/keyboard_hit-02.wav")
	resource.AddFile("sound/weapons/melee/keyboard/keyboard_hit-03.wav")
	resource.AddFile("sound/weapons/melee/keyboard/keyboard_hit-04.wav")


	resource.AddFile("materials/noxctf/sprite_bloodspray1.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray2.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray3.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray4.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray5.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray6.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray7.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray8.vmt")

	resource.AddFile("sound/"..tostring(LASTHUMANSOUND))
	resource.AddFile("sound/"..tostring(ALLLOSESOUND))
	resource.AddFile("sound/"..tostring(HUMANWINSOUND))
	resource.AddFile("sound/"..tostring(DEATHSOUND))
end

function GM:Initialize()
	self:RegisterPlayerSpawnEntities()
	self:AddResources()
	self:PrecacheResources()
	self:SetPantsMode(self.PantsMode, true)
	self:SetClassicMode(self:IsClassicMode(), true)

	game.ConsoleCommand("fire_dmgscale 1\nmp_flashlight 1\nsv_gravity 600\n")
end

function GM:IsClassicMode()
	return self.ClassicMode
end

function GM:ShowHelp(pl)
	pl:SendLua("GAMEMODE:ShowHelp()")
end

function GM:ShowTeam(pl)
	if pl:Team() == TEAM_UNDEAD then
		pl:ManualRedeem()
	else
		pl:SendLua(self:GetWave() > 0 and "GAMEMODE:OpenPointsShop()" or "MakepWorth()")
	end
end

function GM:ShowSpare1(pl)
	if pl:Team() == TEAM_UNDEAD then
		if self.PantsMode or self:IsClassicMode() then
			pl:SplitMessage(translate.ClientGet(pl, "no_class_switch_in_this_mode"))
		else
			pl:SendLua("GAMEMODE:OpenClassSelect()")
		end
	-- Suppressing this because... why the heck does this need to be a quick bind? Answer: it doesn't, so I moved this into the f1 menu.
	//else
		//pl:SendLua("MakepWeapons()")
	end
end

-- We are suppressing this because we want to use our own custom donor menu instead, and game options are already accessable via "showhelp" (f1).
/*function GM:ShowSpare2(pl)
	pl:SendLua("MakepOptions()")
end*/

function GM:SetupSpawnPoints()
	local ztab = ents.FindByClass("info_player_undead")
	ztab = table.Add(ztab, ents.FindByClass("info_player_zombie"))
	ztab = table.Add(ztab, ents.FindByClass("info_player_rebel"))

	local htab = ents.FindByClass("info_player_human")
	htab = table.Add(htab, ents.FindByClass("info_player_combine"))

	local mapname = string.lower(game.GetMap())
	-- Terrorist spawns are usually in some kind of house or a main base in CS_  in order to guard the hosties. Put the humans there.
	if string.sub(mapname, 1, 3) == "cs_" or string.sub(mapname, 1, 3) == "zs_" then
		ztab = table.Add(ztab, ents.FindByClass("info_player_counterterrorist"))
		htab = table.Add(htab, ents.FindByClass("info_player_terrorist"))
	else -- Otherwise, this is probably a DE_, ZM_, or ZH_ map. In DE_ maps, the T's spawn away from the main part of the map and are zombies in zombie plugins so let's do the same.
		ztab = table.Add(ztab, ents.FindByClass("info_player_terrorist"))
		htab = table.Add(htab, ents.FindByClass("info_player_counterterrorist"))
	end

	-- Add all the old ZS spawns from GMod9.
	for _, oldspawn in pairs(ents.FindByClass("gmod_player_start")) do
		if oldspawn.BlueTeam then
			table.insert(htab, oldspawn)
		else
			table.insert(ztab, oldspawn)
		end
	end

	-- You shouldn't play a DM map since spawns are shared but whatever. Let's make sure that there aren't team spawns first.
	if #htab == 0 then
		htab = ents.FindByClass("info_player_start")
		htab = table.Add(htab, ents.FindByClass("info_player_deathmatch")) -- Zombie Master
	end
	if #ztab == 0 then
		ztab = ents.FindByClass("info_player_start")
		ztab = table.Add(ztab, ents.FindByClass("info_zombiespawn")) -- Zombie Master
	end

	team.SetSpawnPoint(TEAM_UNDEAD, ztab)
	team.SetSpawnPoint(TEAM_HUMAN, htab)

	self.RedeemSpawnPoints = ents.FindByClass("info_player_redeemed")
	self.BossSpawnPoints = table.Add(ents.FindByClass("info_player_zombie_boss"), ents.FindByClass("info_player_undead_boss"))
end

//RUN AND GUN HERE

function GM:PlayerPointsAdded(pl, amount)
	if ( pl and pl:IsValid() and pl:Alive() and pl:Team() == TEAM_HUMAN ) then
		local new = pl:GetPoints()
		local old = new - amount
		for k, v in pairs(self.Wut) do
			if ( old < v and v <= new and !pl.WeaponsUnlocked[k] ) then
				pl:Give(self.WeaponUnlock[k][math.random(1,#self.WeaponUnlock[k])])
				pl.WeaponsUnlocked[k]=true
				break
			end
		end
		for k, v in pairs(self.Aut) do
			if ( old < v and v <= new and !pl.AmmoUnlocked[k] ) then
				self.Powerups["ammo"](pl)
				pl.AmmoUnlocked[k]=true
				break
			end
		end
		for k, v in pairs(self.Put) do
			if ( old < v and v <= new and !pl.PowerupsUnlocked[k] ) then
				self.Powerups[self.PowerupUnlock[k][math.random(1,#self.PowerupUnlock[k])]](pl)
				pl.PowerupsUnlocked[k]=true
				break
			end
		end
	end
end

--These are the powerups available as rewards
GM.Powerups = {}

--Gives HP
GM.Powerups["health"] = function(pl)
	local amount = 15
	pl:SetHealth(math.min(pl:Health() + amount, pl:GetMaxHealth()))
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_health", effectdata)
	pl:SendLua('surface.PlaySound("weapons/physcannon/physcannon_charge.wav")')
	pl:SendLua('GAMEMODE:Rewarded("+'..amount..' Health",-1)')
end

--Give Ammo
GM.Powerups["ammo"] = function(pl)
	local ammotype
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() then
		ammotype = "pistol"
	end
	if not ammotype then
		ammotype = wep:GetPrimaryAmmoTypeString()
		if not GAMEMODE.AmmoResupply[ammotype] then
			ammotype = "pistol"
		end
	end
	pl:GiveAmmo(GAMEMODE.AmmoResupply[ammotype] * 2, ammotype)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_ammo", effectdata)
	pl:SendLua('surface.PlaySound("weapons/physcannon/physcannon_charge.wav")')
	pl:SendLua('GAMEMODE:Rewarded("Extra Ammo",-1)')
end

--Regenerates HP
GM.Powerups["regen"] = function(pl)
	local amount = 1
	local delay = 1.2
	local times = 25
	GAMEMODE:RegenTimer(pl,amount)
	timer.Create("regen"..pl:UniqueID(), delay, times-1, function() GAMEMODE:RegenTimer(pl,amount) end)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_regen", effectdata)
	pl:SendLua('surface.PlaySound("weapons/physcannon/physcannon_charge.wav")')
	pl:SendLua('GAMEMODE:Rewarded("+'..(amount*times)..' Health Regeneration",-1)')
end

--Timer for regen
function GM:RegenTimer(pl, amount)
	if pl and pl:IsValid() and pl:Team() == TEAM_HUMAN then
		pl:SetHealth(math.min(pl:Health() + amount, pl:GetMaxHealth()))
	else
		timer.Destroy("regen"..pl:UniqueID())
	end
end

//END RUN AND GUN OK THX BYE

local weaponmodelstoweapon = {}
weaponmodelstoweapon["models/props/cs_office/computer_keyboard.mdl"] = "weapon_zs_keyboard"
weaponmodelstoweapon["models/props_c17/computer01_keyboard.mdl"] = "weapon_zs_keyboard"
weaponmodelstoweapon["models/props_c17/metalpot001a.mdl"] = "weapon_zs_pot"
weaponmodelstoweapon["models/props_interiors/pot02a.mdl"] = "weapon_zs_pan"
weaponmodelstoweapon["models/props_c17/metalpot002a.mdl"] = "weapon_zs_pan"
weaponmodelstoweapon["models/props_junk/shovel01a.mdl"] = "weapon_zs_shovel"
weaponmodelstoweapon["models/props/cs_militia/axe.mdl"] = "weapon_zs_axe"
weaponmodelstoweapon["models/props_c17/tools_wrench01a.mdl"] = "weapon_zs_hammer"
weaponmodelstoweapon["models/weapons/w_knife_t.mdl"] = "weapon_zs_knife"
weaponmodelstoweapon["models/weapons/w_knife_ct.mdl"] = "weapon_zs_knife"
weaponmodelstoweapon["models/weapons/w_crowbar.mdl"] = "weapon_zs_crowbar"
weaponmodelstoweapon["models/weapons/w_stunbaton.mdl"] = "weapon_zs_stunstick"
weaponmodelstoweapon["models/props_interiors/furniture_lamp01a.mdl"] = "weapon_zs_lamp"
function GM:InitPostEntity()
	gamemode.Call("InitPostEntityMap")

	pcall(gamemode.Call, "LoadMapEditorFile")

	gamemode.Call("SetupSpawnPoints")
	gamemode.Call("RemoveUnusedEntities")
	gamemode.Call("ReplaceMapWeapons")
	gamemode.Call("ReplaceMapAmmo")
	gamemode.Call("ReplaceMapBatteries")
	gamemode.Call("CreateZombieGas")
	gamemode.Call("SetupProps")

	for _, ent in pairs(ents.FindByClass("prop_ammo")) do ent.PlacedInMap = true end
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do ent.PlacedInMap = true end
	for _, ent in pairs(ents.FindByClass("prop_flashlightbattery")) do ent.PlacedInMap = true end

	local mapname = string.lower(game.GetMap())
	if string.find(mapname, "_obj_", 1, true) or string.find(mapname, "objective", 1, true) then
		self:SetDynamicSpawning(false)
		self.BossZombies = false
	end

	RunConsoleCommand("mapcyclefile", "mapcycle_zombiesurvival.txt")
end

local function ExplosiveProcessDamage(self, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() then
		local attackerteamid = attacker:GetTeamID()
		if attackerteamid ~= 0 then
			self:SetTeamID(attackerteamid)
			if attacker:IsPlayer() then
				self.Owner = attacker
			elseif attacker.Owner and attacker.Owner:IsPlayer() then
				self.Owner = attacker.Owner
			end
		end
	end
end
function GM:SetupProps()
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do
		local mdl = string.lower(ent:GetModel())
		if table.HasValue(self.BannedProps, mdl) then
			ent:Remove()
		elseif weaponmodelstoweapon[mdl] then
			local wep = ents.Create("prop_weapon")
			if wep:IsValid() then
				wep:SetPos(ent:GetPos())
				wep:SetAngles(ent:GetAngles())
				wep:SetWeaponType(weaponmodelstoweapon[mdl])
				wep:SetShouldRemoveAmmo(false)
				wep:Spawn()

				ent:Remove()
			end
		elseif ent:GetMaxHealth() == 1 and ent:Health() == 0 and ent:GetKeyValues().damagefilter ~= "invul" and ent:GetName() == "" then
			local health = math.min(2500, math.ceil((ent:OBBMins():Length() + ent:OBBMaxs():Length()) * 10))
			local hmul = self.PropHealthMultipliers[mdl]
			if hmul then
				health = health * hmul
			end

			ent.PropHealth = health
			ent.TotalHealth = health
		elseif string.find(string.lower(ent:GetModel()), "explosi", 1, true) then
			ent.ProcessDamage = ExplosiveProcessDamage
		else
			ent:SetHealth(math.ceil(ent:Health() * 3))
			ent:SetMaxHealth(ent:Health())
		end
	end
end

function GM:RemoveUnusedEntities()
	local destroying = ents.FindByClass("prop_ragdoll") -- Pointless lag.

	-- No NPC's in ZS.
	destroying = table.Add(destroying, ents.FindByClass("npc_maker"))
	destroying = table.Add(destroying, ents.FindByClass("npc_template_maker"))
	destroying = table.Add(destroying, ents.FindByClass("npc_maker_template"))
	destroying = table.Add(destroying, ents.FindByClass("npc_zombie"))
	destroying = table.Add(destroying, ents.FindByClass("npc_zombie_torso"))
	destroying = table.Add(destroying, ents.FindByClass("npc_fastzombie"))
	destroying = table.Add(destroying, ents.FindByClass("npc_headcrab"))
	destroying = table.Add(destroying, ents.FindByClass("npc_headcrab_fast"))
	destroying = table.Add(destroying, ents.FindByClass("npc_headcrab_black"))
	destroying = table.Add(destroying, ents.FindByClass("npc_poisonzombie"))

	destroying = table.Add(destroying, ents.FindByClass("item_ammo_crate")) -- Such a headache. Just remove them all.
	destroying = table.Add(destroying, ents.FindByClass("item_suitcharger")) -- Shouldn't exist.
	for _, ent in pairs(destroying) do
		ent:Remove()
	end
end

function GM:ReplaceMapWeapons()
	for _, ent in pairs(ents.FindByClass("weapon_*")) do
		if string.sub(ent:GetClass(), 1, 10) == "weapon_zs_" then
			local wep = ents.Create("prop_weapon")
			if wep:IsValid() then
				wep:SetPos(ent:GetPos())
				wep:SetAngles(ent:GetAngles())
				wep:SetWeaponType(ent:GetClass())
				wep:SetShouldRemoveAmmo(false)
				wep:Spawn()
				wep.IsPreplaced = true
			end
		end

		ent:Remove()
	end
end

local ammoreplacements = {
	["item_ammo_357"] = "357",
	["item_ammo_357_large"] = "357",
	["item_ammo_pistol"] = "pistol",
	["item_ammo_pistol_large"] = "pistol",
	["item_ammo_buckshot"] = "buckshot",
	["item_ammo_ar2"] = "ar2",
	["item_ammo_ar2_large"] = "ar2",
	["item_ammo_ar2_altfire"] = "ar2",
	["item_ammo_crossbow"] = "xbowbolt",
	["item_ammo_smg1"] = "smg1",
	["item_ammo_smg1_large"] = "smg1",
	["item_box_buckshot"] = "buckshot"
}
function GM:ReplaceMapAmmo()
	for classname, ammotype in pairs(ammoreplacements) do
		for _, ent in pairs(ents.FindByClass(classname)) do
			local newent = ents.Create("prop_ammo")
			if newent:IsValid() then
				newent:SetAmmoType(ammotype)
				newent.PlacedInMap = true
				newent:SetPos(ent:GetPos())
				newent:SetAngles(ent:GetAngles())
				newent:Spawn()
				newent:SetAmmo(self.AmmoCache[ammotype] or 1)
			end
			ent:Remove()
		end
	end

	for _, ent in pairs(ents.FindByClass("item_item_crate")) do
		ent:Remove()
	end
end

function GM:ReplaceMapBatteries()
	for _, ent in pairs(ents.FindByClass("item_battery")) do
		ent:Remove()
	end
end

function GM:CreateZombieGas()
	if NOZOMBIEGASSES then return end

	local humanspawns = team.GetSpawnPoint(TEAM_HUMAN)

	for _, spawn in pairs(team.GetSpawnPoint(TEAM_UNDEAD)) do
		local gasses = ents.FindByClass("zombiegasses")
		local numgasses = #gasses
		if 4 < numgasses then
			break
		elseif math.random(1, 4) == 1 or numgasses < 1 then
			local spawnpos = spawn:GetPos()
			local nearhum = false
			for _, humspawn in pairs(humanspawns) do
				if humspawn:GetPos():Distance(spawnpos) < 128 then
					nearhum = true
					break
				end
			end
			if not nearhum then
				for _, humspawn in pairs(gasses) do
					if humspawn:GetPos():Distance(spawnpos) < 128 then
						nearhum = true
						break
					end
				end
			end
			if not nearhum then
				local ent = ents.Create("zombiegasses")
				if ent:IsValid() then
					ent:SetPos(spawnpos)
					ent:Spawn()
				end
			end
		end
	end
end

function GM:CheckDynamicSpawnHR(ent)
	if ent and ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_UNDEAD then
		ent.DynamicSpawnedOn = ent.DynamicSpawnedOn + 1
	end
end

local playermins = Vector(-17, -17, 0)
local playermaxs = Vector(17, 17, 4)
local LastSpawnPoints = {}

function GM:PlayerSelectSpawn(pl)
	local spawninplayer = false
	local teamid = pl:Team()
	local tab
	local epicenter
	if pl.m_PreRedeem and teamid == TEAM_HUMAN and #self.RedeemSpawnPoints >= 1 then
		tab = self.RedeemSpawnPoints
	elseif teamid == TEAM_UNDEAD then
		if pl:GetZombieClassTable().Boss and #self.BossSpawnPoints >= 1 then
			tab = self.BossSpawnPoints
		elseif self.DynamicSpawning and CurTime() >= self:GetWaveStart() + 1 then -- If we're a bit in the wave then we can spawn on top of heavily dense groups with no humans looking at us.
			local dyn = pl.ForceDynamicSpawn
			if dyn then
				pl.ForceDynamicSpawn = nil
				if self:DynamicSpawnIsValid(dyn) then
					self:CheckDynamicSpawnHR(dyn)
					return dyn
				end

				epicenter = dyn:GetPos() -- Ok, at least skew our epicenter to what they tried to spawn at.
				tab = table.Copy(team.GetSpawnPoint(TEAM_UNDEAD))
				local dynamicspawns = self:GetDynamicSpawns(pl)
				if #dynamicspawns > 0 then
					spawninplayer = true
					table.Add(tab, dynamicspawns)
				end
			else
				tab = table.Copy(team.GetSpawnPoint(TEAM_UNDEAD))
				local dynamicspawns = self:GetDynamicSpawns(pl)
				if #dynamicspawns > 0 then
					spawninplayer = true
					table.Add(tab, dynamicspawns)
				end
			end
		end
	end

	if not tab or #tab == 0 then tab = team.GetSpawnPoint(teamid) or {} end

	local count = #tab
	if count > 0 then
		local potential = {}

		for _, spawn in pairs(tab) do
			if spawn:IsValid() and not spawn.Disabled and (spawn:IsPlayer() or spawn ~= LastSpawnPoints[teamid] or #tab == 1) and spawn:IsInWorld() then
				local blocked
				local spawnpos = spawn:GetPos()
				for _, ent in pairs(ents.FindInBox(spawnpos + playermins, spawnpos + playermaxs)) do
					if ent:IsPlayer() and not spawninplayer or string.sub(ent:GetClass(), 1, 5) == "prop_" then
						blocked = true
						break
					end
				end
				if not blocked then
					potential[#potential + 1] = spawn
				end
			end
		end

		if #potential > 0 then
			local spawn = teamid == TEAM_UNDEAD and self:GetClosestSpawnPoint(potential, epicenter or self:GetTeamEpicentre(TEAM_HUMAN)) or potential[math.random(1, #potential)]
			LastSpawnPoints[teamid] = spawn
			self:CheckDynamicSpawnHR(spawn)
			return spawn
		end
	end

	return LastSpawnPoints[teamid] or #tab > 0 and tab[math.random(#tab)] or pl
end

local function BossZombieSort(a, b)
	local ascore = a.BarricadeDamage * 0.1 + a.DamageDealt[TEAM_UNDEAD]
	local bscore = b.BarricadeDamage * 0.1 + b.DamageDealt[TEAM_UNDEAD]
	if ascore == bscore then
		return a:Deaths() < b:Deaths()
	end

	return ascore > bscore
end
function GM:SpawnBossZombie()
	local livingbosses = 0
	local zombies = {}
	local bosses = {}
	for _, ent in pairs(team.GetPlayers(TEAM_UNDEAD)) do
		if ent:GetZombieClassTable().Boss and ent:Alive() then
			livingbosses = livingbosses + 1
			table.insert(bosses, ent:GetZombieClassTable().Index)
			if livingbosses >= math.ceil(#player.GetAll()/6)  then return end
		else
			table.insert(zombies, ent)
		end
	end
	table.sort(zombies, BossZombieSort)

	local bossplayer = zombies[1]
	if not bossplayer then return end

	local bossclasses = {}
	for _, classtable in pairs(GAMEMODE.ZombieClasses) do
		if classtable.Boss then
			table.insert(bossclasses, classtable.Index)
		end
	end

	if #bossclasses == 0 then return end

	local bossesopen = {}
	for _, classindex in pairs(bossclasses) do
		if !table.HasValue(bosses, classindex) then
			table.insert(bossesopen, classindex)
		end
	end
	if #bossesopen==0 then bossesopen = table.Copy(bossclasses) end

	self.LastBossZombieSpawned = self:GetWave()

	local desired = bossplayer:GetInfo("zs_bossclass") or ""
	local bossindex
	for _, classindex in pairs(bossesopen) do
		local classtable = GAMEMODE.ZombieClasses[classindex]
		if string.lower(classtable.Name) == string.lower(desired) then
			bossindex = classindex
			break
		end
	end
	bossindex = bossindex or bossesopen[math.random(#bossesopen)]

	local curclass = bossplayer.DeathClass or bossplayer:GetZombieClass()
	bossplayer:KillSilent()
	bossplayer:SetZombieClass(bossindex)
	bossplayer:DoHulls(bossindex, TEAM_UNDEAD)
	bossplayer.DeathClass = nil
	bossplayer:UnSpectateAndSpawn()
	bossplayer.DeathClass = curclass

	umsg.Start("bosszombiespawned")
		umsg.Entity(bossplayer)
		umsg.Short(bossindex)
	umsg.End()
end

local NextTick = 0
function GM:Think()
	local time = CurTime()

	if not self.RoundEnded then
		if self:GetWaveActive() then
			if self:GetWaveEnd() <= time and self:GetWaveEnd() ~= -1 then
				gamemode.Call("SetWaveActive", false)
			end
		elseif self:GetWaveStart() ~= -1 then
			if self:GetWaveStart() <= time then
				gamemode.Call("SetWaveActive", true)
			elseif self.BossZombies and not self.PantsMode and not self:IsClassicMode()
			and self.LastBossZombieSpawned ~= self:GetWave() and self:GetWave() > 0 and self:GetWaveStart() - 10 <= time and not self.RoundEnded
			and (self.BossZombiePlayersRequired <= 0 or #player.GetAll() >= self.BossZombiePlayersRequired) then
				self:SpawnBossZombie()
			end
		end
	end

	local humans = team.GetPlayers(TEAM_HUMAN)
	for _, pl in pairs(humans) do
		if pl:Team() == TEAM_HUMAN then
			if pl:GetBarricadeGhosting() then
				pl:BarricadeGhostingThink()
			end

			if pl.m_PointQueue >= 1 and time >= pl.m_LastDamageDealt + 3 then
				pl:PointCashOut((pl.m_LastDamageDealtPosition or pl:GetPos()) + Vector(0, 0, 32), FM_NONE)
			end
		end
	end

	if NextTick <= time then
		NextTick = time + 1

		for _, pl in pairs(humans) do
			if pl:Alive() then
				if pl:WaterLevel() >= 3 and not (pl.status_drown and pl.status_drown:IsValid()) then
					pl:GiveStatus("drown")
				end

				if self:GetWave() >= 1 and time >= pl.BonusDamageCheck + 60 then
					pl.BonusDamageCheck = time
					pl:AddPoints(4)
					pl:PrintTranslatedMessage(HUD_PRINTCONSOLE, "minute_points_added", 4)
					if pl.BuffRegenerative then
						pl:SetHealth(math.min(pl:GetMaxHealth(), pl:Health() + 5))
					end
				end
			end
		end
	end
end

function GM:LastBite(victim, attacker)
	LAST_BITE = attacker
end

function GM:CalculateInfliction(victim, attacker)
	if self.RoundEnded or self:GetWave() == 0 then return self.CappedInfliction end

	local players = 0
	local zombies = 0
	local humans = 0
	for _, pl in pairs(player.GetAll()) do
		if not pl.Disconnecting then
			if pl:Team() == TEAM_UNDEAD then
				zombies = zombies + 1
			else
				humans = humans + 1
			end

			players = players + 1
		end
	end

	if players == 0 then return self.CappedInfliction end

	local infliction = math.max(zombies / players, self.CappedInfliction)
	self.CappedInfliction = infliction

	if humans == 1 and 2 < zombies then
		gamemode.Call("LastHuman", team.GetPlayers(TEAM_HUMAN)[1])
	elseif 1 <= infliction then
		infliction = 1

		gamemode.Call("EndRound", TEAM_UNDEAD)

		if attacker and attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD and attacker ~= victim then
			gamemode.Call("LastBite", victim, attacker)
		end
	end

	for k, v in ipairs(self.ZombieClasses) do
		if v.Infliction and infliction >= v.Infliction and not self:IsClassUnlocked(v.Name) then
			v.Unlocked = true

			if not self.PantsMode and not self:IsClassicMode() then
				if not v.Locked then
					for _, pl in pairs(player.GetAll()) do
						pl:SplitMessage(translate.ClientFormat(pl, "infliction_reached", v.Infliction * 100), "<font=ZSHUDFontSmall><color=white>"..translate.ClientFormat(pl, "x_unlocked", v.Name))
					end
				end
			end
		end
	end

	for _, ent in pairs(ents.FindByClass("logic_infliction")) do
		if ent.Infliction <= infliction then
			ent:Input("oninflictionreached", NULL, NULL, infliction)
		end
	end

	return infliction
end

function GM:OnNPCKilled(ent, attacker, inflictor)
end

function GM:LastHuman(pl)
	if not LASTHUMAN then
		if pl and pl:IsValid() then
			BroadcastLua("gamemode.Call(\"LastHuman\", Entity("..pl:EntIndex().."))")
		else
			BroadcastLua("gamemode.Call(\"LastHuman\")")
		end
		LASTHUMAN = true
	end

	self.TheLastHuman = pl

	for _, ent in pairs(ents.FindByClass("logic_infliction")) do
		ent:Input("onlasthuman", pl, pl, pl and pl:IsValid() and pl:EntIndex() or -1)
	end
end

function GM:PlayerHealedTeamMember(pl, other, health, wep)
	if self:GetWave() == 0 then return end

	pl.HealedThisRound = pl.HealedThisRound + health
	pl.CarryOverHealth = (pl.CarryOverHealth or 0) + health

	local hpperpoint = self.MedkitPointsPerHealth
	if hpperpoint <= 0 then return end

	local points = math.floor(pl.CarryOverHealth / hpperpoint)

	if 1 <= points then
		pl:AddPoints(points)

		pl.CarryOverHealth = pl.CarryOverHealth - points * hpperpoint

		umsg.Start("HealedOtherPlayer", pl)
			umsg.Entity(other)
			umsg.Short(points)
		umsg.End()
	end
end

function GM:ObjectPackedUp(pack, packer, owner)
end

function GM:PlayerRepairedObject(pl, other, health, wep)
	if self:GetWave() == 0 then return end

	pl.RepairedThisRound = pl.RepairedThisRound + health
	pl.CarryOverRepair = (pl.CarryOverRepair or 0) + health

	local hpperpoint = self.RepairPointsPerHealth
	if hpperpoint <= 0 then return end

	local points = math.floor(pl.CarryOverRepair / hpperpoint)

	if 1 <= points then
		pl:AddPoints(points)

		pl.CarryOverRepair = pl.CarryOverRepair - points * hpperpoint

		umsg.Start("RepairedObject", pl)
			umsg.Entity(other)
			umsg.Short(points)
		umsg.End()
	end
end

function GM:CacheHonorableMentions()
	if self.CachedHMs then return end

	self.CachedHMs = {}

	for i, hm in ipairs(self.HonorableMentions) do
		if hm.GetPlayer then
			local pl, magnitude = hm.GetPlayer(self)
			if pl then
				self.CachedHMs[i] = {pl:EntIndex(), i, magnitude or 0}
			end
		end
	end

	gamemode.Call("PostDoHonorableMentions")
end

function GM:DoHonorableMentions(filter)
	self:CacheHonorableMentions()

	for i, tab in pairs(self.CachedHMs) do
		umsg.Start("honmention", filter)
			umsg.Short(tab[1])
			umsg.Short(tab[2])
			umsg.Long(tab[3])
		umsg.End()
	end
end

function GM:PostDoHonorableMentions()
end

function GM:PostEndRound(winner)
end

-- Custom random map loader, by Mwr247
function GetNextMap()
	--local maplist = string.Explode("\n",string.Replace(string.Trim(GetConVarString("mapcyclefile"),"\n"),"\r",""))
	local tempmap=game.GetMapNext()
	if evolve and evolve.mapcycle then
		local min=math.Clamp(math.ceil(table.Count(player.GetAll())/16),1,3);
		local max=math.Clamp(math.ceil((table.Count(player.GetAll())+8)/16),1,3);
		local cutoff = evolve:Time() - 60 * 60 * 2
    local maplist = table.Copy(evolve.mapcycle)
    local mapcycle = {}
    for k,v in pairs(evolve.mapcycle) do
      local pick = math.random(1, #maplist)
      table.insert(mapcycle, maplist[pick])
      table.remove(maplist, pick)
    end
		for k,v in pairs(mapcycle) do
			if ( v[1] == game.GetMap() or tonumber(v[2]) == 0 or !file.Exists("maps/"..v[1]..".bsp","GAME") ) then continue end
			if ( tonumber(v[3])>=min and tonumber(v[4])<=max) and ((tonumber(v[4])>=min and tonumber(v[4])<=max) or tonumber(v[4])==0) then
				if (tonumber(v[7])<cutoff) then
					table.insert(maplist, v[1])
				end
			end
		end
    tempmap = maplist[ math.random( #maplist ) ]
    print("Evolve++ mapcycle(" .. min .. ", " .. max .. ") map chosen (of " .. #maplist .. "): " .. tempmap)
	end
	return tempmap
end

function LoadMap(nextmap)
	RunConsoleCommand("changelevel", nextmap)
end

-- You can override or hook and return false in case you have your own map change system.
local function RealMap(map)
	return string.match(map, "(.+)%.bsp")
end
function GM:LoadNextMap()
	timer.Simple(15, game.LoadNextMap)
	timer.SimpleEx(20, RunConsoleCommand, "changelevel", game.GetMap())

	if file.Exists(GetConVarString("mapcyclefile"), "GAME") then
		timer.Simple(15, function() game.LoadNextMap() end)
	else
		local maps = file.Find("maps/zs_*.bsp", "GAME")
		table.sort(maps)
		if #maps > 0 then
			local currentmap = game.GetMap()
			for i, map in ipairs(maps) do
				local lowermap = string.lower(map)
				local realmap = RealMap(lowermap)
				if realmap == currentmap then
					if maps[i+1] then
						local nextmap = RealMap(maps[i + 1])
						if nextmap then
							RunConsoleCommand("changelevel", nextmap)
						end
					else
						local nextmap = RealMap(maps[1])
						if nextmap then
							RunConsoleCommand("changelevel", nextmap)
						end
					end

					break
				end
			end
		end
	end
end

function GM:PreRestartRound()
	for _, pl in pairs(player.GetAll()) do
		pl:StripWeapons()
		pl:Spectate(OBS_MODE_ROAMING)
	end
end

GM.CurrentRound = 1
function GM:RestartRound()
	self.CurrentRound = self.CurrentRound + 1

	self:RestartLua()
	self:RestartGame()

	BroadcastLua("GAMEMODE:RestartRound()")
end

GM.DynamicSpawning = true
GM.CappedInfliction = 0
GM.StartingZombie = {}
GM.CheckedOut = {}
GM.PreviouslyDied = {}
GM.StoredUndeadFrags = {}

function GM:RestartLua()
	self.RoundEnded = nil
	self.CachedHMs = nil
	self.TheLastHuman = nil
	self.LastBossZombieSpawned = nil

	self.CappedInfliction = 0

	self.StartingZombie = {}
	self.CheckedOut = {}
	self.PreviouslyDied = {}
	self.StoredUndeadFrags = {}

	ROUNDWINNER = nil
	LAST_BITE = nil
	LASTHUMAN = nil

	FindMetaTable("Player").GetMeleeFilter = FindMetaTable("Player").GetMeleeFilterOld

	if hook.GetTable()["PlayerShouldTakeDamage"] then hook.Remove("PlayerShouldTakeDamage", "EndRoundShouldTakeDamage") end
	if hook.GetTable()["CanPlayerSuicide"] then hook.Remove("CanPlayerSuicide", "EndRoundCanPlayerSuicide") end
	self.PlayerDeathThink = self._PlayerDeathThink

	self:RevertZombieClasses()
end

-- I don't know.
local function CheckBroken()
	for _, pl in pairs(player.GetAll()) do
		if pl:Alive() and (pl:Health() <= 0 or pl:GetObserverMode() ~= OBS_MODE_NONE or pl:OBBMaxs().x ~= 16) then
			pl:SetObserverMode(OBS_MODE_NONE)
			pl:UnSpectateAndSpawn()
		end
	end
end

local function RestartGame(self)
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("prop_ammo")) do
		ent:Remove()
	end

	self:SetWave(0)
	self:SetWaveStart(CurTime() + self.WaveZeroLength)
	self:SetWaveEnd(CurTime() + self.WaveZeroLength + self:GetWaveOneLength())
	self:SetWaveActive(false)
	SetGlobalInt("numwaves", nil)

	timer.Create("CheckBroken", 10, 1, CheckBroken)

	game.CleanUpMap()
	gamemode.Call("InitPostEntity")

	for _, pl in pairs(player.GetAll()) do
		pl:UnSpectateAndSpawn()
		gamemode.Call("PlayerInitialSpawn", pl)
		gamemode.Call("PlayerReady", pl)
	end
end

function GM:RestartGame()
	for _, pl in pairs(player.GetAll()) do
		pl:StripWeapons()
		pl:StripAmmo()
		pl:SetFrags(0)
		pl:SetDeaths(0)
		pl:SetPoints(0)
		pl:ChangeTeam(TEAM_HUMAN)
		pl:DoHulls()
		pl:SetZombieClass(self.DefaultZombieClass)
		pl.DeathClass = nil
		pl.WeaponsUnlocked = {}
		pl.AmmoUnlocked = {}
		pl.PowerupsUnlocked = {}
	end

	self:SetWave(0)
	self:SetWaveStart(CurTime() + self.WaveZeroLength)
	self:SetWaveEnd(CurTime() + self.WaveZeroLength + self:GetWaveOneLength())
	self:SetWaveActive(false)
	SetGlobalInt("numwaves", nil)

	timer.SimpleEx(0.25, RestartGame, self)
end

function GM:InitPostEntityMap()
end

local function EndRoundMeleeFilter(self) return {self} end
local function EndRoundPlayerShouldTakeDamage(pl, attacker) return pl:Team() ~= TEAM_HUMAN or not attacker:IsPlayer() end
local function EndRoundPlayerCanSuicide(pl) return pl:Team() ~= TEAM_HUMAN end
local function EndRoundPlayerDeathThink() end

local function EndRoundSetupPlayerVisibility(pl)
	if GAMEMODE.LastHumanPosition and GAMEMODE.RoundEnded then
		AddOriginToPVS(GAMEMODE.LastHumanPosition)
	else
		hook.Remove("SetupPlayerVisibility", "EndRoundSetupPlayerVisibility")
	end
end

function GM:EndRound(winner)
	if self.RoundEnded then return end
	self.RoundEnded = true
	self.RoundEndedTime = CurTime()
	ROUNDWINNER = winner

	game.SetTimeScale(0.25)
	timer.Simple(2, function() game.SetTimeScale(1) end)

	hook.Add("SetupPlayerVisibility", "EndRoundSetupPlayerVisibility", EndRoundSetupPlayerVisibility)

	local nextmap = GetNextMap()
	if self:ShouldRestartRound() then
		timer.SimpleEx(self.EndGameTime - 3, gamemode.Call, "PreRestartRound")
		timer.SimpleEx(self.EndGameTime, gamemode.Call, "RestartRound")
	else
		timer.SimpleEx(self.EndGameTime, LoadMap, nextmap)
		timer.SimpleEx(self.EndGameTime+5, gamemode.Call, "LoadNextMap")
	end

	-- Get rid of some lag.
	for _, ent in pairs(ents.FindByClass("prop_ammo")) do ent:Remove() end
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do ent:Remove() end

	timer.SimpleEx(5, gamemode.Call, "DoHonorableMentions")

	FindMetaTable("Player").GetMeleeFilter = EndRoundMeleeFilter
	if winner == TEAM_HUMAN then
		self.LastHumanPosition = nil
		hook.Add("PlayerShouldTakeDamage", "EndRoundShouldTakeDamage", EndRoundPlayerShouldTakeDamage)
		hook.Add("CanPlayerSuicide", "EndRoundCanPlayerSuicide", EndRoundPlayerCanSuicide)
	elseif winner == TEAM_UNDEAD then
		hook.Add("PlayerShouldTakeDamage", "EndRoundShouldTakeDamage", EndRoundPlayerCanSuicide)
	end
	self.PlayerDeathThink = EndRoundPlayerDeathThink
	--game.GetMapNext()
	if self:ShouldRestartRound() then
		BroadcastLua("gamemode.Call(\"EndRound\", "..winner..", \"\")")
	else
		BroadcastLua("gamemode.Call(\"EndRound\", "..winner..", \""..nextmap.."\")")
	end

	if winner == TEAM_HUMAN then
		for _, ent in pairs(ents.FindByClass("logic_winlose")) do
			ent:Input("onwin")
		end
	else
		for _, ent in pairs(ents.FindByClass("logic_winlose")) do
			ent:Input("onlose")
		end
	end

	gamemode.Call("PostEndRound", winner)

	self:SetWaveStart(CurTime() + self.EndGameTime)
end

function GM:PlayerReady(pl)
	if not pl:IsValid() then return end
	pl.StartingWorth = self.StartingWorth

	self:FullGameUpdate(pl)
	pl:UpdateAllZombieClasses()

	local classid = pl:GetZombieClass()
	pl:SetZombieClass(classid, true, pl)

	if pl:Team() == TEAM_UNDEAD then
		-- This is just so they get updated on what class they are and have their hulls set up right.
		pl:DoHulls(classid, TEAM_UNDEAD)
	elseif self:GetWave() <= 0 and pl.StartingWorth > 0 and not self.StartingLoadout then
		-- Donor worth adder
		if evolve and evolve.donors and evolve:IsDonor( pl ) then
			pl.StartingWorth = self.StartingWorth + 10
			pl:SendLua("GAMEMODE.StartingWorth="..tostring(pl.StartingWorth))
		end
		pl:SendLua("MakepWorth()")
	else
		gamemode.Call("GiveDefaultOrRandomEquipment", pl)
	end

	if self.RoundEnded then
		pl:SendLua("gamemode.Call(\"EndRound\", "..tostring(ROUNDWINNER)..", \""..game.GetMapNext().."\")")
		gamemode.Call("DoHonorableMentions", pl)
	end

	if self.OverrideStartingWorth then
		pl:SendLua("GAMEMODE.StartingWorth="..tostring(pl.StartingWorth))
	end

	if pl:GetInfo("zs_noredeem") == "1" then
		pl.NoRedeeming = true
	end
	if pl:GetInfo("zs_alwaysvolunteer") == "1" then
		pl:SetNetworkedBool("pvolunteer", true)
	end

	if self:IsClassicMode() then
		pl:SendLua("SetGlobalBool(\"classicmode\", true)")
	end
end

function GM:FullGameUpdate(pl)
	umsg.Start("reczsgamestate", pl)
		umsg.Short(self:GetWave())
		umsg.Float(self:GetWaveStart())
		umsg.Float(self:GetWaveEnd())
	umsg.End()
end

concommand.Add("PostPlayerInitialSpawn", function(sender, command, arguments)
	if not sender.PostPlayerInitialSpawn then
		sender.PostPlayerInitialSpawn = true

		gamemode.Call("PlayerReady", sender)
	end
end)

local playerheight = Vector(0, 0, 72)
local playermins = Vector(-17, -17, 0)
local playermaxs = Vector(17, 17, 4)
local function groupsort(a, b)
	return #a > #b
end
function GM:AttemptHumanDynamicSpawn(pl)
	if pl:IsValid() and pl:IsPlayer() and pl:Alive() and pl:Team() == TEAM_HUMAN and self.DynamicSpawning then
		local groups = self:GetTeamRallyGroups(TEAM_HUMAN)
		if #groups > 0 then
			table.sort(groups, groupsort)
			local group = groups[1]

			local allplayers = team.GetPlayers(TEAM_HUMAN)
			for _, otherpl in pairs(group) do
				if otherpl ~= pl then
					local pos = otherpl:GetPos() + Vector(0, 0, 1)
					if otherpl:Alive() and otherpl:GetMoveType() == MOVETYPE_WALK and not util.TraceHull({start = pos, endpos = pos + playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID, filter = allplayers}).Hit then
						pl:SetPos(otherpl:GetPos())
						return true
					end
				end
			end
		end
	end

	return false
end

function GM:PlayerInitialSpawn(pl)
	pl:SprintDisable()
	if pl:KeyDown(IN_WALK) then
		pl:ConCommand("-walk")
	end

	pl:SetCanWalk(false)
	pl:SetCanZoom(false)
	pl:SetNoCollideWithTeammates(true)
	pl:SetCustomCollisionCheck(true)

	pl.ZombiesKilled = 0
	pl.ZombiesKilledAssists = 0
	pl.BrainsEaten = 0

	pl.ResupplyBoxUsedByOthers = 0

	pl.WaveJoined = self:GetWave()

	pl.CrowKills = 0
	pl.CrowVsCrowKills = 0
	pl.CrowBarricadeDamage = 0
	pl.BarricadeDamage = 0
	pl.DynamicSpawnedOn = 0

	pl.NextPainSound = 0

	pl.BonusDamageCheck = 0

	pl.m_DrawViewModel = true
	pl.m_DrawWorldModel = true

	pl.DamageDealt = {}
	pl.DamageDealt[TEAM_UNDEAD] = 0
	pl.DamageDealt[TEAM_HUMAN] = 0

	pl.HealedThisRound = 0
	pl.CarryOverHealth = 0
	pl.RepairedThisRound = 0
	pl.CarryOverRepair = 0
	pl.PointsCommission = 0
	pl.CarryOverCommision = 0

	local nosend = not pl.PostPlayerInitialSpawn
	pl.HumanSpeedAdder = nil
	pl.HumanSpeedAdder = nil
	pl.HumanRepairMultiplier = nil
	pl.HumanHealMultiplier = nil
	pl.BuffResistant = nil
	pl.BuffRegenerative = nil
	pl.IsWeak = nil
	pl.HumanSpeedAdder = nil
	pl:SetPalsy(false, nosend)
	pl:SetHemophilia(false, nosend)
	pl:SetUnlucky(false)
	pl.Clumsy = nil
	pl.NoGhosting = nil
	pl.DamageVulnerability = nil
	pl.WeaponsUnlocked = {}
	pl.AmmoUnlocked = {}
	pl.PowerupsUnlocked = {}

	local uniqueid = pl:UniqueID()

	if table.HasValue(self.FanList, uniqueid) then
		pl.DamageVulnerability = (pl.DamageVulnerability or 1) + 10
		pl:PrintMessage(HUD_PRINTTALK, "Thanks for being a fan of Zombie Survival!")
	end

	if self.PreviouslyDied[uniqueid] then
		-- They already died and reconnected.
		pl:ChangeTeam(TEAM_UNDEAD)
	elseif LASTHUMAN then
		-- Joined during last human.
		pl.SpawnedTime = CurTime()
		pl:ChangeTeam(TEAM_UNDEAD)
	elseif self:GetWave() <= 0 then
		-- Joined during ready phase.
		pl.SpawnedTime = CurTime()
		pl:ChangeTeam(TEAM_HUMAN)
	elseif self:GetNumberOfWaves() == -1 or self.NoNewHumansWave <= self:GetWave() or team.NumPlayers(TEAM_UNDEAD) >= team.NumPlayers(TEAM_HUMAN) or team.NumPlayers(TEAM_UNDEAD) == 0 and 1 <= team.NumPlayers(TEAM_HUMAN) then -- Joined during game, no zombies, some humans or joined past the deadline.
		pl:ChangeTeam(TEAM_UNDEAD)
		self.PreviouslyDied[uniqueid] = CurTime()
	else
		-- Joined past the ready phase but before the deadline.
		pl.SpawnedTime = CurTime()
		pl:ChangeTeam(TEAM_HUMAN)
		if self.DynamicSpawning then
			timer.SimpleEx(0, self.AttemptHumanDynamicSpawn, self, pl)
		end
	end

	if pl:Team() == TEAM_UNDEAD and not self:GetWaveActive() and self.ZombieClasses["Crow"] then
		pl:SetZombieClass(self.ZombieClasses["Crow"].Index)
		pl.DeathClass = self.DefaultZombieClass
	else
		pl:SetZombieClass(self.DefaultZombieClass)
	end

	if pl:Team() == TEAM_UNDEAD and self.StoredUndeadFrags[uniqueid] then
		pl:SetFrags(self.StoredUndeadFrags[uniqueid])
		self.StoredUndeadFrags[uniqueid] = nil
	end
end

function GM:PlayerRedeemed(pl, silent, noequip)
	if not silent then
		umsg.Start("PlayerRedeemed")
			umsg.Entity(pl)
		umsg.End()
	end

	pl:RemoveStatus("overridemodel", false, true)

	pl:ChangeTeam(TEAM_HUMAN)
	pl:DoHulls()
	if not noequip then pl.m_PreRedeem = true end
	pl:UnSpectateAndSpawn()
	pl.m_PreRedeem = nil

	local frags = pl:Frags()
	if frags < 0 then
		pl:SetFrags(frags * 5)
	else
		pl:SetFrags(0)
	end
	pl:SetDeaths(0)

	pl.DeathClass = nil
	pl.WeaponsUnlocked = {}
	pl.AmmoUnlocked = {}
	pl.PowerupsUnlocked = {}
	pl:SetZombieClass(self.DefaultZombieClass)

	pl.SpawnedTime = CurTime()
end

function GM:PlayerDisconnected(pl)
	self.Disconnecting = true

	self.PreviouslyDied[pl:UniqueID()] = CurTime()

	if pl:Team() == TEAM_HUMAN then
		pl:DropAll()
	elseif pl:Team() == TEAM_UNDEAD then
		self.StoredUndeadFrags[pl:UniqueID()] = pl:Frags()
	end

	if pl:Health() > 0 then
		local lastattacker = pl:GetLastAttacker()
		if IsValid(lastattacker) then
			pl:TakeDamage(1000, lastattacker, lastattacker)

			for _, p in pairs(player.GetAll()) do
				p:PrintTranslatedMessage(HUD_PRINTCONSOLE, "disconnect_killed", pl:Name(), lastattacker:Name())
			end
		end
	end

	gamemode.Call("CalculateInfliction")
end

-- Reevaluates all props to determine if they should be frozen or not from nails to the world.
function GM:EvaluatePropFreeze()
	for _, ent in pairs(ents.GetAll()) do
		if ent:IsNailedToWorldHierarchy() then
			ent:SetNailFrozen(true)
		elseif ent:GetNailFrozen() then
			ent:SetNailFrozen(false)
		end
	end
end

-- A nail takes some damage. isdead is true if the damage is enough to remove the nail. The nail is invalid after this function call if it dies.
function GM:OnNailDamaged(ent, attacker, inflictor, damage, dmginfo)
end

-- A nail is removed between two entities. The nail is no longer considered valid right after this function and is not in the entities' Nails tables. remover may not be nil if it was removed with the hammer's unnail ability.
local function evalfreeze(ent)
	if ent and ent:IsValid() then
		gamemode.Call("EvaluatePropFreeze")
	end
end
function GM:OnNailRemoved(nail, ent1, ent2, remover)
	if ent1 and ent1:IsValid() and not ent1:IsWorld() then
		timer.SimpleEx(0, evalfreeze, ent1)
		timer.SimpleEx(0.2, evalfreeze, ent1)
	end
	if ent2 and ent2:IsValid() and not ent2:IsWorld() then
		timer.SimpleEx(0, evalfreeze, ent2)
		timer.SimpleEx(0.2, evalfreeze, ent2)
	end

	if remover and remover:IsValid() and remover:IsPlayer() then
		local deployer = nail:GetDeployer()
		if deployer:IsValid() and deployer ~= remover and deployer:Team() == TEAM_HUMAN then
			for _, pl in pairs(player.GetAll()) do
				pl:PrintTranslatedMessage(HUD_PRINTCONSOLE, "nail_removed_by", remover:Name(), deployer:Name())
			end
		end
	end
end

-- A nail is created between two entities.
function GM:OnNailCreated(ent1, ent2, nail)
	if ent1 and ent1:IsValid() and not ent1:IsWorld() then
		timer.SimpleEx(0, evalfreeze, ent1)
	end
	if ent2 and ent2:IsValid() and not ent2:IsWorld() then
		timer.SimpleEx(0, evalfreeze, ent2)
	end
end

function GM:RemoveDuplicateAmmo(pl)
	local AmmoCounts = {}
	local WepAmmos = {}
	for _, wep in pairs(pl:GetWeapons()) do
		if wep.Primary then
			local ammotype = wep:ValidPrimaryAmmo()
			if ammotype and wep.Primary.DefaultClip > 0 then
				AmmoCounts[ammotype] = (AmmoCounts[ammotype] or 0) + 1
				WepAmmos[wep] = wep.Primary.DefaultClip - wep.Primary.ClipSize
			end
			local ammotype2 = wep:ValidSecondaryAmmo()
			if ammotype2 and wep.Secondary.DefaultClip > 0 then
				AmmoCounts[ammotype2] = (AmmoCounts[ammotype2] or 0) + 1
				WepAmmos[wep] = wep.Secondary.DefaultClip - wep.Secondary.ClipSize
			end
		end
	end
	for ammotype, count in pairs(AmmoCounts) do
		if count > 1 then
			local highest = 0
			local highestwep
			for wep, extraammo in pairs(WepAmmos) do
				if wep.Primary.Ammo == ammotype then
					highest = math.max(highest, extraammo)
					highestwep = wep
				end
			end
			if highestwep then
				for wep, extraammo in pairs(WepAmmos) do
					if wep ~= highestwep and wep.Primary.Ammo == ammotype then
						pl:RemoveAmmo(extraammo, ammotype)
					end
				end
			end
		end
	end
end

local function TimedOut(pl)
	if pl:IsValid() and pl:Team() == TEAM_HUMAN and pl:Alive() and not GAMEMODE.CheckedOut[pl:UniqueID()] then
		gamemode.Call("GiveRandomEquipment", pl)
	end
end

function GM:GiveDefaultOrRandomEquipment(pl)
	if not self.CheckedOut[pl:UniqueID()] then
		if self.StartingLoadout then
			self:GiveStartingLoadout(pl)
		else
			if pl.StartingWorth == nil then pl.StartingWorth = self.StartingWorth end
			pl:SendLua("GAMEMODE:RequestedDefaultCart()")
			if pl.StartingWorth > 0 then
				timer.SimpleEx(4, TimedOut, pl)
			end
		end
	end
end

function GM:GiveStartingLoadout(pl)
	for item, amount in pairs(self.StartingLoadout) do
		for i=1, amount do
			pl:Give(item)
		end
	end
end

function GM:GiveRandomEquipment(pl)
	if self.CheckedOut[pl:UniqueID()] then return end
	self.CheckedOut[pl:UniqueID()] = true

	if self.StartingLoadout then
		self:GiveStartingLoadout(pl)
	elseif #self.StartLoadouts >= 1 then
		for _, wep in pairs(self.StartLoadouts[math.random(1, #self.StartLoadouts)]) do
			pl:Give(wep)
		end
	end
end

function GM:PlayerCanCheckout(pl)
	return pl:IsValid() and pl:Team() == TEAM_HUMAN and pl:Alive() and not self.CheckedOut[pl:UniqueID()] and not self.StartingLoadout
end

concommand.Add("zs_pointsshopbuy", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected()) or #arguments == 0 then return end

	if sender:GetUnlucky() then
		sender:SplitMessage(translate.ClientGet(sender, "banned_for_life_warning"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	if not sender:NearArsenalCrate() then
		sender:SplitMessage(translate.ClientGet(sender, "need_to_be_near_arsenal_crate"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	if not gamemode.Call("PlayerCanPurchase", sender) then
		sender:SplitMessage(translate.ClientGet(sender, "cant_purchase_right_now"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	local itemtab
	local id = arguments[1]
	local num = tonumber(id)
	if num then
		itemtab = GAMEMODE.Items[num]
	else
		for i, tab in pairs(GAMEMODE.Items) do
			if tab.Signature == id then
				itemtab = tab
				break
			end
		end
	end

	if not itemtab or not itemtab.PointShop then return end

	local points = sender:GetPoints()
	local cost = itemtab.Worth
	if not GAMEMODE:GetWaveActive() then
		cost = cost * GAMEMODE.ArsenalCrateMultiplier
	end

	if GAMEMODE:IsClassicMode() and itemtab.NoClassicMode then
		sender:SplitMessage(translate.ClientFormat(sender, "cant_use_x_in_classic", itemtab.Name))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	cost = math.ceil(cost)

	if points < cost then
		sender:SplitMessage(translate.ClientGet(sender, "dont_have_enough_points"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	if itemtab.Callback then
		itemtab.Callback(sender)
	elseif itemtab.SWEP then
		if sender:HasWeapon(itemtab.SWEP) then
			local stored = weapons.GetStored(itemtab.SWEP)
			if stored and stored.AmmoIfHas then
				sender:GiveAmmo(stored.Primary.DefaultClip, stored.Primary.Ammo)
			else
				local wep = ents.Create("prop_weapon")
				if wep:IsValid() then
					wep:SetPos(sender:GetShootPos())
					wep:SetAngles(sender:GetAngles())
					wep:SetWeaponType(itemtab.SWEP)
					wep:SetShouldRemoveAmmo(true)
					wep:Spawn()
				end
			end
		else
			local wep = sender:Give(itemtab.SWEP)
			if wep and wep:IsValid() and wep.EmptyWhenPurchased and wep:GetOwner():IsValid() then
				if wep.Primary then
					local primary = wep:ValidPrimaryAmmo()
					if primary then
						sender:RemoveAmmo(math.max(0, wep.Primary.DefaultClip - wep.Primary.ClipSize), primary)
					end
				end
				if wep.Secondary then
					local secondary = wep:ValidSecondaryAmmo()
					if secondary then
						sender:RemoveAmmo(math.max(0, wep.Secondary.DefaultClip - wep.Secondary.ClipSize), secondary)
					end
				end
			end
		end
	else
		return
	end

	sender:TakePoints(cost)
	sender:PrintTranslatedMessage(HUD_PRINTTALK, "purchased_x_for_y_points", itemtab.Name, cost)
	sender:SendLua("surface.PlaySound(\"ambient/levels/labs/coinslot1.wav\")")

	local nearest = sender:NearestArsenalCrateOwnedByOther()
	if nearest then
		local owner = nearest:GetObjectOwner()
		if owner:IsValid() then
			local nonfloorcommission = cost * 0.07
			local commission = math.floor(nonfloorcommission)
			if commission > 0 then
				owner.PointsCommission = owner.PointsCommission + cost

				owner:AddPoints(commission)
				umsg.Start("ReceivedCommission", owner)
					umsg.Entity(nearest)
					umsg.Entity(sender)
					umsg.Short(commission)
				umsg.End()
			end

			local leftover = nonfloorcommission - commission
			if leftover > 0 then
				owner.CarryOverCommision = owner.CarryOverCommision + leftover
				if owner.CarryOverCommision >= 1 then
					local carried = math.floor(owner.CarryOverCommision)
					owner.CarryOverCommision = owner.CarryOverCommision - carried
					owner:AddPoints(carried)
					umsg.Start("ReceivedCommission", owner)
						umsg.Entity(nearest)
						umsg.Entity(sender)
						umsg.Short(carried)
					umsg.End()
				end
			end
		end
	end
end)

concommand.Add("worthrandom", function(sender, command, arguments)
	if sender:IsValid() and sender:IsConnected() and gamemode.Call("PlayerCanCheckout", sender) then
		gamemode.Call("GiveRandomEquipment", sender)
	end
end)

concommand.Add("worthcheckout", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected()) or #arguments == 0 then return end

	if not gamemode.Call("PlayerCanCheckout", sender) then
		sender:SplitMessage("You can't use the Worth menu any more this round!")
		return
	end

	local cost = 0
	local hasalready = {}

	for _, id in pairs(arguments) do
		local tab = FindStartingItem(id)
		if tab and not hasalready[id] then
			cost = cost + tab.Worth
			hasalready[id] = true
		end
	end

	if cost > sender.StartingWorth then return end

	local hasalready = {}

	for _, id in pairs(arguments) do
		local tab = FindStartingItem(id)
		if tab and not hasalready[id] then
			if tab.NoClassicMode and GAMEMODE:IsClassicMode() then
				sender:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(sender, "cant_use_x_in_classic_mode", tab.Name))
			elseif tab.Callback then
				tab.Callback(sender)
				hasalready[id] = true
			elseif tab.SWEP then
				sender:Give(tab.SWEP)
				hasalready[id] = true
			end
		end
	end

	if table.Count(hasalready) > 0 then
		GAMEMODE.CheckedOut[sender:UniqueID()] = true
	end

	gamemode.Call("RemoveDuplicateAmmo", sender)
end)

function GM:PlayerDeathThink(pl)
	if pl.Revive or self:GetWave() == 0 then return end

	if pl:GetObserverMode() == OBS_MODE_CHASE then
		local target = pl:GetObserverTarget()
		if not target or not target:IsValid() or not target:Alive() then
			pl:StripWeapons()
			pl:Spectate(OBS_MODE_ROAMING)
			pl:SpectateEntity(NULL)
		end
	end

	if pl:Team() ~= TEAM_UNDEAD then
		pl.StartCrowing = nil
		pl.StartSpectating = nil
		return
	end

	if pl.NextSpawnTime and pl.NextSpawnTime <= CurTime() then -- Force spawn.
		pl.NextSpawnTime = nil

		pl:RefreshDynamicSpawnPoint()
		pl:UnSpectateAndSpawn()
	elseif pl:GetObserverMode() == OBS_MODE_NONE then -- Not in spectator yet.
		if self:GetWaveActive() then -- During wave.
			if not pl.StartSpectating or CurTime() >= pl.StartSpectating then
				pl.StartSpectating = nil

				pl:StripWeapons()
				local best = self:GetBestDynamicSpawn(pl)
				if best then
					pl:Spectate(OBS_MODE_CHASE)
					pl:SpectateEntity(best)
				else
					pl:Spectate(OBS_MODE_ROAMING)
					pl:SpectateEntity(NULL)
				end
			end
		elseif not pl.StartCrowing or CurTime() >= pl.StartCrowing then -- Not during wave. Turn in to a crow. If we die as a crow then we get turned to spectator anyway.
			pl:ChangeToCrow()
		end
	else -- In spectator.
		if pl:KeyDown(IN_ATTACK) then
			if self:GetWaveActive() then
				pl:RefreshDynamicSpawnPoint()
				pl:UnSpectateAndSpawn()
			else
				pl:ChangeToCrow()
			end
		elseif pl:KeyPressed(IN_ATTACK2) then
			pl.SpectatedPlayerKey = (pl.SpectatedPlayerKey or 0) + 1

			local livingzombies = {}
			for k, v in pairs(team.GetPlayers(TEAM_ZOMBIE)) do
				if v:Alive() then table.insert(livingzombies, v) end
			end

			pl:StripWeapons()
			local specplayer = livingzombies[pl.SpectatedPlayerKey]
			if specplayer then
				pl:Spectate(OBS_MODE_CHASE)
				pl:SpectateEntity(specplayer)
			else
				pl:Spectate(OBS_MODE_ROAMING)
				pl:SpectateEntity(NULL)
				pl.SpectatedPlayerKey = nil
			end
		end
	end
end
GM._PlayerDeathThink = GM.PlayerDeathThink

function GM:ShouldAntiGrief(ent, attacker, dmginfo, health)
	return ent.m_AntiGrief and self.GriefMinimumHealth <= health and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN and not dmginfo:IsExplosionDamage()
end

function GM:EntityTakeDamage(ent, dmginfo)
	local attacker, inflictor, damage = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()

	if attacker == inflictor and attacker:IsProjectile() and dmginfo:GetDamageType() == DMG_CRUSH then -- Fixes projectiles doing physics-based damage.
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
		return
	end

	if ent._BARRICADEBROKEN and not (attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD) then
		damage = damage * 3
		dmginfo:SetDamage(dmginfo:GetDamage() * 3)
	end

	if ent.ProcessDamage and ent:ProcessDamage(dmginfo) then return end

	-- Don't allow blowing up props during wave 0.
	if self:GetWave() <= 0 and string.sub(ent:GetClass(), 1, 12) == "prop_physics" and dmginfo:GetInflictor().NoPropDamageDuringWave0 then
		dmginfo:SetDamage(0)
		dmginfo:SetDamageType(DMG_BULLET)
		return
	end

	-- Prop is nailed. Forward damage to the nails.
	if ent:DamageNails(attacker, inflictor, damage, dmginfo) then return end

	-- Work-around for explosive barrel chains.
	local inflictor = dmginfo:GetInflictor()
	if ent:IsPlayer() and inflictor.ProcessDamage == ExplosiveProcessDamage and inflictor:IsValid() then
		local teamid = inflictor:GetTeamID()
		if teamid ~= 0 and teamid == ent:GetTeamID() and inflictor.Owner ~= ent then
			dmginfo:SetDamage(0)
			return
		end
	end

	local entclass = ent:GetClass()
	if ent.PropHealth then -- A prop that was invulnerable and converted to vulnerable.
		if self.NoPropDamageFromHumanMelee and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN and inflictor.IsMelee then
			dmginfo:SetDamage(0)
			return
		end

		if gamemode.Call("ShouldAntiGrief", ent, attacker, dmginfo, ent.PropHealth) then
			local newdamage = attacker:AntiGrief(damage)
			if newdamage <= 0 then return end
			damage = newdamage
		end

		ent.PropHealth = ent.PropHealth - damage

		if ent.PropHealth <= 0 then
			local effectdata = EffectData()
				effectdata:SetOrigin(ent:GetPos())
			util.Effect("Explosion", effectdata, true, true)
			ent:Fire("break")
		else
			local brit = math.Clamp(ent.PropHealth / ent.TotalHealth, 0, 1)
			local col = ent:GetColor()
			col.r = 255
			col.g = 255 * brit
			col.b = 255 * brit
			ent:SetColor(col)
		end
	elseif entclass == "func_door_rotating" then
		if ent:GetKeyValues().damagefilter == "invul" then return end

		if not ent.Heal then
			local br = ent:BoundingRadius()
			if br > 80 then return end -- Don't break these kinds of doors that are bigger than this.

			local health = br * 35
			ent.Heal = health
			ent.TotalHeal = health
		end

		if gamemode.Call("ShouldAntiGrief", ent, attacker, dmginfo, ent.TotalHeal) then
			local newdamage = attacker:AntiGrief(damage)
			if newdamage <= 0 then return end
			damage = newdamage
		end

		if damage >= 20 and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD then
			ent:EmitSound(math.random(2) == 1 and "npc/zombie/zombie_pound_door.wav" or "ambient/materials/door_hit1.wav")
		end

		ent.Heal = ent.Heal - damage
		local brit = math.Clamp(ent.Heal / ent.TotalHeal, 0, 1)
		local col = ent:GetColor()
		col.r = 255
		col.g = 255 * brit
		col.b = 255 * brit
		ent:SetColor(col)

		if ent.Heal <= 0 then
			ent:EmitSound("Breakable.Metal")
			ent:Fire("open", "", 0) -- Trigger any area portals.
			ent:Fire("break", "", 0.05)
			ent:Fire("kill", "", 0.1)
		end
	elseif entclass == "prop_door_rotating" then
		if ent:GetKeyValues().damagefilter == "invul" or ent:HasSpawnFlags(2048) then return end

		ent.Heal = ent.Heal or ent:BoundingRadius() * 35
		ent.TotalHeal = ent.TotalHeal or ent.Heal

		if gamemode.Call("ShouldAntiGrief", ent, attacker, dmginfo, ent.TotalHeal) then
			local newdamage = attacker:AntiGrief(damage)
			if newdamage <= 0 then return end
			damage = newdamage
		end

		if damage >= 20 and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD then
			ent:EmitSound("npc/zombie/zombie_pound_door.wav")
		end

		ent.Heal = ent.Heal - damage
		local brit = math.Clamp(ent.Heal / ent.TotalHeal, 0, 1)
		local col = ent:GetColor()
		col.r = 255
		col.g = 255 * brit
		col.b = 255 * brit
		ent:SetColor(col)

		if ent.Heal <= 0 then
			local physprop = ents.Create("prop_physics")
			if physprop:IsValid() then
				physprop:SetPos(ent:GetPos())
				physprop:SetAngles(ent:GetAngles())
				physprop:SetSkin(ent:GetSkin() or 0)
				physprop:SetMaterial(ent:GetMaterial())
				physprop:SetModel(ent:GetModel())
				physprop:Spawn()
				ent:Fire("break")
				physprop:SetPhysicsAttacker(attacker)
				if attacker:IsValid() then
					local phys = physprop:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous((physprop:NearestPoint(attacker:EyePos()) - attacker:EyePos()):GetNormalized() * math.Clamp(damage * 3, 40, 300))
					end
				end
				if physprop:GetMaxHealth() == 1 and physprop:Health() == 0 then
					local health = math.ceil((physprop:OBBMins():Length() + physprop:OBBMaxs():Length()) * 2)
					if health < 2000 then
						physprop.PropHealth = health
						physprop.TotalHealth = health
					end
				end
			end
		end
	elseif entclass == "func_physbox" then
		local holder, status = ent:GetHolder()
		if holder then status:Remove() end

		if ent:GetKeyValues().damagefilter == "invul" then return end

		ent.Heal = ent.Heal or ent:BoundingRadius() * 35
		ent.TotalHeal = ent.TotalHeal or ent.Heal

		if gamemode.Call("ShouldAntiGrief", ent, attacker, dmginfo, ent.TotalHeal) then
			local newdamage = attacker:AntiGrief(damage)
			if newdamage <= 0 then return end
			damage = newdamage
		end

		ent.Heal = ent.Heal - damage
		local brit = math.Clamp(ent.Heal / ent.TotalHeal, 0, 1)
		local col = ent:GetColor()
		col.r = 255
		col.g = 255 * brit
		col.b = 255 * brit
		ent:SetColor(col)

		if ent.Heal <= 0 then
			local foundaxis = false
			local entname = ent:GetName()
			local allaxis = ents.FindByClass("phys_hinge")
			for _, axis in pairs(allaxis) do
				local keyvalues = axis:GetKeyValues()
				if keyvalues.attach1 == entname or keyvalues.attach2 == entname then
					foundaxis = true
					axis:Remove()
					ent.Heal = ent.Heal + 120
				end
			end

			if not foundaxis then
				ent:Fire("break", "", 0)
			end
		end
	elseif entclass == "func_breakable" then
		if ent:GetKeyValues().damagefilter == "invul" then return end

		if gamemode.Call("ShouldAntiGrief", ent, attacker, dmginfo, ent:GetMaxHealth()) then
			local newdamage = attacker:AntiGrief(damage, true)
			if newdamage <= 0 then return end
			damage = newdamage

			ent:SetHealth(ent:Health() + (damage - newdamage))
		end

		local brit = math.Clamp(ent:Health() / ent:GetMaxHealth(), 0, 1)
		local col = ent:GetColor()
		col.r = 255
		col.g = 255 * brit
		col.b = 255 * brit
		ent:SetColor(col)
	end

	if damage > 0 then
		local holder, status = ent:GetHolder()
		if holder then status:Remove() end
	end
end

function GM:SetRandomToZombie()
	local plays = team.GetPlayers(TEAM_HUMAN)
	local pl = plays[math.random(#plays)]

	if not pl then return end

	pl:ChangeTeam(TEAM_UNDEAD)
	pl:SetFrags(0)
	pl:SetDeaths(0)

	self.StartingZombie[pl:UniqueID()] = true
	self.PreviouslyDied[pl:UniqueID()] = CurTime()
	pl:UnSpectateAndSpawn()

	return pl
end

function GM:OnPlayerChangedTeam(pl, oldteam, newteam)
	if newteam == TEAM_UNDEAD then
		pl:SetPoints(0)
		pl.DamagedBy = {}
		pl:SetBarricadeGhosting(false)
	elseif newteam == TEAM_HUMAN then
		self.PreviouslyDied[pl:UniqueID()] = nil
	end

	pl.m_PointQueue = 0

	timer.SimpleEx(0, gamemode.Call, "CalculateInfliction")
end

function GM:SetPantsMode(mode)
	//self.PantsMode = mode and self.ZombieClasses["Zombie Legs"] ~= nil and not self:IsClassicMode()
	self.PantsMode = false // Override
	if self.PantsMode then
		local index = self.ZombieClasses["Zombie Legs"].Index

		self.PreOverrideDefaultZombieClass = self.PreOverrideDefaultZombieClass or self.DefaultZombieClass
		self.DefaultZombieClass = index

		for _, pl in pairs(player.GetAll()) do
			local classname = pl:GetZombieClassTable().Name
			if classname ~= "Zombie Legs" and classname ~= "Crow" then
				if pl:Team() == TEAM_UNDEAD then
					pl:KillSilent()
					pl:SetZombieClass(index)
					pl:UnSpectateAndSpawn()
				else
					pl:SetZombieClass(index)
				end
			end
			pl.DeathClass = index
		end
	else
		self.DefaultZombieClass = self.PreOverrideDefaultZombieClass or self.DefaultZombieClass

		for _, pl in pairs(player.GetAll()) do
			if pl:GetZombieClassTable().Name == "Zombie Legs" then
				if pl:Team() == TEAM_UNDEAD then
					pl:KillSilent()
					pl:SetZombieClass(self.DefaultZombieClass or 1)
					pl:UnSpectateAndSpawn()
				else
					pl:SetZombieClass(self.DefaultZombieClass or 1)
				end
			end
		end
	end
end

function GM:SetClassicMode(mode)
	self.ClassicMode = mode and self.ZombieClasses["Classic Zombie"] ~= nil and not self.PantsMode

	SetGlobalBool("classicmode", self.ClassicMode)

	if self:IsClassicMode() then
		local index = self.ZombieClasses["Classic Zombie"].Index

		self.PreOverrideDefaultZombieClass = self.PreOverrideDefaultZombieClass or self.DefaultZombieClass
		self.DefaultZombieClass = index

		for _, pl in pairs(player.GetAll()) do
			local classname = pl:GetZombieClassTable().Name
			if classname ~= "Classic Zombie" and classname ~= "Crow" then
				if pl:Team() == TEAM_UNDEAD then
					pl:KillSilent()
					pl:SetZombieClass(index)
					pl:UnSpectateAndSpawn()
				else
					pl:SetZombieClass(index)
				end
			end
			pl.DeathClass = index
		end
	else
		self.DefaultZombieClass = self.PreOverrideDefaultZombieClass or self.DefaultZombieClass

		for _, pl in pairs(player.GetAll()) do
			if pl:GetZombieClassTable().Name == "Classic Zombie" then
				if pl:Team() == TEAM_UNDEAD then
					pl:KillSilent()
					pl:SetZombieClass(self.DefaultZombieClass or 1)
					pl:UnSpectateAndSpawn()
				else
					pl:SetZombieClass(self.DefaultZombieClass or 1)
				end
			end
		end
	end
end

function GM:SetClosestsToZombie()
	local allplayers = player.GetAll()
	local numplayers = #allplayers
	if numplayers <= 1 then return end

	local desiredzombies = self:GetDesiredStartingZombies()

	self:SortZombieSpawnDistances(allplayers)

	local zombies = {}
	for _, pl in pairs(allplayers) do
		if pl:Team() ~= TEAM_HUMAN or not pl:Alive() then
			table.insert(zombies, pl)
		end
	end

	-- Need to place some people back on the human team.
	if #zombies > desiredzombies then
		local toswap = #zombies - desiredzombies
		for _, pl in pairs(zombies) do
			if pl.DiedDuringWave0 and not pl:GetNetworkedBool("pvolunteer", false) then
				pl:SetTeam(TEAM_HUMAN)
				pl:UnSpectateAndSpawn()
				toswap = toswap - 1
				if toswap <= 0 then
					break
				end
			end
		end
	end

	for i = 1, desiredzombies do
		local pl = allplayers[i]
		if pl:Team() ~= TEAM_UNDEAD then
			pl:ChangeTeam(TEAM_UNDEAD)
			self.PreviouslyDied[pl:UniqueID()] = CurTime()
		end
		pl:SetFrags(0)
		pl:SetDeaths(0)
		self.StartingZombie[pl:UniqueID()] = true
		pl:UnSpectateAndSpawn()
	end

	for _, pl in pairs(allplayers) do
		if pl:Team() == TEAM_HUMAN and pl._ZombieSpawnDistance <= 128 then
			pl:SetPos(self:PlayerSelectSpawn(pl):GetPos())
		end
	end
end

function GM:AllowPlayerPickup(pl, ent)
	return false
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	if attacker.PBAttacker and attacker.PBAttacker:IsValid() and CurTime() < attacker.NPBAttacker then -- Protection against prop_physbox team killing. physboxes don't respond to SetPhysicsAttacker()
		attacker = attacker.PBAttacker
	end

	if attacker:IsPlayer() and attacker ~= pl and not attacker.AllowTeamDamage and not pl.AllowTeamDamage and attacker:Team() == pl:Team() then return false end

	return true
end

function GM:PlayerHurt(victim, attacker, healthremaining, damage)
	if 0 < healthremaining then
		victim:PlayPainSound()
	end

	if victim:Team() == TEAM_HUMAN then
		victim.BonusDamageCheck = CurTime()

		if healthremaining < 75 and 1 <= healthremaining then
			victim:ResetSpeed(nil, healthremaining)
		end
	end

	if attacker:IsValid() and attacker:IsPlayer() then
		victim:SetLastAttacker(attacker)

		local myteam = attacker:Team()
		local otherteam = victim:Team()
		if myteam ~= otherteam then
			damage = math.min(damage, victim.m_PreHurtHealth)
			victim.m_PreHurtHealth = healthremaining

			attacker.DamageDealt[myteam] = attacker.DamageDealt[myteam] + damage

			if myteam == TEAM_UNDEAD then
				attacker.LifeHumanDamage = attacker.LifeHumanDamage + damage
			elseif otherteam == TEAM_UNDEAD then
				victim.DamagedBy[attacker] = (victim.DamagedBy[attacker] or 0) + damage
				if (not victim.m_LastWaveStartSpawn or CurTime() >= victim.m_LastWaveStartSpawn + 3) and (healthremaining <= 0 or not victim.m_LastGasHeal or CurTime() >= victim.m_LastGasHeal + 2) then
					attacker.m_PointQueue = attacker.m_PointQueue + damage / victim:GetMaxHealth() * (victim:GetZombieClassTable().Points or 0)
				end
				attacker.m_LastDamageDealtPosition = victim:GetPos()
				attacker.m_LastDamageDealt = CurTime()
			end
		end
	end
end

-- Don't change speed instantly to stop people from shooting and then running away with a faster weapon.
function GM:WeaponDeployed(pl, wep)
	local timername = tostring(pl).."speedchange"
	timer.Destroy(timername)

	local speed = pl:ResetSpeed(true) -- Determine what speed we SHOULD get without actually setting it.
	if speed < pl:GetMaxSpeed() then
		pl:SetSpeed(speed)
	elseif pl:GetMaxSpeed() < speed then
		timer.CreateEx(timername, 0.333, 1, ValidFunction, pl, "SetHumanSpeed", speed)
	end
end

function GM:KeyPress(pl, key)
	if key == IN_USE then
		if pl:Team() == TEAM_HUMAN and pl:Alive() then
			if pl:IsCarrying() then
				pl.status_human_holding:Remove()
			else
				self:TryHumanPickup(pl, pl:TraceLine(64).Entity)
			end
		end
	elseif key == IN_SPEED then
		if pl:Alive() then
			if pl:Team() == TEAM_HUMAN then
				pl:DispatchAltUse()
			elseif pl:Team() == TEAM_UNDEAD then
				pl:CallZombieFunction("AltUse")
			end
		end
	elseif key == IN_ZOOM then
		if pl:Team() == TEAM_HUMAN and pl:Alive() /*and pl:IsOnGround()*/ then
			pl:SetBarricadeGhosting(true)
		end
	end
end

function GM:PlayerUse(pl, ent)
	if not pl:Alive() or pl:Team() == TEAM_UNDEAD and pl:GetZombieClassTable().NoUse or pl:GetBarricadeGhosting() then return false end

	local entclass = ent:GetClass()
	if entclass == "prop_door_rotating" then
		if CurTime() < (ent.m_AntiDoorSpam or 0) then -- Prop doors can be glitched shut by mashing the use button.
			return false
		end
		ent.m_AntiDoorSpam = CurTime() + 0.85
	elseif entclass == "item_healthcharger" then
		if pl:GetHemophilia() or pl:Team() == TEAM_UNDEAD then return false end
	elseif pl:Team() == TEAM_HUMAN and not pl:IsCarrying() and pl:KeyPressed(IN_USE) then
		self:TryHumanPickup(pl, ent)
	end

	return true
end

function GM:PlayerDeath(pl, inflictor, attacker)
end

function GM:PlayerDeathSound()
	return true
end

function GM:CanPlayerSuicide(pl)
	if pl:Team() == TEAM_HUMAN and self:GetWave() <= self.NoSuicideWave then
		pl:PrintTranslatedMessage(HUD_PRINTCENTER, "give_time_before_suicide")
		return false
	end

	return pl:GetObserverMode() == OBS_MODE_NONE and pl:Alive() and (not pl.SpawnNoSuicide or pl.SpawnNoSuicide < CurTime())
end

function GM:DefaultRevive(pl)
	local status = pl:GiveStatus("revive")
	if status then
		status:SetReviveTime(CurTime() + 2)
	end
end

function GM:HumanKilledZombie(pl, attacker, inflictor, dmginfo, headshot, suicide)
	if (pl:GetZombieClassTable().Points or 0) == 0 or self.RoundEnded then return end

	-- Simply distributes based on damage but also do some stuff for assists.

	local totaldamage = 0
	for otherpl, dmg in pairs(pl.DamagedBy) do
		if otherpl:IsValid() and otherpl:Team() == TEAM_HUMAN then
			totaldamage = totaldamage + dmg
		end
	end

	local mostassistdamage = 0
	local halftotaldamage = totaldamage / 2
	local mostdamager
	for otherpl, dmg in pairs(pl.DamagedBy) do
		if otherpl ~= attacker and otherpl:IsValid() and otherpl:Team() == TEAM_HUMAN and dmg > mostassistdamage and dmg >= halftotaldamage then
			mostassistdamage = dmg
			mostdamager = otherpl
		end
	end

	attacker.ZombiesKilled = attacker.ZombiesKilled + 1

	if mostdamager then
		attacker:PointCashOut(pl, FM_LOCALKILLOTHERASSIST)
		mostdamager:PointCashOut(pl, FM_LOCALASSISTOTHERKILL)

		mostdamager.ZombiesKilledAssists = mostdamager.ZombiesKilledAssists + 1
	else
		attacker:PointCashOut(pl, FM_NONE)
	end

	gamemode.Call("PostHumanKilledZombie", pl, attacker, inflictor, dmginfo, mostdamager, mostassistdamage, headshot)

	return mostdamager
end

function GM:PostHumanKilledZombie(pl, attacker, inflictor, dmginfo, assistpl, assistamount, headshot)
end

function GM:ZombieKilledHuman(pl, attacker, inflictor, dmginfo, headshot, suicide)
	if self.RoundEnded then return end

	local plpos = pl:GetPos()
	local dist = 99999
	for _, ent in pairs(team.GetSpawnPoint(TEAM_UNDEAD)) do
		if ent:IsValid() then
			dist = math.min(math.ceil(ent:GetPos():Distance(plpos)), dist)
		end
	end
	pl.ZombieSpawnDeathDistance = dist

	attacker:AddBrains(1)
	attacker.LifeBrainsEaten = attacker.LifeBrainsEaten + 1

	if not pl.Gibbed and not suicide then
		--pl.GreenTint = true

		local status = pl:GiveStatus("revive_slump_human")
		if status then
			status:SetReviveTime(CurTime() + 4)
			status:SetZombieInitializeTime(CurTime() + 2)
		end

		local classtab = self:IsClassicMode() and GAMEMODE.ZombieClasses["Classic Zombie"] or GAMEMODE.ZombieClasses["Fresh Dead"]
		if classtab then
			pl:SetZombieClass(classtab.Index)
		end
	end

	gamemode.Call("PostZombieKilledHuman", pl, attacker, inflictor, dmginfo, headshot, suicide)

	return attacker:Frags()
end

function GM:PostZombieKilledHuman(pl, attacker, inflictor, dmginfo, headshot, suicide)
end

function DelayedChangeToZombie(pl)
	if pl:IsValid() then
		if pl.ChangeTeamFrags then
			pl:SetFrags(pl.ChangeTeamFrags)
			pl.ChangeTeamFrags = 0
		end

		pl:ChangeTeam(TEAM_UNDEAD)
	end
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	pl:RemoveFakeFlashlight()
	pl:RemoveStatus("overridemodel", false, true)

	local inflictor = dmginfo:GetInflictor()
	local plteam = pl:Team()
	local ct = CurTime()
	local suicide = attacker == pl or attacker:IsWorld()

	pl:Freeze(false)

	local headshot = pl:LastHitGroup() == HITGROUP_HEAD and pl.m_LastHeadShot and CurTime() <= pl.m_LastHeadShot + 0.1

	if suicide then attacker = pl:GetLastAttacker() or attacker end
	pl:SetLastAttacker()

	if inflictor == NULL then inflictor = attacker end

	if inflictor == attacker and attacker:IsPlayer() then
		local wep = attacker:GetActiveWeapon()
		if wep:IsValid() then
			inflictor = wep
		end
	end

	if headshot then
		local effectdata = EffectData()
			effectdata:SetOrigin(dmginfo:GetDamagePosition())
			local force = dmginfo:GetDamageForce()
			effectdata:SetMagnitude(force:Length() * 3)
			effectdata:SetNormal(force:GetNormalized())
			effectdata:SetEntity(pl)
		util.Effect("headshot", effectdata, true, true)
	end

	if not pl:CallZombieFunction("OnKilled", attacker, inflictor, suicide, headshot, dmginfo) then
		if pl:Health() <= -70 and not pl.NoGibs then
			pl:Gib(dmginfo)
		elseif not pl.KnockedDown then
			pl:CreateRagdoll()
		end
	end

	local revive
	local assistpl
	if plteam == TEAM_UNDEAD then
		local classtable = pl:GetZombieClassTable()

		pl:PlayZombieDeathSound()

		if not classtable.NoDeaths then
			pl:AddDeaths(1)
		end

		if self:GetWaveActive() then
			pl.StartSpectating = ct + 2
		else
			pl.StartCrowing = ct + 3
		end

		if attacker:IsValid() and attacker:IsPlayer() and attacker ~= pl then
			if classtable.Revives and not pl.Gibbed and not headshot then
				if classtable.ReviveCallback then
					revive = classtable.ReviveCallback(pl, attacker, dmginfo)
				elseif math.random(1, 4) ~= 1 then
					self:DefaultRevive(pl)
					revive = true
				end
			end

			if not revive and attacker:Team() ~= TEAM_UNDEAD then
				assistpl = gamemode.Call("HumanKilledZombie", pl, attacker, inflictor, dmginfo, headshot, suicide)
			end
		end

		if not revive and (pl.LifeBarricadeDamage ~= 0 or pl.LifeHumanDamage ~= 0 or pl.LifeBrainsEaten ~= 0) then
			umsg.Start("lifestats", pl)
				umsg.Long(math.ceil(pl.LifeBarricadeDamage or 0))
				umsg.Long(math.ceil(pl.LifeHumanDamage or 0))
				umsg.Short(pl.LifeBrainsEaten or 0)
			umsg.End()
		end
	else
		pl.NextSpawnTime = ct + 4

		pl:PlayDeathSound()

		if attacker:IsPlayer() and attacker ~= pl then
			gamemode.Call("ZombieKilledHuman", pl, attacker, inflictor, dmginfo, headshot, suicide)
		end

		pl:DropAll()
		timer.SimpleEx(0, DelayedChangeToZombie, pl) -- We don't want people shooting barrels near teammates.
		self.PreviouslyDied[pl:UniqueID()] = CurTime()
		if self:GetWave() == 0 then
			pl.DiedDuringWave0 = true
		end

		local frags = pl:Frags()
		if frags < 0 then
			pl.ChangeTeamFrags = math.ceil(frags / 5)
		else
			pl.ChangeTeamFrags = 0
		end

		if pl.SpawnedTime then
			pl.SurvivalTime = math.max(ct - pl.SpawnedTime, pl.SurvivalTime or 0)
			pl.SpawnedTime = nil
		end

		if team.NumPlayers(TEAM_HUMAN) <= 1 then
			self.LastHumanPosition = pl:LocalToWorld(pl:OBBCenter())
			BroadcastLua("GAMEMODE.LastHumanPosition = Vector("..self.LastHumanPosition.x..", "..self.LastHumanPosition.y..", "..self.LastHumanPosition.z..")")
		end
	end

	if revive or pl:CallZombieFunction("NoDeathMessage", attacker, dmginfo) then return end

	if attacker == pl then
		umsg.Start("PlayerKilledSelf")
			umsg.Entity(pl)
			umsg.Char(plteam)
		umsg.End()
	elseif attacker:IsPlayer() then
		if assistpl then
			umsg.Start("PlayerKilledByPlayers")
				umsg.Entity(pl)
				umsg.Entity(attacker)
				umsg.Entity(assistpl)
				umsg.String(inflictor:GetClass())
				umsg.Char(plteam)
				umsg.Char(attacker:Team()) -- Assuming assistants are always on the same team.
				umsg.Bool(headshot)
			umsg.End()

			gamemode.Call("PlayerKilledByPlayer", pl, assistpl, inflictor, headshot, dmginfo, true)
		else
			umsg.Start("PlayerKilledByPlayer")
				umsg.Entity(pl)
				umsg.Entity(attacker)
				umsg.String(inflictor:GetClass())
				umsg.Char(plteam)
				umsg.Char(attacker:Team())
				umsg.Bool(headshot)
			umsg.End()
		end

		gamemode.Call("PlayerKilledByPlayer", pl, attacker, inflictor, headshot, dmginfo)
	else
		umsg.Start("PlayerKilled")
			umsg.Entity(pl)
			umsg.String(inflictor:GetClass())
			umsg.String(attacker:GetClass())
			umsg.Char(plteam)
		umsg.End()
	end
end

function GM:PlayerKilledByPlayer(pl, attacker, inflictor, headshot, dmginfo)
end

function GM:PlayerCanPickupWeapon(pl, ent) -- Commented out next line, since zombies cant pick up from floor anyways, but this keeps them from being unable to get any extra weapons at all
	if pl:Team() == TEAM_UNDEAD then return ent:GetClass() == pl:GetZombieClassTable().SWEP end -- This is necessary for headcrabs and crows.

	return not ent.ZombieOnly and ent:GetClass() ~= "weapon_stunstick"
end

function GM:PlayerFootstep(pl, vPos, iFoot, strSoundName, fVolume, pFilter)
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	local fStepTime = 350

	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		local fMaxSpeed = pl:GetMaxSpeed()
		if fMaxSpeed <= 100 then
			fStepTime = 400
		elseif fMaxSpeed <= 300 then
			fStepTime = 350
		else
			fStepTime = 250
		end
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		fStepTime = 450
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		fStepTime = 600
	end

	if pl:Crouching() then
		fStepTime = fStepTime + 50
	end

	return fStepTime
end

concommand.Add("zsdropweapon", function(sender, command, arguments)
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) or CurTime() < (sender.NextWeaponDrop or 0) then return end
	sender.NextWeaponDrop = CurTime() + 0.15

	local currentwep = sender:GetActiveWeapon()
	if currentwep and currentwep:IsValid() then
		local ent = sender:DropWeaponByType(currentwep:GetClass())
		if ent and ent:IsValid() then
			local shootpos = sender:GetShootPos()
			local aimvec = sender:GetAimVector()
			ent:SetPos(util.TraceHull({start = shootpos, endpos = shootpos + aimvec * 32, mask = MASK_SOLID, filter = sender, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2)}).HitPos)
			ent:SetAngles(sender:GetAngles())
		end
	end
end)

concommand.Add("zsemptyclip", function(sender, command, arguments)
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	sender.NextEmptyClip = sender.NextEmptyClip or 0
	if sender.NextEmptyClip <= CurTime() then
		sender.NextEmptyClip = CurTime() + 0.1

		local wep = sender:GetActiveWeapon()
		if wep:IsValid() and not wep.NoMagazine then
			local primary = wep:ValidPrimaryAmmo()
			if primary and 0 < wep:Clip1() then
				sender:GiveAmmo(wep:Clip1(), primary, true)
				wep:SetClip1(0)
			end
			local secondary = wep:ValidSecondaryAmmo()
			if secondary and 0 < wep:Clip2() then
				sender:GiveAmmo(wep:Clip2(), secondary, true)
				wep:SetClip2(0)
			end
		end
	end
end)

concommand.Add("zsgiveammo", function(sender, command, arguments)
	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN then return end

	local ammotype = arguments[1]
	if not ammotype or #ammotype == 0 or not GAMEMODE.AmmoCache[ammotype] then return end

	local count = sender:GetAmmoCount(ammotype)
	if count <= 0 then
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		sender:PrintTranslatedMessage(HUD_PRINTCENTER, "no_spare_ammo_to_give")
		return
	end

	local ent
	local dent = Entity(tonumber(arguments[2] or 0) or 0)
	if GAMEMODE:ValidMenuLockOnTarget(sender, dent) then
		ent = dent
	end

	if not ent then
		ent = sender:MeleeTrace(48, 2).Entity
	end

	if ent and ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_HUMAN and ent:Alive() then
		local desiredgive = math.min(count, GAMEMODE.AmmoCache[ammotype])
		if desiredgive >= 1 then
			sender:RemoveAmmo(desiredgive, ammotype)
			ent:GiveAmmo(desiredgive, ammotype)

			if CurTime() >= (sender.NextGiveAmmoSound or 0) then
				sender.NextGiveAmmoSound = CurTime() + 1
				sender:PlayGiveAmmoSound()
			end

			sender:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)

			return
		end
	else
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		sender:PrintTranslatedMessage(HUD_PRINTCENTER, "no_person_in_range")
	end
end)

concommand.Add("zsgiveweapon", function(sender, command, arguments)
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	local currentwep = sender:GetActiveWeapon()
	if currentwep and currentwep:IsValid() then
		local ent
		local dent = Entity(tonumber(arguments[2] or 0) or 0)
		if GAMEMODE:ValidMenuLockOnTarget(sender, dent) then
			ent = dent
		end

		if not ent then
			ent = sender:MeleeTrace(48, 2).Entity
		end

		if ent and ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_HUMAN and ent:Alive() then
			if not ent:HasWeapon(currentwep:GetClass()) then
				sender:GiveWeaponByType(currentwep, ent, false)
			else
				sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
				sender:PrintTranslatedMessage(HUD_PRINTCENTER, "person_has_weapon")
			end
		else
			sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			sender:PrintTranslatedMessage(HUD_PRINTCENTER, "no_person_in_range")
		end
	end
end)

concommand.Add("zsgiveweaponclip", function(sender, command, arguments)
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	local currentwep = sender:GetActiveWeapon()
	if currentwep and currentwep:IsValid() then
		local ent
		local dent = Entity(tonumber(arguments[2] or 0) or 0)
		if GAMEMODE:ValidMenuLockOnTarget(sender, dent) then
			ent = dent
		end

		if not ent then
			ent = sender:MeleeTrace(48, 2).Entity
		end

		if ent and ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_HUMAN and ent:Alive() then
			if not ent:HasWeapon(currentwep:GetClass()) then
				sender:GiveWeaponByType(currentwep, ent, true)
			else
				sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
				sender:PrintTranslatedMessage(HUD_PRINTCENTER, "person_has_weapon")
			end
		else
			sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			sender:PrintTranslatedMessage(HUD_PRINTCENTER, "no_person_in_range")
		end
	end
end)

concommand.Add("zsdropammo", function(sender, command, arguments)
	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN or CurTime() < (sender.NextDropClip or 0) then return end

	sender.NextDropClip = CurTime() + 0.2

	local wep = sender:GetActiveWeapon()
	if not wep:IsValid() then return end

	local ammotype = arguments[1] or wep:GetPrimaryAmmoTypeString()
	if GAMEMODE.AmmoNames[ammotype] and GAMEMODE.AmmoCache[ammotype] then
		local ent = sender:DropAmmoByType(ammotype, GAMEMODE.AmmoCache[ammotype] * 2)
		if ent and ent:IsValid() then
			ent:SetPos(sender:EyePos() + sender:GetAimVector() * 8)
			ent:SetAngles(sender:GetAngles())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(sender:GetVelocity() * 0.85)
			end
		end
	end
end)

local VoiceSetTranslate = {}
VoiceSetTranslate["models/player/alyx.mdl"] = "alyx"
VoiceSetTranslate["models/player/barney.mdl"] = "barney"
VoiceSetTranslate["models/player/breen.mdl"] = "male"
VoiceSetTranslate["models/player/combine_soldier.mdl"] = "combine"
VoiceSetTranslate["models/player/combine_soldier_prisonguard.mdl"] = "combine"
VoiceSetTranslate["models/player/combine_super_soldier.mdl"] = "combine"
VoiceSetTranslate["models/player/eli.mdl"] = "male"
VoiceSetTranslate["models/player/gman_high.mdl"] = "male"
VoiceSetTranslate["models/player/kleiner.mdl"] = "male"
VoiceSetTranslate["models/player/monk.mdl"] = "monk"
VoiceSetTranslate["models/player/mossman.mdl"] = "female"
VoiceSetTranslate["models/player/odessa.mdl"] = "male"
VoiceSetTranslate["models/player/police.mdl"] = "combine"
VoiceSetTranslate["models/player/brsp.mdl"] = "female"
VoiceSetTranslate["models/player/moe_glados_p.mdl"] = "female"
VoiceSetTranslate["models/grim.mdl"] = "combine"
VoiceSetTranslate["models/jason278-players/gabe_3.mdl"] = "monk"
VoiceSetTranslate["models/player/p2_chell.mdl"] = "female"
function GM:PlayerSpawn(pl)
	pl:RemoveFakeFlashlight()
	pl:StripWeapons()
	pl:SetColor(color_white)

	if pl:GetMaterial() ~= "" then
		pl:SetMaterial("")
	end

	pl.StartCrowing = nil
	pl.StartSpectating = nil
	pl.NextSpawnTime = nil
	pl.Gibbed = nil

	pl.SpawnNoSuicide = CurTime() + 1

	pl:ShouldDropWeapon(false)

	pl:SetLegDamage(0)
	pl:SetLastAttacker()

	if pl:Team() == TEAM_UNDEAD then
		if not pl.Revived then
			pl.DamagedBy = {}
		end

		pl.LifeBarricadeDamage = 0
		pl.LifeHumanDamage = 0
		pl.LifeBrainsEaten = 0

		if pl.DeathClass and self:GetWaveActive() then
			pl:SetZombieClass(pl.DeathClass)
			pl.DeathClass = nil
		end
		local classtab = pl:GetZombieClassTable()
		pl:DoHulls(pl:GetZombieClass(), TEAM_UNDEAD)

		if classtab.Model then
			pl:SetModel(classtab.Model)
		elseif classtab.UsePlayerModel then
			local desiredname = pl:GetInfo("cl_playermodel")
			if #desiredname == 0 then
				pl:SelectRandomPlayerModel()
			else
				pl:SetModel(player_manager.TranslatePlayerModel(desiredname))
			end
		elseif classtab.UsePreviousModel then
			local curmodel = string.lower(pl:GetModel())
			if self.RestrictedModels[curmodel] or string.sub(curmodel, 1, 14) ~= "models/player/" then
				pl:SelectRandomPlayerModel()
			end
		elseif classtab.UseRandomModel then
			pl:SelectRandomPlayerModel()
		else
			pl:SetModel("models/player/zombie_classic.mdl")
		end

		local numundead = team.NumPlayers(TEAM_UNDEAD)
		local numhuman = team.NumPlayers(TEAM_HUMAN)

		local dynahp = math.Max(math.floor(self:GetWave() * team.NumPlayers(TEAM_HUMAN)*2/(team.NumPlayers(TEAM_UNDEAD)+1) * 7 * classtab.Health/100), 0)
		if classtab.Boss then dynahp = dynahp/3 end

		local mapname = string.lower(game.GetMap())
		if string.find(mapname, "_obj_", 1, true) or string.find(mapname, "objective", 1, true) then
			dynahp = 0
		end

		pl:SetHealth(classtab.Health + dynahp)

		-- Old zombie hp scaling
		/*if not classtab.Boss and self.OutnumberedHealthBonus > numundead then
			pl:SetHealth(classtab.Health * 2.25 + dynahp)
		end*/

		if classtab.SWEP then
			pl:Give(classtab.SWEP)
		end

		pl:SetNoTarget(true)
		pl:SetMaxHealth(1)

		pl:ResetSpeed()
		pl:SetCrouchedWalkSpeed(classtab.CrouchedWalkSpeed or 0.70)

		if not pl.Revived or not self:GetWaveActive() or CurTime() > self:GetWaveEnd() then
			pl.StartCrowing = 0
		end

		pl:CallZombieFunction("OnSpawned")
	else
		pl.m_PointQueue = 0

		local desiredname = pl:GetInfo("cl_playermodel")
		local modelname = player_manager.TranslatePlayerModel(#desiredname == 0 and self.RandomPlayerModels[math.random(#self.RandomPlayerModels)] or desiredname)
		local lowermodelname = string.lower(modelname)
		if self.RestrictedModels[lowermodelname] then
			modelname = "models/player/alyx.mdl"
			lowermodelname = modelname
		end
		pl:SetModel(modelname)

		local pcol = Vector(pl:GetInfo("cl_playercolor"))
		pcol.x = math.Clamp(pcol.x, 0, 2.5)
		pcol.y = math.Clamp(pcol.y, 0, 2.5)
		pcol.z = math.Clamp(pcol.z, 0, 2.5)
		pl:SetPlayerColor(pcol)

		local wcol = Vector(pl:GetInfo("cl_weaponcolor"))
		wcol.x = math.Clamp(wcol.x, 0, 2.5)
		wcol.y = math.Clamp(wcol.y, 0, 2.5)
		wcol.z = math.Clamp(wcol.z, 0, 2.5)
		pl:SetWeaponColor(wcol)

		-- Cache the voice set.
		if VoiceSetTranslate[lowermodelname] then
			pl.VoiceSet = VoiceSetTranslate[lowermodelname]
		elseif string.find(lowermodelname, "female", 1, true) then
			pl.VoiceSet = "female"
		else
			pl.VoiceSet = "male"
		end

		pl.HumanSpeedAdder = nil

		pl.BonusDamageCheck = CurTime()

		pl:ResetSpeed()
		pl:SetJumpPower(DEFAULT_JUMP_POWER)
		pl:SetCrouchedWalkSpeed(0.65)

		pl:SetNoTarget(false)
		pl:SetMaxHealth(100)

		if self.StartingLoadout then
			self:GiveStartingLoadout(pl)
		elseif pl.m_PreRedeem then
			pl:Give("weapon_zs_redeemers")
			pl:Give("weapon_zs_plank")
		end
	end

	pl.m_PreHurtHealth = pl:Health()

		local oldhands = pl:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		pl:SetHands( hands )
		hands:SetOwner( pl )

		-- Which hands should we use?
		local cl_playermodel = pl:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = pl:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		pl:DeleteOnRemove( hands )

		hands:Spawn()
 	end

end

function GM:SetWave(wave)
	local previouslylocked = {}
	for i, classtab in ipairs(GAMEMODE.ZombieClasses) do
		if not gamemode.Call("IsClassUnlocked", classid) then
			previouslylocked[i] = true
		end
	end

	SetGlobalInt("wave", wave)

	for classid in pairs(previouslylocked) do
		if gamemode.Call("IsClassUnlocked", classid) then
			for _, ent in pairs(ents.FindByClass("logic_classunlock")) do
				local classname = GAMEMODE.ZombieClasses[classid].Name
				if ent.Class == string.lower(classname) then
					ent:Input("onclassunlocked", ent, ent, classname)
				end
			end
		end
	end
end

function GM:WaveStateChanged(newstate)
	if newstate then
		if self:GetWave() == 0 then
			self:SetClosestsToZombie()

			local humans = {}
			for _, pl in pairs(player.GetAll()) do
				if pl:Team() == TEAM_HUMAN and pl:Alive() then
					table.insert(humans, pl)
				end
			end

			if #humans >= 1 then
				for _, pl in pairs(humans) do
					gamemode.Call("GiveDefaultOrRandomEquipment", pl)
					pl.BonusDamageCheck = CurTime()
				end
			end

			-- We should spawn a crate in a random spawn point if no one has any.
			if #ents.FindByClass("prop_arsenalcrate") == 0 then
				/*
				local have = false
				for _, pl in pairs(humans) do
					if pl:HasWeapon("weapon_zs_arsenal") then
						have = true
						break
					end
				end
				*/

				if not have and #humans >= 1 then
					local spawn = self:PlayerSelectSpawn(humans[math.random(#humans)])
					if spawn and spawn:IsValid() then
						local ent = ents.Create("prop_arsenalcrate")
						if ent:IsValid() then
							ent:SetPos(spawn:GetPos())
							ent:Spawn()
							ent:DropToFloor()
							ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
						end
					end
				end
			end
		end

		local prevwave = self:GetWave()

		gamemode.Call("SetWave", prevwave + 1)
		gamemode.Call("SetWaveStart", CurTime())
		gamemode.Call("SetWaveEnd", self:GetWaveStart() + self:GetWaveOneLength() + (self:GetWave() - 1) * (GetGlobalBool("classicmode") and self.TimeAddedPerWaveClassic or self.TimeAddedPerWave))

		umsg.Start("recwavestart")
			umsg.Short(self:GetWave())
			umsg.Float(self:GetWaveEnd())
		umsg.End()

		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_UNDEAD then
				pl.m_LastWaveStartSpawn = CurTime()
				if pl:GetZombieClassTable().Name == "Crow" then
					pl:SetZombieClass(pl.DeathClass or 1)
					pl:UnSpectateAndSpawn()
				elseif not pl:Alive() and not pl.Revive then
					pl:UnSpectateAndSpawn()
				end
			elseif pl:Team() == TEAM_HUMANS then
				local ammotype
				local wep = pl:GetActiveWeapon()
				if not wep:IsValid() then
					ammotype = "pistol"
				end

				if not ammotype then
					ammotype = wep:GetPrimaryAmmoTypeString()
					if not GAMEMODE.AmmoResupply[ammotype] then
						ammotype = "pistol"
					end
				end

				pl:GiveAmmo(GAMEMODE.AmmoResupply[ammotype], ammotype)
			end
		end

		local curwave = self:GetWave()
		for _, ent in pairs(ents.FindByClass("logic_waves")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwavestart", ent, ent, curwave)
			end
		end
		for _, ent in pairs(ents.FindByClass("logic_wavestart")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwavestart", ent, ent, curwave)
			end
		end
	elseif self:GetWave() == self:GetNumberOfWaves() then
		gamemode.Call("EndRound", TEAM_HUMAN)

		local curwave = self:GetWave()
		for _, ent in pairs(ents.FindByClass("logic_waves")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwaveend", ent, ent, curwave)
			end
		end
		for _, ent in pairs(ents.FindByClass("logic_waveend")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwaveend", ent, ent, curwave)
			end
		end
	else
		gamemode.Call("SetWaveStart", CurTime() + (GetGlobalBool("classicmode") and self.WaveIntermissionLengthClassic or self.WaveIntermissionLength))

		umsg.Start("recwaveend")
			umsg.Short(self:GetWave())
			umsg.Float(self:GetWaveStart())
		umsg.End()

		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_HUMAN and pl:Alive() then
				if self.EndWaveHealthBonus > 0 then
					pl:SetHealth(math.min(pl:GetMaxHealth(), pl:Health() + self.EndWaveHealthBonus))
				end
			elseif pl:Team() == TEAM_UNDEAD and not pl:Alive() and not pl.Revive then
				local curclass = pl.DeathClass or pl:GetZombieClass()
				local crowindex = GAMEMODE.ZombieClasses["Crow"].Index
				pl:SetZombieClass(crowindex)
				pl:DoHulls(crowindex, TEAM_UNDEAD)
				pl.DeathClass = nil
				pl:UnSpectateAndSpawn()
				pl.DeathClass = curclass
			end

			pl.SkipCrow = nil
		end

		local curwave = self:GetWave()
		for _, ent in pairs(ents.FindByClass("logic_waves")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwaveend", ent, ent, curwave)
			end
		end
		for _, ent in pairs(ents.FindByClass("logic_waveend")) do
			if ent.Wave == curwave or ent.Wave == -1 then
				ent:Input("onwaveend", ent, ent, curwave)
			end
		end
	end
end

function GM:PlayerSwitchFlashlight(pl, newstate)
	if pl:Team() == TEAM_UNDEAD then
		if pl:Alive() then
			if IsValid(pl.FakeFlashlight) then
				pl:RemoveFakeFlashlight()
				pl:SendLua("gamemode.Call(\"ToggleZombieVision\", false)")
			else
				pl:CreateFakeFlashlight()
				pl:SendLua("gamemode.Call(\"ToggleZombieVision\", true)")
			end
		end

		return false
	end

	return true
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	return 350
end

concommand.Add("_zs_requestlockedclasses", function(sender, command, arguments)
	local tab = {}
	for i, classtab in ipairs(GAMEMODE.ZombieClasses) do
		tab[i] = tostring(classtab.Locked and 2 or classtab.Unlocked and 1 or 0)
	end

	umsg.Start("reclockedclasses", sender)
		umsg.String(table.concat(tab, ","))
	umsg.End()
end)

concommand.Add("zs_class", function(sender, command, arguments)
	if sender:Team() ~= TEAM_UNDEAD or sender.Revive or GAMEMODE.PantsMode or GAMEMODE:IsClassicMode() then return end

	local classname = table.concat(arguments, " ")
	local classtab = GAMEMODE.ZombieClasses[classname]
	if not classtab or classtab.Hidden and not (classtab.CanUse and classtab:CanUse(sender)) then return end


	if not gamemode.Call("IsClassUnlocked", classname) then
		sender:SplitMessage("<font=ZSHUDFontSmall>That class is not unlocked yet. It will be unlocked at the start of wave "..classtab.Wave..".")
	elseif sender:GetZombieClassTable().Name == classname and not sender.DeathClass then
		sender:SplitMessage("You are already a "..classtab.Name.."!")
	else
		sender:SplitMessage("You will spawn as a "..classtab.Name..".")
		sender.DeathClass = classtab.Index
	end
end)

function EnableCollisions(ent, extrarad, teamid, timnam)
	if ent:IsValid() then
		local pushout = false

		local timeout = ent._EnableCollisionsTimeout and CurTime() >= ent._EnableCollisionsTimeout

		local rate = 900 * FrameTime()
		local center = ent:LocalToWorld(ent:OBBCenter())
		for _, pl in pairs(ents.FindInSphere(center, ent:BoundingRadius() * 0.5 + extrarad)) do
			if pl:IsValid() and pl:IsPlayer() and pl:Alive() and (not teamid or pl:Team() == teamid) then
				pushout = true

				if timeout then
					if ent.IsBarricadeObject and pl:Team() == TEAM_HUMAN then
						pl:SetBarricadeGhosting(true)
					end
				else
					local plpos = pl:LocalToWorld(pl:OBBCenter())
					local diff = plpos - center
					diff.z = 0
					heading = diff:GetNormalized() * rate
					local starttrace = plpos + heading
					if util.TraceLine({start = starttrace, endpos = starttrace + Vector(0, 0, -80), mask = MASK_SOLID_BRUSHONLY}).Hit then
						pl:SetVelocity(heading)
					end
				end
			end
		end

		if pushout and not timeout then return end

		if ent.OldMaterial then
			ent:SetMaterial(ent.OldMaterial)
			ent.OldMaterial = nil
		end
		local col = ent.OldColor
		if col then
			ent:SetColor(col)
			ent.OldColor = nil
		end
		if ent.OldCollisionGroup then
			ent:SetCollisionGroup(ent.OldCollisionGroup)
			ent.OldCollisionGroup = nil
		end
	end

	timer.Destroy(timnam)
end
