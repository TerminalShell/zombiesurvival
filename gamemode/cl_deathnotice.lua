if not killicon.GetFont then
	killicon.OldAddFont = killicon.AddFont
	killicon.OldAddAlias = killicon.AddAlias
	killicon.OldAdd = killicon.Add

	local storedfonts = {}
	local storedicons = {}

	function killicon.AddFont(sClass, sFont, sLetter, cColor)
		storedfonts[sClass] = {sFont, sLetter, cColor}
		return killicon.OldAddFont(sClass, sFont, sLetter, cColor)
	end

	function killicon.Add(sClass, sTexture, cColor)
		storedicons[sClass] = {surface.GetTextureID(sTexture), cColor}
		return killicon.OldAdd(sClass, sTexture, cColor)
	end

	function killicon.AddAlias(sClass, sBaseClass)
		if storedfonts[sClass] then
			return killicon.AddFont(sBaseClass, storedfonts[sClass][1], storedfonts[sClass][2], storedfonts[sClass][3])
		elseif storedicons[sClass] then
			return killicon.Add(sBaseClass, storedicons[sClass][1], storedicons[sClass][2])
		end
	end

	function killicon.Get(sClass)
		return killicon.GetFont(sClass) or killicon.GetIcon(sClass)
	end

	function killicon.GetFont(sClass)
		return storedfonts[sClass]
	end

	function killicon.GetIcon(sClass)
		return storedicons[sClass]
	end
end

-- Kill icons kinda need to be here instead of the weapon script.

killicon.AddFont("default", "zsdeathnoticecs", "C", color_white)
killicon.AddAlias("suicide", "default")

killicon.AddFont("prop_physics", "zsdeathnotice", "9", color_white)
killicon.AddFont("weapon_smg1", "zsdeathnotice", "/", color_white)
killicon.AddFont("weapon_357", "zsdeathnotice", ".", color_white)
killicon.AddFont("weapon_ar2", "zsdeathnotice", "2", color_white)
killicon.AddFont("crossbow_bolt", "zsdeathnotice", "1", color_white)
killicon.AddFont("weapon_shotgun", "zsdeathnotice", "0", color_white)
killicon.AddFont("rpg_missile", "zsdeathnotice", "3", color_white)
killicon.AddFont("npc_grenade_frag", "zsdeathnotice", "4", color_white)
killicon.AddFont("weapon_pistol", "zsdeathnotice", "-", color_white)
killicon.AddFont("prop_combine_ball", "zsdeathnotice", "8", color_white)
killicon.AddFont("grenade_ar2", "zsdeathnotice", "7", color_white)
killicon.AddFont("weapon_stunstick", "zsdeathnotice", "!", color_white)
killicon.AddFont("weapon_slam", "zsdeathnotice", "*", color_white)
killicon.AddFont("weapon_crowbar", "zsdeathnotice", "6", color_white)

killicon.AddFont("headshot", "zsdeathnoticecs", "D", color_white)
killicon.Add("redeem", "killicon/redeem", color_white)

killicon.Add("weapon_zs_zombie", "zombiesurvival/killicons/zombie", color_white)
killicon.Add("weapon_zs_newzombie", "zombiesurvival/killicons/zombie", color_white)
killicon.Add("weapon_zs_freshdead", "zombiesurvival/killicons/zombie", color_white)
killicon.Add("weapon_zs_classiczombie", "zombiesurvival/killicons/zombie", color_white)
killicon.Add("weapon_zs_zombietorso", "zombiesurvival/killicons/torso", color_white)
killicon.Add("weapon_zs_zombielegs", "zombiesurvival/killicons/legs", color_white)
killicon.Add("weapon_zs_fastzombielegs", "zombiesurvival/killicons/legs", color_white)
killicon.Add("weapon_zs_nightmare", "zombiesurvival/killicons/nightmare", color_white)
killicon.Add("weapon_zs_pukepus", "zombiesurvival/killicons/pukepus", color_white)
killicon.Add("weapon_zs_ticklemonster", "zombiesurvival/killicons/tickle", color_white)
killicon.Add("weapon_zs_crow", "zombiesurvival/killicons/crow", color_white)
killicon.Add("weapon_zs_fastzombie", "zombiesurvival/killicons/fastzombie", color_white)
killicon.Add("weapon_zs_poisonzombie", "zombiesurvival/killicons/poisonzombie", color_white)
killicon.Add("weapon_zs_chemzombie", "zombiesurvival/killicons/chemzombie", color_white)
killicon.Add("weapon_zs_ghoul", "zombiesurvival/killicons/ghoul", color_white)
killicon.Add("dummy_chemzombie", "zombiesurvival/killicons/chemzombie", color_white)
killicon.Add("weapon_zs_wraith", "zombiesurvival/killicons/wraithv2", color_white)
killicon.Add("weapon_zs_headcrab", "zombiesurvival/killicons/headcrab", color_white)
killicon.Add("weapon_zs_fastheadcrab", "zombiesurvival/killicons/fastheadcrab", color_white)
killicon.Add("weapon_zs_poisonheadcrab", "zombiesurvival/killicons/poisonheadcrab", color_white)
killicon.Add("projectile_poisonspit", "zombiesurvival/killicons/projectile_poisonspit", color_white)
killicon.Add("projectile_poisonflesh", "zombiesurvival/killicons/projectile_poisonflesh", color_white)
killicon.Add("projectile_poisonpuke", "zombiesurvival/killicons/pukepus", color_white)
killicon.Add("weapon_zs_special_wow", "sprites/glow04_noz", color_white)

killicon.Add("prop_turret", "zombiesurvival/killicons/prop_gunturret", color_white)
killicon.Add("weapon_zs_turret", "zombiesurvival/killicons/prop_gunturret", color_white)
killicon.Add("weapon_zs_turretremove", "zombiesurvival/killicons/prop_gunturret", color_white)
killicon.AddFont("projectile_zsgrenade", "zsdeathnotice", "4", color_white)
killicon.AddFont("weapon_zs_grenade", "zsdeathnotice", "4", color_white)
killicon.AddFont("prop_detpack", "zsdeathnotice", "*", color_white)
killicon.AddFont("weapon_zs_detpack", "zsdeathnotice", "*", color_white)
killicon.AddFont("weapon_zs_detpackremote", "zsdeathnotice", "*", color_white)
killicon.AddFont("weapon_zs_stubber", "zsdeathnoticecs", "n", color_white)
killicon.AddFont("weapon_zs_tosser", "zsdeathnotice", "/", color_white)
killicon.AddFont("weapon_zs_owens", "zsdeathnotice", "-", color_white)
killicon.AddFont("weapon_zs_wolfos", "zsdeathnotice", "-", color_white)
killicon.AddFont("weapon_zs_battleaxe", "zsdeathnoticecs", "c", color_white)
killicon.AddFont("weapon_zs_boomstick", "zsdeathnotice", "0", color_white)
killicon.AddFont("weapon_zs_annabelle", "zsdeathnotice", "0", color_white)
killicon.AddFont("weapon_zs_blaster", "zsdeathnotice", "0", color_white)
killicon.AddFont("weapon_zs_eraser", "zsdeathnoticecs", "u", color_white)
killicon.AddFont("weapon_zs_sweeper", "zsdeathnoticecs", "k", color_white)
killicon.AddFont("weapon_zs_barricadekit", "zsdeathnotice", "3", color_white)
killicon.AddFont("weapon_zs_bulletstorm", "zsdeathnoticecs", "m", color_white)
killicon.AddFont("weapon_zs_crossbow", "zsdeathnotice", "1", color_white)
killicon.AddFont("projectile_arrow", "zsdeathnotice", "1", color_white)
killicon.AddFont("weapon_zs_deagle", "zsdeathnoticecs", "f", color_white)
killicon.AddFont("weapon_zs_glock", "zsdeathnoticecs", "c", color_white)
killicon.AddFont("weapon_zs_ricochet", "zsdeathnotice", ".", color_white)
killicon.AddFont("weapon_zs_peashooter", "zsdeathnoticecs", "a", color_white)
killicon.AddFont("weapon_zs_handyman", "zsdeathnoticecs", "a", color_white)
killicon.AddFont("weapon_zs_daring", "zsdeathnoticecs", "a", color_white)
killicon.AddFont("weapon_zs_tinyslug", "zsdeathnoticecs", "n", color_white)
killicon.AddFont("weapon_zs_knife", "zsdeathnoticecs", "j", color_white)
killicon.AddFont("weapon_zs_sprayer", "zsdeathnoticecs", "l", color_white)
killicon.AddFont("weapon_zs_shredder", "zsdeathnoticecs", "x", color_white)
killicon.AddFont("weapon_zs_machinery", "zsdeathnoticecs", "d", color_white)
killicon.AddFont("weapon_zs_inferno", "zsdeathnoticecs", "e", color_white)
killicon.AddFont("weapon_zs_stalker", "zsdeathnoticecs", "w", color_white)
killicon.AddFont("weapon_zs_reaper", "zsdeathnoticecs", "q", color_white)
killicon.AddFont("weapon_zs_crackler", "zsdeathnoticecs", "t", color_white)
killicon.AddFont("weapon_zs_adonis", "zsdeathnotice", "2", color_white)
killicon.AddFont("weapon_zs_akbar", "zsdeathnoticecs", "b", color_white)
killicon.AddFont("weapon_zs_defender", "zsdeathnoticecs", "v", color_white)
killicon.AddFont("weapon_zs_redeemers", "zsdeathnoticecs", "s", color_white)
killicon.Add("weapon_zs_axe", "killicon/zs_axe", color_white)
killicon.Add("weapon_zs_sawhack", "killicon/zs_axe", color_white)
killicon.Add("weapon_zs_keyboard", "killicon/zs_keyboard", color_white)
killicon.Add("weapon_zs_sledge", "killicon/zs_sledgehammer", color_white)
killicon.Add("weapon_zs_megamasher", "killicon/zs_sledgehammer", color_white)
killicon.Add("weapon_zs_pan", "killicon/zs_fryingpan", color_white)
killicon.Add("weapon_zs_pot", "killicon/zs_pot", color_white)
killicon.Add("weapon_zs_plank", "killicon/zs_plank", color_white)
killicon.Add("weapon_zs_hammer", "killicon/zs_hammer", color_white)
killicon.Add("weapon_zs_electrohammer", "killicon/zs_hammer", color_white)
killicon.Add("weapon_zs_shovel", "killicon/zs_shovel", color_white)
killicon.AddFont("weapon_zs_crowbar", "zsdeathnotice", "6", color_white)
killicon.AddFont("weapon_zs_stunstick", "zsdeathnotice", "!", color_white)

usermessage.Hook("CrowKilledByCrow", function(message)
	local victim = message:ReadEntity()
	local attacker = message:ReadEntity()

	if attacker:IsValid() and victim:IsValid() then
		gamemode.Call("AddDeathNotice", attacker:Name(), TEAM_UNDEAD, "weapon_zs_crow", victim:Name(), TEAM_UNDEAD)
	end
end)

usermessage.Hook("PlayerKilledByPlayer", function(message)
	local victim = message:ReadEntity()
	local attacker = message:ReadEntity()

	local inflictor = message:ReadString()

	local victimteam = message:ReadChar()
	local attackerteam = message:ReadChar()

	local headshot = message:ReadBool()

	if victim:IsValid() and attacker:IsValid() then
		local attackername = attacker:Name()
		local victimname = victim:Name()

		if victim == MySelf then
			if victimteam == TEAM_HUMAN then
				gamemode.Call("LocalPlayerDied", attackername)
			end
		elseif attacker == MySelf then
			if attacker:Team() == TEAM_UNDEAD then
				gamemode.Call("FloatingScore", victim, "floatingscore_und", 1, 0)
			end
		end

		victim:CallZombieFunction("OnKilled", attacker, attacker, attacker == victim, headshot, DamageInfo())

		print(attackername.." killed "..victimname.." with "..inflictor)

		gamemode.Call("AddDeathNotice", attackername, attackerteam, inflictor, victimname, victimteam, headshot)
	end
end)

usermessage.Hook("PlayerKilledByPlayers", function(message)
	local victim = message:ReadEntity()
	local attacker = message:ReadEntity()
	local assister = message:ReadEntity()

	local inflictor = message:ReadString()

	local victimteam = message:ReadChar()
	local attackerteam = message:ReadChar()

	local headshot = message:ReadBool()

	if victim:IsValid() and attacker:IsValid() and assister and assister:IsValid() then
		local attackername = attacker:Name()
		local assistername = assister:Name()
		local victimname = victim:Name()

		if victim == MySelf and victimteam == TEAM_HUMAN then
			gamemode.Call("LocalPlayerDied", attackername.." and "..assistername)
		end

		victim:CallZombieFunction("OnKilled", attacker, attacker, attacker == victim, headshot, DamageInfo())

		print(attackername.." and "..assistername.." killed "..victimname.." with "..inflictor)

		gamemode.Call("AddDeathNotice", attackername.." and "..assistername, attackerteam, inflictor, victimname, victimteam, headshot)
	end
end)

usermessage.Hook("PlayerKilledSelf", function(message)
	local victim = message:ReadEntity()
	local victimteam = message:ReadChar()

	if victim:IsValid() then
		if victim == MySelf and victimteam == TEAM_HUMAN then
			gamemode.Call("LocalPlayerDied")
		end

		victim:CallZombieFunction("OnKilled", victim, victim, true, false, DamageInfo())

		local victimname = victim:Name()

		print(victimname.." killed themself")

		gamemode.Call("AddDeathNotice", nil, 0, "suicide", victimname, victimteam)
	end
end)

usermessage.Hook("PlayerRedeemed", function(message)
	local pl = message:ReadEntity()
	if pl:IsValid() then
		gamemode.Call("AddDeathNotice", nil, 0, "redeem", pl:Name(), TEAM_HUMAN)
		if pl == MySelf then
			GAMEMODE:SplitMessage("<color=cyan>You redeemed!")
		end
	end
end)

usermessage.Hook("PlayerKilled", function(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = "#" .. message:ReadString()
	local victimteam = message:ReadChar()

	if victim:IsValid() then
		if victim == MySelf and victimteam == TEAM_HUMAN then
			gamemode.Call("LocalPlayerDied")
		end

		victim:CallZombieFunction("OnKilled", attacker, NULL, attacker == victim, false, DamageInfo())

		local victimname = victim:Name()

		print(victimname.." was killed by "..attacker.." with "..inflictor)

		gamemode.Call("AddDeathNotice", attacker, -1, inflictor, victimname, victimteam)
	end
end)

usermessage.Hook("PlayerKilledNPC", function(message)
	local victim = "#"..message:ReadString()
	local inflictor = message:ReadString()
	local attacker = message:ReadEntity()

	local attackername = attacker:Name()

	print(attackername.." killed "..victim.." with "..inflictor)

	gamemode.Call("AddDeathNotice", attackername, attacker:Team(), inflictor, victim, -1)
end)

usermessage.Hook("NPCKilledNPC", function(message)
	local victim = "#"..message:ReadString()
	local inflictor = message:ReadString()
	local attacker = "#"..message:ReadString()

	print(attacker.." killed "..victim.." with "..inflictor)

	gamemode.Call("AddDeathNotice", attacker, -1, inflictor, victim, -1)
end)

local NPC_Color = Color(250, 50, 50, 255)
local Deaths = {}
function GM:AddDeathNotice(Victim, team1, Inflictor, Attacker, team2, headshot)
	local Death = {victim = Victim,
	attacker = Attacker,
	time = CurTime(),
	left = Victim,
	right = Attacker,
	icon = Inflictor}

	if Death.left then
		Death.left = string.Replace(Death.left, "#", "")
	end
	if Death.right then
		Death.right = string.Replace(Death.right, "#", "")
	end

	if team1 == -1 then Death.color1 = table.Copy(NPC_Color)
	else Death.color1 = table.Copy(team.GetColor(team1)) end

	if team2 == -1 then Death.color2 = table.Copy(NPC_Color)
	else Death.color2 = table.Copy(team.GetColor(team2)) end

	if Death.left == Death.right then
		Death.left = nil
		Death.icon = "suicide"
	end

	Death.headshot = headshot

	table.insert(Deaths, Death)
end

local function DrawDeath(x, y, death)
	surface.SetFont("ZSHUDFontSmallest")
	local texw, texh = surface.GetTextSize(death.right)
	local fadein = 1 - math.min(math.sqrt((CurTime() - death.time) * 2), 1)
	local fadeout = death.time + 6 - CurTime()
	local alpha = math.min(math.max(fadeout * 255, 0), 255)
	death.color1.a = alpha
	death.color2.a = alpha

	x = x + fadein * 400

	x = x - texw
	draw.SimpleText(death.right, "ZSHUDFontSmallest", x, y, death.color2, TEXT_ALIGN_LEFT)
	x = x - 8

	if death.headshot then
		local hsw, hsh = killicon.GetSize("headshot")
		x = x - hsw * 0.5
		killicon.Draw(x, y, "headshot", alpha)
		x = x - hsw * 0.5
	end

	local iconwidth, iconheight = killicon.GetSize(death.icon)

	x = x - iconwidth * 0.5 - 1
	killicon.Draw(x, y, death.icon, alpha)
	x = x - iconwidth * 0.5

	if death.left then
		draw.SimpleText(death.left, "ZSHUDFontSmallest", x - 8, y, death.color1, TEXT_ALIGN_RIGHT)
	end

	return y + math.max(iconheight, texh) + 1
end

function GM:DrawDeathNotice(x, y)
	if #Deaths == 0 then return end

	local done = true
	for k, Death in pairs(Deaths) do
		if Death.time + 6 > CurTime() then
			done = false
			y = DrawDeath(x, y, Death)
		end
	end

	if done then
		Deaths = {}
	end
end
