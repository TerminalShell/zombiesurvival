if not MySelf then
	MySelf = NULL
end
hook.Add("Think", "GetLocal", function()
	MySelf = LocalPlayer()
	if MySelf:IsValid() then
		hook.Remove("Think", "GetLocal")
		if not GAMEMODE.HookGetLocal then
			GAMEMODE.HookGetLocal = function(g) end
		end
		gamemode.Call("HookGetLocal", MySelf)
		RunConsoleCommand("PostPlayerInitialSpawn")
	end
end)

-- Sometimes persistent ones don't get created.
local dummy = CreateClientConVar("_zs_dummyconvar", 1, false, false)
local oldCreateClientConVar = CreateClientConVar
function CreateClientConVar(...)
	return oldCreateClientConVar(...) or dummy
end

include("shared.lua")
include("cl_voice.lua")
include("cl_util.lua")
include("cl_options.lua")
include("obj_player_extend_cl.lua")
include("cl_scoreboard.lua")
include("cl_targetid.lua")
include("cl_postprocess.lua")
include("cl_splitmessage.lua")

include("vgui/dgamestate.lua")
include("vgui/dteamcounter.lua")
include("vgui/dmodelpanelex.lua")
include("vgui/dammocounter.lua")
include("vgui/dteamheading.lua")

include("vgui/pmainmenu.lua")
include("vgui/poptions.lua")
include("vgui/phelp.lua")
include("vgui/pclassselect.lua")
include("vgui/pweapons.lua")
include("vgui/pendboard.lua")
include("vgui/pworth.lua")
include("vgui/ppointshop.lua")
include("vgui/dpingmeter.lua")
include("vgui/dsidemenu.lua")

include("cl_dermaskin.lua")
include("cl_deathnotice.lua")
include("cl_floatingscore.lua")
include("cl_hint.lua")

include("cl_hitdamagenumbers.lua")

w, h = ScrW(), ScrH()
NEXTMAP = ""

-- Remove when model decal crash is fixed.
--function util.Decal()
--end

function GM:ClickedPlayerButton(pl, button)
end

function GM:ClickedEndBoardPlayerButton(pl, button)
end

GM.InputMouseX = 0
GM.InputMouseY = 0
function GM:_InputMouseApply(cmd, x, y, ang)
	self.InputMouseX = x
	self.InputMouseY = y

	if MySelf:IsHolding() and MySelf:KeyDown(IN_WALK) then
		RunConsoleCommand("_zs_rotateang", self.InputMouseX, self.InputMouseY)
		return true
	end
end

function GM:_GUIMousePressed(mc)
	if self.HumanMenuPanel and self.HumanMenuPanel:Valid() and self.HumanMenuPanel:IsVisible() and MySelf:KeyDown(self.MenuKey) then
		local dir = gui.ScreenToVector(gui.MousePos())
		local ent = util.TraceLine({start = MySelf:EyePos(), endpos = MySelf:EyePos() + dir * self.CraftingRange, filter = MySelf, mask = MASK_SOLID}).Entity
		if ent:IsValid() and not ent:IsPlayer() and (ent:GetMoveType() == MOVETYPE_NONE or ent:GetMoveType() == MOVETYPE_VPHYSICS) and ent:GetSolid() == SOLID_VPHYSICS then
			if mc == MOUSE_LEFT then
				if ent == self.CraftingEntity then
					self.CraftingEntity = nil
				else
					self.CraftingEntity = ent
				end
			elseif mc == MOUSE_RIGHT and self.CraftingEntity and self.CraftingEntity:IsValid() then
				RunConsoleCommand("_zs_craftcombine", self.CraftingEntity:EntIndex(), ent:EntIndex())
				self.CraftingEntity = nil
			end
		end
	end
end

function GM:DrawAmmo(current, maximum, total, screenscale)
	local wid, hei = 200 * screenscale, 64 * screenscale
	local x, y = w - wid - 16, h - hei - 64

	local midhei = y + hei * 0.5

	draw.RoundedBox(8, x, y, wid, hei, color_black_alpha90)
	draw.SimpleText("Ammo", "ZSHUDFontSmall", x + 8, y + 8, COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local col
	if current == 0 then
		col = COLOR_RED
	elseif current <= maximum * 0.5 then
		col = COLOR_YELLOW
	else
		col = COLOR_GRAY
	end
	draw.SimpleText(current, "ZSHUDFont", x + wid - 8, y + 8, col, TEXT_ALIGN_RIGHT)
	draw.SimpleText(maximum, "ZSHUDFont", x + wid - 8, y + 8, col, TEXT_ALIGN_RIGHT)

	if total == 0 then
		draw.SimpleText(total, "ZSHUDFontSmall", x + wid - 8, y + hei - 8, COLOR_RED, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(total, "ZSHUDFontSmall", x + wid - 8, y + hei - 8, COLOR_GRAY, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end
end

function GM:TryHumanPickup(pl, entity)
end

function GM:AddExtraOptions(list, window)
end

function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

function GM:HUDWeaponPickedUp(wep)
end

function GM:_HUDWeaponPickedUp(wep)
	if MySelf:Team() == TEAM_HUMAN and not wep.NoPickupNotification then
		self:Rewarded(wep:GetClass())
	end
end

function GM:HUDItemPickedUp(itemname)
end

function GM:HUDAmmoPickedUp(itemname, amount)
end

--[[if not ents.FixedIsValid then
	ents.FixedIsValid = true

	local function check(t)
		local t2 = {}

		for k, v in pairs(t) do
			if v:IsValid() then t2[#t2 + 1] = v end
		end

		return t2
	end

	local oldfindinsphere = ents.FindInSphere
	function ents.FindInSphere(...)
		return check(oldfindinsphere(...))
	end

	local oldfindinbox = ents.FindInBox
	function ents.FindInBox(...)
		return check(oldfindinbox(...))
	end

	local oldfindincone = ents.FindInCone
	function ents.FindInCone(...)
		return check(oldfindincone(...))
	end

	local oldgetall = player.GetAll
	function player.GetAll(...)
		return check(oldgetall(...))
	end
end]]

function GM:InitPostEntity()
end

local currentpower = 0
local spawngreen = 0
local texFearMeter = surface.GetTextureID("zombiesurvival/fearometer")
local texNeedle = surface.GetTextureID("zombiesurvival/fearometerneedle")
local texEyeGlow = surface.GetTextureID("Sprites/light_glow02_add_noz")
function GM:DrawFearMeter(power, screenscale)
	screenscale = screenscale * 0.5

	if currentpower < power then
		currentpower = math.min(power, currentpower + FrameTime() * (math.tan(currentpower) * 2 + 0.05))
	elseif power < currentpower then
		currentpower = math.max(power, currentpower - FrameTime() * (math.tan(currentpower) * 2 + 0.05))
	end

	local wid, hei = 512 * screenscale, 512 * screenscale
	local mx, my = w * 0.5 - wid * 0.5, h - hei

	surface.SetTexture(texFearMeter)
	surface.SetDrawColor(140, 140, 140, 220)
	surface.DrawTexturedRect(mx, my, wid, hei)
	if currentpower >= 0.75 then
		local pulse = CurTime() % 3 - 1
		if pulse > 0 then
			pulse = pulse ^ 2
			local pulsesize = pulse * screenscale * 72
			surface.SetDrawColor(140, 140, 140, 120 - pulse * 120)
			surface.DrawTexturedRect(mx - pulsesize, my - pulsesize, wid + pulsesize * 2, hei + pulsesize * 2)
		end
	end

	surface.SetTexture(texNeedle)
	surface.SetDrawColor(160, 160, 160, 200)
	local rot = math.Clamp((0.5 - currentpower) + math.sin(RealTime() * 10) * 0.01, -0.5, 0.5) * 300
	surface.DrawTexturedRectRotated(w * 0.5 - math.max(0, rot * wid * -0.0001), h - hei * 0.5 - math.abs(rot) * hei * 0.00015, wid, hei, rot)

	if MySelf:Team() == TEAM_UNDEAD then
		if not GetGlobalBool("DynamicSpawningDisabled", false) then
			local obs = MySelf:GetObserverTarget()
			spawngreen = math.Approach(spawngreen, self:DynamicSpawnIsValid(obs and obs:IsValid() and obs:IsPlayer() and obs:Team() == TEAM_UNDEAD and obs or MySelf) and 1 or 0, FrameTime() * 4)

			local sy = my + hei * 0.6953
			local size = wid * 0.085

			surface.SetTexture(texEyeGlow)
			surface.SetDrawColor(220 * (1 - spawngreen), 220 * spawngreen, 0, 220)
			surface.DrawTexturedRectRotated(mx + wid * 0.459, sy, size, size, 0)
			surface.DrawTexturedRectRotated(mx + wid * 0.525, sy, size, size, 0)
		end

		--draw.SimpleText("Damage Resistance", "ZSHUDFontTiny", w * 0.5, h - 42, color_white, TEXT_ALIGN_CENTER)
	end
end

GM.LastTimeDead = 0
GM.LastTimeAlive = 0

function GM:TrackLastDeath()
	if MySelf:Alive() then
		self.LastTimeAlive = CurTime()
	else
		self.LastTimeDead = CurTime()
	end
end

function GM:IsClassicMode()
	return GetGlobalBool("classicmode")
end

local vecfake = Vector(0, 0, 32000)
function GM:FakeFlashlightsThink()
	for _, ent in pairs(ents.FindByClass("class C_EnvProjectedTexture")) do
		local owner = ent:GetOwner()
		if owner == LocalPlayer() then
			ent:SetPos(EyePos())
			ent:SetAngles(EyeAngles())
		elseif owner ~= NULL then
			ent:SetPos(vecfake)
		end
	end
end

function GM:PreRender()
	self:FakeFlashlightsThink()
end

local nobaby = CreateClientConVar("zs_nobaby", 0, true, false)
local noclassicwarning = CreateClientConVar("zs_noclassicwarning", 0, true, false)
local lastwarntim = -1
GM.HeartBeatTime = 0
GM.FOVLerp = 1
GM.HurtEffect = 0

GM.PrevHealth = 0
function GM:_Think()
	self:FakeFlashlightsThink()

	if GetGlobalBool("classicmode") and not self.ClassicWarning then
		self.ClassicWarning = true
		if not noclassicwarning:GetBool() then
			Derma_Query("This server is running Zombie Survival in 'Classic Mode'\nClassic Mode is a setting which greatly alters gameplay. Things that are changed:\n* No selection of zombie classes. Everyone uses the Classic Zombie class\n* No barricading tools such as nailing or turrets\n* More but faster waves\n\nThis is NOT original Zombie Survival!\n\n-- Servers which run classic mode will display CLASSIC MODE in the bottom left of the screen --", "Warning!", "OK", function() end, "OK and don't pop this message up anymore", function() RunConsoleCommand("zs_noclassicwarning", "1") end)
		end
	end

	local health = MySelf:Health()
	if self.PrevHealth and health < self.PrevHealth then
		self.HurtEffect = math.min(self.HurtEffect + (self.PrevHealth - health) * 0.02, 1.5)
	else
		self.HurtEffect = math.max(0, self.HurtEffect - FrameTime() * 0.65)
	end
	self.PrevHealth = health

	self:TrackLastDeath()

	local endtime = self:GetWaveActive() and self:GetWaveEnd() or self:GetWaveStart()
	if endtime ~= -1 then
		local timleft = math.max(0, endtime - CurTime())
		if timleft <= 10 and lastwarntim ~= math.ceil(timleft) then
			lastwarntim = math.ceil(timleft)
			if 0 < lastwarntim and not nobaby:GetBool() then
				surface.PlaySound("buttons/lightswitch2.wav")
			end
		end
	end

	local myteam = MySelf:Team()

	if not GetGlobalBool("beatsdisabled", false) then
		self:PlayBeats(myteam, self:CachedFearPower())
	end

	if myteam == TEAM_HUMAN then
		local wep = MySelf:GetActiveWeapon()
		if wep:IsValid() and wep.GetIronsights and wep:GetIronsights() then
			self.FOVLerp = math.Approach(self.FOVLerp, wep.IronsightsMultiplier or 0.6, FrameTime() * 4)
		else
			self.FOVLerp = math.Approach(self.FOVLerp, 1, FrameTime() * 5)
		end

		if MySelf:GetBarricadeGhosting() then
			MySelf:BarricadeGhostingThink()
		end
	else
		self.HeartBeatTime = self.HeartBeatTime + (6 + self:CachedFearPower() * 5) * FrameTime()

		if not MySelf:Alive() then
			self:ToggleZombieVision(false)
		end
	end

	for _, pl in pairs(player.GetAll()) do
		local tab = pl:GetZombieClassTable()
		if pl:Team() == TEAM_UNDEAD and tab.BuildBonePositions then
			pl.WasBuildingBonePositions = true
			pl:ResetBones()
			tab.BuildBonePositions(tab, pl)
		elseif pl.WasBuildingBonePositions then
			pl.WasBuildingBonePositions = nil
			pl:ResetBones()
		end
	end
end

function GM:ShouldPlayBeats(teamid, fear)
	return not self.RoundEnded
end

local cv_ShouldPlayMusic = CreateClientConVar("zs_playmusic", 1, true, false)
local NextBeat = 0
local LastBeatLevel = 0
function GM:PlayBeats(teamid, fear)
	if RealTime() <= NextBeat or not gamemode.Call("ShouldPlayBeats", teamid, fear) then return end

	if LASTHUMAN and cv_ShouldPlayMusic:GetBool() and not wave == 10 then
		MySelf:EmitSound(LASTHUMANSOUND, 0, 100, self.BeatsVolume) --surface.PlaySound(LASTHUMANSOUND)
		NextBeat = RealTime() + SoundDuration(LASTHUMANSOUND) * 3
		return
elseif LASTHUMAN and cv_ShouldPlayMusic:GetBool() then
		MySelf:EmitSound(LASTHUMANSOUND, 0, 100, self.BeatsVolume) --surface.PlaySound(LASTHUMANSOUND)
		NextBeat = RealTime() + SoundDuration(LASTHUMANSOUND) * 3
		return
	end

	if fear <= 0 or not self.BeatsEnabled then return end

	local beats = self.Beats[teamid == TEAM_HUMAN and self.BeatSetHuman or self.BeatSetZombie]
	if not beats then return end

	LastBeatLevel = math.Approach(LastBeatLevel, math.ceil(fear * 10), 3)

	local snd = beats[LastBeatLevel]
	if snd then
		MySelf:EmitSound(snd, 0, 100, self.BeatsVolume)
		NextBeat = RealTime() + SoundDuration(snd) - 0.025
	end
end

local colHealth = Color(0, 130, 0, 200)
local colPoison = Color(220, 220, 0, 200)
function GM:DrawHealthBar(x, y, health, maxhealth, bartexture, screenscale, poisondamage)
	health = math.max(0, health)

	local wid, hei = 512 * screenscale, 256 * screenscale

	if health > 0 then
		local healthfrac = math.min(1, health / maxhealth)
		local barx = x + screenscale * 72
		local bary = y + screenscale * 100
		local maxbarwidth = screenscale * 402
		local barwidth = maxbarwidth * healthfrac
		colHealth.g = 130 * healthfrac
		colHealth.r = 130 - colHealth.g
		surface.SetDrawColor(colHealth)
		surface.DrawRect(barx, bary, barwidth, screenscale * 24)
		if poisondamage then
			surface.SetDrawColor(colPoison)
			local poisonbarwidth = maxbarwidth * (poisondamage / maxhealth)
			surface.DrawRect(barx + barwidth, bary, math.min(poisonbarwidth, maxbarwidth - barwidth), screenscale * 16)
		end
	end

	surface.SetTexture(bartexture)
	surface.SetDrawColor(150, 150, 150, 200)
	surface.DrawTexturedRect(x, y, wid, hei)

	draw.SimpleText(health, "ZSHUDFont", x + screenscale * 144, y + screenscale * 132, colHealth, TEXT_ALIGN_LEFT)
end

local colPackUp = Color(20, 255, 20, 220)
local colPackUpNotOwner = Color(255, 240, 10, 220)
function GM:DrawPackUpBar(x, y, fraction, notowner, screenscale)
	local col = notowner and colPackUpNotOwner or colPackUp

	local maxbarwidth = 360 * screenscale
	local barheight = 14 * screenscale
	local barwidth = maxbarwidth * math.Clamp(fraction, 0, 1)
	local startx = x - maxbarwidth * 0.5

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(startx, y, maxbarwidth, barheight)
	surface.SetDrawColor(col)
	surface.DrawRect(startx + 3, y + 3, barwidth - 6, barheight - 6)
	surface.DrawOutlinedRect(startx, y, maxbarwidth, barheight)

	surface.SetFont("ZSHUDFontSmall")
	local tw, th = surface.GetTextSize("W")
	draw.SimpleText(notowner and CurTime() % 2 < 1 and "Requires 4 people" or notowner and "Packing other's object" or "Packing", "ZSHUDFontSmall", x, y - th - 2, col, TEXT_ALIGN_CENTER)
end

local texHumanHealthBar = surface.GetTextureID("zombiesurvival/healthbar__human")
function GM:HumanHUD(screenscale)
	local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())

	self:DrawHealthBar(screenscale * 24, h - 272 * screenscale, MySelf:Health(), MySelf:GetMaxHealth(), texHumanHealthBar, screenscale, MySelf:GetPoisonDamage())

	local packup = MySelf.PackUp
	if packup and packup:IsValid() then
		self:DrawPackUpBar(w * 0.5, h * 0.55, 1 - packup:GetTimeRemaining() / packup:GetMaxTime(), packup:GetNotOwner(), screenscale)
	end

	if not self.RoundEnded then
		if self:GetWave() == 0 and not self:GetWaveActive() and self.WaveZeroLength >= timeleft then
			surface.SetFont("ZSHUDFontSmall")
			local txtw, txth = surface.GetTextSize("Hi")
			if timeleft < 10 then
				local glow = math.sin(RealTime() * 8) * 200 + 255
				draw.SimpleText("Waiting for players... "..util.ToMinutesSeconds(timeleft), "ZSHUDFontSmall", w * 0.5, h * 0.7, Color(255, glow, glow), TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("Waiting for players... "..util.ToMinutesSeconds(timeleft), "ZSHUDFontSmall", w * 0.5, h * 0.7, COLOR_WHITE, TEXT_ALIGN_CENTER)
			end

			local allplayers = player.GetAll()
			self:SortZombieSpawnDistances(allplayers)
			local desiredzombies = self:GetDesiredStartingZombies()

			draw.SimpleText("The humans closest to zombie spawns will start as zombies.", "ZSHUDFontSmall", w * 0.5, h * 0.7 + txth, COLOR_WHITE, TEXT_ALIGN_CENTER)
			
			draw.SimpleText("Number of initial zombies this game (".. self.WaveOneZombies * 100 .."%): "..desiredzombies, "ZSHUDFontSmall", w * 0.5, h * 0.7 + txth * 2, COLOR_WHITE, TEXT_ALIGN_CENTER)

			surface.SetFont("ZSHUDFontTiny")
			local y = h * 0.7 + txth * 3
			txtw, txth = surface.GetTextSize("Hi")
			for i, pl in ipairs(allplayers) do
				if h - txth <= y or i > desiredzombies then break else
					draw.SimpleText(pl:Name(), "ZSHUDFontTiny", w * 0.5, y, pl == MySelf and COLOR_RED or COLOR_WHITE, TEXT_ALIGN_CENTER)
					y = y + txth
				end
			end
		end

		local drown = MySelf.status_drown
		if drown and drown:IsValid() then
			surface.SetDrawColor(0, 0, 0, 60)
			surface.DrawRect(w * 0.4, h * 0.35, w * 0.2, 12)
			surface.SetDrawColor(30, 30, 230, 180)
			surface.DrawOutlinedRect(w * 0.4, h * 0.35, w * 0.2, 12)
			surface.DrawRect(w * 0.4, h * 0.35, w * 0.2 * (1 - drown:GetDrown()), 12)
			draw.SimpleText("Breath ", "ZSHUDFontSmall", w * 0.4, h * 0.35 + 6, COLOR_BLUE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	if gamemode.Call("PlayerCanPurchase", MySelf) then
		if self:GetWaveActive() then
			draw.SimpleText("Press F2 for the Points Shop!", "ZSHUDFontSmall", w * 0.5, 8, COLOR_GRAY, TEXT_ALIGN_CENTER)
		else
			surface.SetFont("ZSHUDFontSmall")
			local tw, th = surface.GetTextSize("W")
			draw.SimpleText("Press F2 for the Points Shop!", "ZSHUDFontSmall", w * 0.5, 8, COLOR_GRAY, TEXT_ALIGN_CENTER)
			draw.SimpleText(self.ArsenalCrateDiscountPercentage.."% discount for buying between waves!", "ZSHUDFontSmall", w * 0.5, 9 + th, COLOR_GRAY, TEXT_ALIGN_CENTER)
		end
	end
end

function GM:CreateItemTooltip(tab)
	local panel = vgui.Create("DPanel")
	panel:SetWide(128)

	local y = 16

	panel:SetTall(y + 16)

	return panel
end

function GM:HUDPaint()
end

function GM:_HUDPaint()
	if self.FilmMode then return end

	h = ScrH()
	w = ScrW()

	local screenscale = BetterScreenScale()

	local myteam = MySelf:Team()

	self:HUDDrawTargetID(myteam, screenscale)

	self:DrawDeathNotice(w - 16, 16, screenscale)

	if self:GetWave() > 0 then
		self:DrawFearMeter(self:CachedFearPower(), screenscale * 0.75)
	end

	if myteam == TEAM_UNDEAD then
		self:ZombieHUD(screenscale * 0.75)
	else
		self:HumanHUD(screenscale * 0.75)
	end

	if GetGlobalBool("classicmode") then
		draw.SimpleText("CLASSIC MODE", "ZSHUDFontSmaller", 4, ScrH() - 4, COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
end

function GM:ZombieObserverHUD(MySelf, screenscale, obsmode)
	surface.SetFont("ZSHUDFontSmall")
	local texw, texh = surface.GetTextSize("W")

	local dyn
	if obsmode == OBS_MODE_CHASE then
		local target = MySelf:GetObserverTarget()
		if target and target:IsValid() and target:IsPlayer() and target:Team() == TEAM_UNDEAD then
			draw.SimpleTextBlur(translate.Format("observing_x", target:Name(), math.max(0, target:Health())), "ZSHUDFontSmall", w * 0.5, h * 0.75 - texh - 32, COLOR_DARKRED, TEXT_ALIGN_CENTER)
			dyn = not GetGlobalBool("DynamicSpawningDisabled", false) and self:DynamicSpawnIsValid(target)
		end
	end

	if self:GetWaveActive() then
		draw.SimpleTextBlur(dyn and translate.Get("press_lmb_to_spawn_on_them") or translate.Get("press_lmb_to_spawn"), "ZSHUDFontSmall", w * 0.5, h * 0.75, dyn and COLOR_DARKGREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER)
	end
	draw.SimpleTextBlur(translate.Get("press_rmb_to_cycle_targets"), "ZSHUDFontSmall", w * 0.5, h * 0.75 + texh + 8, COLOR_DARKRED, TEXT_ALIGN_CENTER)
end

local matHumanHeadID = surface.GetTextureID("zombiesurvival/humanhead")
local matZombieHeadID = surface.GetTextureID("zombiesurvival/zombiehead")
local colLifeStats = Color(255, 0, 0, 255)
function GM:ZombieHUD(screenscale)
	local classtab = self.ZombieClasses[MySelf:GetZombieClass()]
	self:DrawHealthBar(screenscale * 24, h - 272 * screenscale, MySelf:Health(), classtab.Health, classtab.HealthBar or texHumanHealthBar, screenscale)

	if self.LifeStatsEndTime and CurTime() < self.LifeStatsEndTime then
		colLifeStats.a = math.Clamp((self.LifeStatsEndTime - CurTime()) / (self.LifeStatsLifeTime * 0.33), 0, 1) * 255

		local x = w * 0.75
		local y = h * 0.75
		draw.SimpleTextBlur(translate.Get("that_life"), "ZSHUDFontSmall", x, y, colLifeStats, TEXT_ALIGN_LEFT)
		surface.SetFont("ZSHUDFontSmall")
		local tw, th = surface.GetTextSize("W")
		y = y + th
		if self.LifeStatsBarricadeDamage > 0 then
			draw.SimpleTextBlur(translate.Format("x_damage_to_barricades", self.LifeStatsBarricadeDamage), "ZSHUDFontSmall", x, y, colLifeStats, TEXT_ALIGN_LEFT)
			y = y + th
		end
		if self.LifeStatsHumanDamage > 0 then
			draw.SimpleTextBlur(translate.Format("x_damage_to_humans", self.LifeStatsHumanDamage), "ZSHUDFontSmall", x, y, colLifeStats, TEXT_ALIGN_LEFT)
			y = y + th
		end
		if self.LifeStatsBrainsEaten > 0 then
			draw.SimpleTextBlur(translate.Format("x_brains_eaten", self.LifeStatsBrainsEaten), "ZSHUDFontSmall", x, y, colLifeStats, TEXT_ALIGN_LEFT)
			y = y + th
		end
	end

	local obsmode = MySelf:GetObserverMode()
	if obsmode ~= OBS_MODE_NONE then
		self:ZombieObserverHUD(MySelf, screenscale, obsmode)
	elseif not self:GetWaveActive() and not MySelf:Alive() then
		draw.SimpleTextBlur(translate.Get("waiting_for_next_wave"), "ZSHUDFont", w * 0.5, h * 0.3, COLOR_DARKRED, TEXT_ALIGN_CENTER)
	end
end

function GM:RequestedDefaultCart()
	local defaultcart = GetConVarString("zs_defaultcart")
	if #defaultcart > 0 then
		defaultcart = string.lower(defaultcart)

		for i, carttab in ipairs(self.SavedCarts) do
			if carttab[1] and string.lower(carttab[1]) == defaultcart then
				gamemode.Call("SuppressArsenalUpgrades", 1)
				RunConsoleCommand("worthcheckout", unpack(carttab[2]))

				return
			end
		end

		RunConsoleCommand("worthrandom")
	end
end

-- The whole point of this is so we don't need to check if the local player is valid 1000 times a second.
function GM:HookGetLocal()
	MYSELFVALID = true

	self.Think = self._Think
	self.HUDShouldDraw = self._HUDShouldDraw
	self.RenderScreenspaceEffects = self._RenderScreenspaceEffects
	self.CachedFearPower = self._CachedFearPower
	self.CalcView = self._CalcView
	self.ShouldDrawLocalPlayer = self._ShouldDrawLocalPlayer
	self.PostDrawOpaqueRenderables = self._PostDrawOpaqueRenderables
	self.PostDrawTranslucentRenderables = self._PostDrawTranslucentRenderables
	self.HUDPaint = self._HUDPaint
	self.HUDPaintBackground = self._HUDPaintBackground
	self.CreateMove = self._CreateMove
	self.PrePlayerDraw = self._PrePlayerDraw
	self.PostPlayerDraw = self._PostPlayerDraw
	self.InputMouseApply = self._InputMouseApply
	self.GUIMousePressed = self._GUIMousePressed
	self.HUDWeaponPickedUp = self._HUDWeaponPickedUp
end

function GM:_PostDrawTranslucentRenderables()
	self:DrawPointWorldHints()
	self:DrawWorldHints()
end

function GM:RestartRound()
	self.TheLastHuman = nil
	self.RoundEnded = nil
	LASTHUMAN = nil

	if pEndBoard and pEndBoard:Valid() then
		pEndBoard:Remove()
		pEndBoard = nil
	end

	self:HookGetLocal()

	self:RevertZombieClasses()
end

function GM:_HUDShouldDraw(name)
	if self.FilmMode and name ~= "CHudWeaponSelection" then return false end

	local wep = MySelf:GetActiveWeapon()
	if wep.HUDShouldDraw then
		local ret = wep:HUDShouldDraw(name)
		if ret ~= nil then return ret end
	end

	return name ~= "CHudHealth" and name ~= "CHudBattery"
	and name ~= "CHudAmmo" and name ~= "CHudSecondaryAmmo"
	and name ~= "CHudDamageIndicator"
end

local Current = 0
local NextCalculate = 0
function GM:_CachedFearPower()
	if CurTime() >= NextCalculate then
		NextCalculate = CurTime() + self.FearMeterRefreshRate
		Current = self:GetFearMeterPower(EyePos(), TEAM_UNDEAD, MySelf)
	end

	return Current
end

function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end

function GM:CreateFonts()
	local fontfamily = "Typenoksidi"
	local fontweight = 0
	local fontweight3D = 1000
	local fontaa = true
	local fontshadow = false
	local fontoutline = true

	surface.CreateLegacyFont("coolvetica", 32, 0, false, false, "ArsenalCrate", false, true)
	surface.CreateLegacyFont("coolvetica", 24, 0, false, false, "ArsenalCrate2", false, true)
	surface.CreateLegacyFont("csd", 42, 500, true, false, "healthsign", false, true)
	surface.CreateLegacyFont("tahoma", 48, 1000, true, false, "zshintfont", false, true)
	surface.CreateLegacyFont(fontfamily, 16, fontweight3D, true, false, "ZS3D2DFontTiny", false, true)
	surface.CreateLegacyFont(fontfamily, 22, fontweight3D, true, false, "ZS3D2DFontSmaller", false, true)
	surface.CreateLegacyFont(fontfamily, 28, fontweight3D, true, false,  "ZS3D2DFontSmall", false, true)
	surface.CreateLegacyFont(fontfamily, 42, fontweight3D, true, false, "ZS3D2DFont", false, true)
	surface.CreateLegacyFont(fontfamily, 72, fontweight3D, true, false, "ZS3D2DFontBig", false, true)
	surface.CreateLegacyFont("monospace", 20, 0, false, false, "ZS3DNailHealth", false, true)

	local screenscale = BetterScreenScale()

	surface.CreateLegacyFont("csd", screenscale * 36, 100, true, false, "zsdeathnoticecs", false, true)
	surface.CreateLegacyFont("HL2MP", screenscale * 36, 100, true, false, "zsdeathnotice", false, true)

	surface.CreateLegacyFont(fontfamily, screenscale * 16, fontweight, fontaa, false, "ZSHUDFontTiny", fontshadow, fontoutline)
	surface.CreateLegacyFont(fontfamily, screenscale * 20, fontweight, fontaa, false, "ZSHUDFontSmallest", fontshadow, fontoutline)
	surface.CreateLegacyFont(fontfamily, screenscale * 22, fontweight, fontaa, false, "ZSHUDFontSmaller", fontshadow, fontoutline)
	surface.CreateLegacyFont(fontfamily, screenscale * 28, fontweight, fontaa, false, "ZSHUDFontSmall", fontshadow, fontoutline)
	surface.CreateLegacyFont(fontfamily, screenscale * 42, fontweight, fontaa, false, "ZSHUDFont", fontshadow, fontoutline)
	surface.CreateLegacyFont(fontfamily, screenscale * 72, fontweight, fontaa, false, "ZSHUDFontBig", fontshadow, fontoutline)

	surface.CreateLegacyFont(fontfamily, screenscale * 16, 0, fontaa, false, "ZSAmmoName", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 16, fontweight, fontaa, false, "ZSHUDFontTinyNS", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 20, fontweight, fontaa, false, "ZSHUDFontSmallestNS", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 22, fontweight, fontaa, false, "ZSHUDFontSmallerNS", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 28, fontweight, fontaa, false, "ZSHUDFontSmallNS", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 42, fontweight, fontaa, false, "ZSHUDFontNS", false, false)
	surface.CreateLegacyFont(fontfamily, screenscale * 72, fontweight, fontaa, false, "ZSHUDFontBigNS", false, false)

	surface.CreateLegacyFont(fontfamily, screenscale * 16, 0, true, false, "ZSDamageResistance", false, true)

	surface.CreateLegacyFont(fontfamily, 32, fontweight, true, false, "ZSScoreBoardTitle", false, true)
	surface.CreateLegacyFont(fontfamily, 22, fontweight, true, false, "ZSScoreBoardSubTitle", false, true)
	surface.CreateLegacyFont(fontfamily, 16, fontweight, true, false, "ZSScoreBoardPlayer", false, true)
	surface.CreateLegacyFont(fontfamily, 24, fontweight, true, false, "ZSScoreBoardHeading", false, false)
	surface.CreateLegacyFont("arial", 20, 0, true, false, "ZSScoreBoardPlayerSmall", false, true)

	-- Default, DefaultBold, DefaultSmall, etc. were changed when gmod13 hit. These are renamed fonts that have the old values.
	surface.CreateFont("DefaultFontVerySmall", {font = "tahoma", size = 10, weight = 0, antialias = false})
	surface.CreateFont("DefaultFontSmall", {font = "tahoma", size = 11, weight = 0, antialias = false})
	surface.CreateFont("DefaultFontSmallDropShadow", {font = "tahoma", size = 11, weight = 0, shadow = true, antialias = false})
	surface.CreateFont("DefaultFont", {font = "tahoma", size = 13, weight = 500, antialias = false})
	surface.CreateFont("DefaultFontBold", {font = "tahoma", size = 13, weight = 1000, antialias = false})
	surface.CreateFont("DefaultFontLarge", {font = "tahoma", size = 16, weight = 0, antialias = false})
end

local FontBlurX = 0
local FontBlurX2 = 0
local FontBlurY = 0
local FontBlurY2 = 0

timer.Create("ShuffleNameBlur", 0.1, 0, function()
	FontBlurX = math.random(-8, 8)
	FontBlurX2 = math.random(-8, 8)
	FontBlurY = math.random(-8, 8)
	FontBlurY2 = math.random(-8, 8)
end)

local color_blur1 = Color(60, 60, 60, 220)
local color_blur2 = Color(40, 40, 40, 140)
function draw.SimpleTextBlur(text, font, x, y, col, xalign, yalign)
	color_blur1.a = col.a * 0.85
	color_blur2.a = col.a * 0.55
	draw.SimpleText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign, yalign)
	draw.SimpleText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign, yalign)
	draw.SimpleText(text, font, x, y, col, xalign, yalign)
end

function draw.DrawTextBlur(text, font, x, y, col, xalign)
	color_blur1.a = col.a * 0.85
	color_blur2.a = col.a * 0.55
	draw.DrawText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign)
	draw.DrawText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign)
	draw.DrawText(text, font, x, y, col, xalign)
end

function GM:CreateVGUI()
	local screenscale = BetterScreenScale()
	self.GameStatePanel = vgui.Create("DGameState")
	self.GameStatePanel:SetTextFont("ZSHUDFontSmaller")
	self.GameStatePanel:SetAlpha(220)
	self.GameStatePanel:SetSize(screenscale * 420, screenscale * 98)
end

function GM:Initialize()
	self:CreateFonts()
	self:PrecacheResources()
	self:CreateVGUI()
	self:InitializeBeats()
end

GM.Beats = {}
function GM:InitializeBeats()
	local _, dirs = file.Find("sound/zombiesurvival/beats/*", "GAME")
	for _, dirname in pairs(dirs) do
		if dirname == "none" or dirname == "default" then continue end

		self.Beats[dirname] = {}
		local highestexist
		for i=1, 10 do
			local filename = "zombiesurvival/beats/"..dirname.."/"..i..".wav"
			if file.Exists("sound/"..filename, "GAME") then
				self.Beats[dirname][i] = Sound(filename)
				highestexist = i
			elseif highestexist then
				self.Beats[dirname][i] = "zombiesurvival/beats/"..dirname.."/"..highestexist..".wav"
			end
		end
	end
end

function GM:PlayerDeath(pl, attacker)
end

function GM:OnPlayerHitGround(pl, inwater, hitfloater, speed)
	if inwater then return true end

	if pl:Team() == TEAM_UNDEAD then
		if pl:GetZombieClassTable().NoFallDamage then return true end

		speed = math.max(0, speed - 200)
	end

	if pl:Team() ~= TEAM_UNDEAD or not pl:GetZombieClassTable().NoFallSlowdown then
		pl:RawCapLegDamage(CurTime() + math.min(2, speed * 0.0035))
	end

	return true
end

function GM:LastHuman(pl)
	self.TheLastHuman = pl

	if not LASTHUMAN then
		LASTHUMAN = true
		timer.SimpleEx(0.5, self.LastHumanMessage, self)
	end
end

function GM:LastHumanMessage()
	if self.RoundEnded then return end

	local MySelf = LocalPlayer()
	if MySelf:Team() == TEAM_UNDEAD or not MySelf:Alive() then
		self:SplitMessage("<color=red>"..(self.PantsMode and "KICK" or "KILL").." THE LAST HUMAN!")
	else
		self:SplitMessage("<color=red>YOU ARE THE LAST HUMAN!", "<color=red>"..team.NumPlayers(TEAM_UNDEAD).." "..(self.PantsMode and "PANTS" or "ZOMBIES").." ARE OUT TO GET YOU!")
	end
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	return pl == attacker or not attacker:IsPlayer() or pl:Team() ~= attacker:Team() or pl.AllowTeamDamage or attacker.AllowTeamDamage
end

function GM:SetWave(wave)
	SetGlobalInt("wave", wave)
end

local texFilmGrain = surface.GetTextureID("zombiesurvival/filmgrain/filmgrain")
function GM:_HUDPaintBackground()
	if self.FilmGrainEnabled and MySelf:Team() == TEAM_HUMAN then
		surface.SetTexture(texFilmGrain)
		surface.SetDrawColor(0, 0, 0, (0.25 + 0.75 * self:CachedFearPower()) * self.FilmGrainOpacity)
		surface.DrawTexturedRectUV(0, 0, w, h, 2, 2, 0, 0)
	end

	local wep = MySelf:GetActiveWeapon()
	if wep:IsValid() and wep.DrawHUDBackground then
		wep:DrawHUDBackground()
	end
end

local function GiveWeapon()
	RunConsoleCommand("zsgiveweapon")
end
local function GiveWeaponClip()
	RunConsoleCommand("zsgiveweaponclip")
end
local function DropWeapon()
	RunConsoleCommand("zsdropweapon")
end
local function EmptyClip()
	RunConsoleCommand("zsemptyclip")
end
function GM:HumanMenu()
	local ent = MySelf:MeleeTrace(48, 2).Entity
	if self:ValidMenuLockOnTarget(MySelf, ent) then
		self.HumanMenuLockOn = ent
	else
		self.HumanMenuLockOn = nil
	end

	if self.HumanMenuPanel and self.HumanMenuPanel:Valid() then
		self.HumanMenuPanel:SetVisible(true)
		self.HumanMenuPanel:OpenMenu()
		return
	end

	local panel = vgui.Create("DSideMenu")
	self.HumanMenuPanel = panel

	local screenscale = BetterScreenScale()
	for k, v in pairs(self.AmmoNames) do
		local b = vgui.Create("DAmmoCounter", panel)
		b:SetAmmoType(k)
		b:SetTall(screenscale * 36)
		panel:AddItem(b)
	end

	local b = EasyButton(panel, "Give Weapon", 8, 4)
	b.DoClick = GiveWeapon
	panel:AddItem(b)
	b = EasyButton(panel, "Give Weapon and 5 clips", 8, 4)
	b.DoClick = GiveWeaponClip
	panel:AddItem(b)
	b = EasyButton(panel, "Drop weapon", 8, 4)
	b.DoClick = DropWeapon
	panel:AddItem(b)
	b = EasyButton(panel, "Empty clip", 8, 4)
	b.DoClick = EmptyClip
	panel:AddItem(b)

	panel:OpenMenu()
end

GM.ZombieThirdPerson = false
function GM:PlayerBindPress(pl, bind, wasin)
	if bind == "gmod_undo" then
		RunConsoleCommand("+zoom")
		timer.CreateEx("ReleaseZoom", 1, 1, RunConsoleCommand, "-zoom")
	elseif bind == "+menu_context" then
		self.ZombieThirdPerson = not self.ZombieThirdPerson
	end
end

function GM:_ShouldDrawLocalPlayer(pl)
	return pl:Team() == TEAM_UNDEAD and (self.ZombieThirdPerson or pl:CallZombieFunction("ShouldDrawLocalPlayer")) or pl:IsPlayingTaunt()
end

local roll = 0
function GM:_CalcView(pl, origin, angles, fov, znear, zfar)
	if pl.Confusion and pl.Confusion:IsValid() then
		pl.Confusion:CalcView(pl, origin, angles, fov, znear, zfar)
	end

	if pl.Revive and pl.Revive:IsValid() and pl.Revive.GetRagdollEyes then
		local rpos, rang = pl.Revive:GetRagdollEyes(pl)
		if rpos then
			origin = rpos
			angles = rang
		end
	elseif pl.KnockedDown and pl.KnockedDown:IsValid() then
		local rpos, rang = self:GetRagdollEyes(pl)
		if rpos then
			origin = rpos
			angles = rang
		end
	elseif pl:ShouldDrawLocalPlayer() and pl:OldAlive() then
		origin = pl:GetThirdPersonCameraPos(origin, angles)
	end

	local targetroll = 0
	if self.MovementViewRoll then
		local vel = pl:GetVelocity()
		targetroll = targetroll + vel:GetNormalized():Dot(angles:Right()) * math.min(30, vel:Length() / 100)
	end

	if pl:WaterLevel() >= 3 then
		targetroll = targetroll + math.sin(CurTime()) * 7
	end

	roll = math.Approach(roll, targetroll, math.max(0.25, math.sqrt(math.abs(roll))) * 30 * FrameTime())
	angles.roll = angles.roll + roll

	if pl:IsPlayingTaunt() then
		self:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
	end

	return self.BaseClass.CalcView(self, pl, origin, angles, fov, znear, zfar)
end

function GM:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
	local tr = util.TraceHull({start = origin, endpos = origin - angles:Forward() * 72, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), mask = MASK_OPAQUE, filter = pl})
	origin:Set(tr.HitPos + tr.HitNormal * 2)
end

local staggerdir = VectorRand():GetNormalized()
function GM:_CreateMove(cmd)
	if MySelf:IsPlayingTaunt() then
		self:CreateMoveTaunt(cmd)
		return
	end

	if MySelf:Team() == TEAM_HUMAN then
		if MySelf:Alive() then
			local maxhealth = MySelf:GetMaxHealth()
			local threshold = MySelf:GetPalsy() and maxhealth - 1 or maxhealth * 0.25

			local lockon = self.HumanMenuLockOn
			if lockon then
				if self:ValidMenuLockOnTarget(MySelf, lockon) and self.HumanMenuPanel and self.HumanMenuPanel:Valid() and self.HumanMenuPanel:IsVisible() and MySelf:KeyDown(self.MenuKey) then
					local oldang = cmd:GetViewAngles()
					local newang = (lockon:EyePos() - EyePos()):Angle()
					oldang.pitch = math.ApproachAngle(oldang.pitch, newang.pitch, FrameTime() * math.max(45, math.abs(math.AngleDifference(oldang.pitch, newang.pitch)) ^ 1.3))
					oldang.yaw = math.ApproachAngle(oldang.yaw, newang.yaw, FrameTime() * math.max(45, math.abs(math.AngleDifference(oldang.yaw, newang.yaw)) ^ 1.3))
					cmd:SetViewAngles(oldang)
				else
					self.HumanMenuLockOn = nil
				end
			else
				local health = MySelf:Health()
				if health <= threshold then
					local ft = FrameTime()

					staggerdir = (staggerdir + ft * 8 * VectorRand()):GetNormalized()

					local ang = cmd:GetViewAngles()
					local rate = ft * ((threshold - health) / threshold) * 7
					ang.pitch = math.NormalizeAngle(ang.pitch + staggerdir.z * rate)
					ang.yaw = math.NormalizeAngle(ang.yaw + staggerdir.x * rate)
					cmd:SetViewAngles(ang)
				end
			end
		end
	elseif MySelf.FeignDeath and MySelf.FeignDeath:IsValid() then
		local ang = cmd:GetViewAngles()
		ang.yaw = MySelf.FeignDeath.CommandYaw or ang.yaw
		cmd:SetViewAngles(ang)
	else
		MySelf:CallZombieFunction("CreateMove", cmd)
	end
end

function GM:CreateMoveTaunt(cmd)
	cmd:ClearButtons(0)
	cmd:ClearMovement()
end

function GM:PostProcessPermitted(str)
	return false
end

function GM:HUDPaintEndRound()
end

function GM:PreDrawViewModel(vm, pl, wep)
	if wep and wep.PreDrawViewModel then
		wep:PreDrawViewModel(vm)
	end
end

function GM:PostDrawViewModel(vm, pl, wep)
--	if wep and wep.PostDrawViewModel then
--		wep:PostDrawViewModel(vm)
--	end
	
		if ( wep.UseHands || !wep:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end
	
end

local undomodelblend = false
local undozombievision = false
local matWhite = Material("models/debug/debugwhite")
function GM:_PrePlayerDraw(pl)
	if pl:CallZombieFunction("PrePlayerDraw") then return true end

	if pl.status_overridemodel and pl.status_overridemodel:IsValid() and self:ShouldDrawLocalPlayer(MySelf) then -- We need to do this otherwise the player's real model shows up for some reason.
		undomodelblend = true
		render.SetBlend(0) --render.SetBlend(0.01)
	elseif MySelf:Team() == TEAM_HUMAN and pl ~= MySelf and pl:Team() == TEAM_HUMAN then
		local radius = self.TransparencyRadius
		if radius > 0 then
			local eyepos = EyePos()
			local dist = pl:NearestPoint(eyepos):Distance(eyepos)
			if dist < radius then
				local blend = math.max((dist / radius) ^ 1.4, 0.04)
				render.SetBlend(blend)
				if blend < 0.4 then
					render.ModelMaterialOverride(matWhite)
					render.SetColorModulation(0.2, 0.2, 0.2)
				end
				undomodelblend = true
			end
		end
	end

	if self.m_ZombieVision and MySelf:Team() == TEAM_UNDEAD and pl:Team() == TEAM_HUMAN and pl:GetPos():Distance(EyePos()) <= pl:GetAuraRange() then
		undozombievision = true

		local green = math.Clamp(pl:Health() / pl:GetMaxHealth(), 0, 1)
		render.ModelMaterialOverride(matWhite)
		render.SetColorModulation(1 - green, green, 0)
		render.SuppressEngineLighting(true)
		cam.IgnoreZ(true)
	end
end

function GM:_PostPlayerDraw(pl)
	pl:CallZombieFunction("PostPlayerDraw")

	if undomodelblend then
		render.SetBlend(1)
		render.ModelMaterialOverride()
		render.SetColorModulation(1, 1, 1)

		undomodelblend = false
	end
	if undozombievision then
		render.ModelMaterialOverride()
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
		cam.IgnoreZ(false)

		undozombievision = false
	end
end

function GM:DrawCraftingEntity()
	local craftingentity = self.CraftingEntity
	if craftingentity and craftingentity:IsValid() then
		if self.HumanMenuPanel and self.HumanMenuPanel:Valid() and self.HumanMenuPanel:IsVisible() and MySelf:KeyDown(self.MenuKey) then
			render.ModelMaterialOverride(matWhite)
			render.SuppressEngineLighting(true)
			render.SetBlend(0.025)
			local scale = craftingentity:GetModelScale()
			local extrascale = 1.05 + math.abs(math.sin(RealTime() * 7)) * 0.1
			craftingentity:SetModelScale(scale * extrascale, 0)

			local oldpos = craftingentity:GetPos()
			craftingentity:SetPos(oldpos - craftingentity:LocalToWorld(oldpos))
			craftingentity:DrawModel()
			craftingentity:SetPos(oldpos)

			craftingentity:SetModelScale(scale, 0)
			render.SetBlend(1)
			render.SuppressEngineLighting(false)
			render.ModelMaterialOverride(0)
		else
			self.CraftingEntity = nil
		end
	end
end

function GM:HUDPaintBackgroundEndRound()
	local timleft = math.max(0, self.EndTime + self.EndGameTime - CurTime())
	if timleft <= 0 then
		draw.SimpleTextBlur("Loading...", "ZSHUDFont", w * 0.5, h * 0.8, COLOR_WHITE, TEXT_ALIGN_CENTER)
	else
		if(NEXTMAP != nil and NEXTMAP != "") then
			draw.SimpleTextBlur("Loading map \""..NEXTMAP.."\" in: "..util.ToMinutesSeconds(timleft), "ZSHUDFontSmall", w * 0.5, h * 0.8, COLOR_WHITE, TEXT_ALIGN_CENTER)
		else
			draw.SimpleTextBlur("Next round in: "..util.ToMinutesSeconds(timleft), "ZSHUDFontSmall", w * 0.5, h * 0.8, COLOR_WHITE, TEXT_ALIGN_CENTER)
		end
	end

	self:DrawDeathNotice(w - 16, 16, BetterScreenScale())
end

local function EndRoundCalcView(pl, origin, angles, fov, znear, zfar)
	if GAMEMODE.EndTime and CurTime() < GAMEMODE.EndTime + 5 then
		if GAMEMODE.LastHumanPosition then
			local delta = math.Clamp((CurTime() - GAMEMODE.EndTime) * 2, 0, 1)
 
			local start = GAMEMODE.LastHumanPosition * delta + origin * (1 - delta)
			local tr = util.TraceHull({start = start, endpos = delta * 64 * Angle(0, CurTime() * 30, 0):Forward(), mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), filter = player.GetAll(), mask = MASK_SOLID})
			return {origin = tr.HitPos + tr.HitNormal, angles = (start - tr.HitPos):Angle()}
		end

		return
	end

	hook.Remove("CalcView", "EndRoundCalcView")
end

local function EndRoundShouldDrawLocalPlayer(pl)
	if GAMEMODE.EndTime and CurTime() < GAMEMODE.EndTime + 5 then
		return true
	end

	hook.Remove("ShouldDrawLocalPlayer", "EndRoundShouldDrawLocalPlayer")
end

local function EndRoundGetMeleeFilter(self) return {self} end
function GM:EndRound(winner, nextmap)
	if self.RoundEnded then return end
	self.RoundEnded = true

	ROUNDWINNER = winner
	NEXTMAP = nextmap
	
	self.EndTime = CurTime()

	RunConsoleCommand("stopsound")

	FindMetaTable("Player").GetMeleeFilter = EndRoundGetMeleeFilter

	self.HUDPaint = self.HUDPaintEndRound
	self.HUDPaintBackground = self.HUDPaintBackgroundEndRound

	if winner == TEAM_UNDEAD then
		hook.Add("CalcView", "EndRoundCalcView", EndRoundCalcView)
		hook.Add("ShouldDrawLocalPlayer", "EndRoundShouldDrawLocalPlayer", EndRoundShouldDrawLocalPlayer)
	end

	if winner == TEAM_UNDEAD then
		timer.SimpleEx(0.5, surface.PlaySound, ALLLOSESOUND)
	else
		timer.SimpleEx(0.5, surface.PlaySound, HUMANWINSOUND)
	end

	--timer.SimpleEx(5, MakepEndBoard, winner)
end

function GM:WeaponDeployed(pl, wep)
end

function GM:LocalPlayerDied(attackername)
	LASTDEATH = RealTime()

	surface.PlaySound(DEATHSOUND)
	if attackername then
		self:SplitMessage("<color=red><font=ZSHUDFontBig>You have died.", "<color=red>You were "..(self.PantsMode and "kicked in the shins" or "killed").." by "..tostring(attackername)..".")
	else
		self:SplitMessage("<color=red><font=ZSHUDFontBig>You have died.")
	end
end

function GM:KeyPress(pl, key)
	if key == self.MenuKey then
		if pl:Team() == TEAM_HUMAN and pl:Alive() and not pl:IsHolding() then
			gamemode.Call("HumanMenu")
		end
	elseif key == IN_SPEED then
		if pl:Alive() then
			if pl:Team() == TEAM_HUMAN then
				pl:DispatchAltUse()
			elseif pl:Team() == TEAM_UNDEAD then
				pl:CallZombieFunction("AltUse")
			end
		end
	end
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	local time = pl:CallZombieFunction("PlayerStepSoundTime", iType, bWalking)
	if time then
		return time
	end

	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 520 - pl:GetVelocity():Length()
	end

	if iType == STEPSOUNDTIME_ON_LADDER then
		return 500
	end

	if iType == STEPSOUNDTIME_WATER_KNEE then
		return 650
	end

	return 350
end

function GM:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume)
	return pl:CallZombieFunction("PlayerFootstep", vFootPos, iFoot, strSoundName, fVolume)
end

function GM:PlayerCanCheckout(pl)
	return pl:IsValid() and pl:Team() == TEAM_HUMAN and pl:Alive() and self:GetWave() <= 0
end

function GM:OpenWorth()
	if gamemode.Call("PlayerCanCheckout", MySelf) then
		MakepWorth()
	end
end

function GM:CloseWorth()
	if pWorth and pWorth:Valid() then
		pWorth:Remove()
		pWorth = nil
	end
end

GM.SuppressArsenalTime = 0
function GM:SuppressArsenalUpgrades(suppresstime)
	self.SuppressArsenalTime = math.max(CurTime() + suppresstime, self.SuppressArsenalTime)
end

function GM:Rewarded(class, amount)
	if CurTime() < self.SuppressArsenalTime then return end

	class = class or "0"

	local wep = weapons.GetStored(class)
	if wep and wep.PrintName then
		self:SplitMessage("<font=ZSHUDFontSmall>Arsenal Upgraded", "<font=ZSHUDFontSmall>"..wep.PrintName)
	elseif amount then
		if amount==-1 then
			self:SplitMessage("<font=ZSHUDFontSmall>Powerup Activated", "<font=ZSHUDFontSmall>"..class.."")
		else
			self:SplitMessage("<font=ZSHUDFontSmall>Arsenal Upgraded", "<font=ZSHUDFontSmall>"..amount.." "..class.."")
		end
	else
		self:SplitMessage("<font=ZSHUDFontSmall>Arsenal Upgraded", "<font=zsdeathnotice>0")
	end
end

function PlayMenuOpenSound()
	LocalPlayer():EmitSound("buttons/lightswitch2.wav", 100, 30)
end

function PlayMenuCloseSound()
	LocalPlayer():EmitSound("buttons/lightswitch2.wav", 100, 20)
end

usermessage.Hook("lifestats", function(um)
	local barricadedamage = um:ReadLong()
	local humandamage = um:ReadLong()
	local brainseaten = um:ReadShort()

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime
	GAMEMODE.LifeStatsBarricadeDamage = barricadedamage
	GAMEMODE.LifeStatsHumanDamage = humandamage
	GAMEMODE.LifeStatsBrainsEaten = brainseaten
end)

usermessage.Hook("honmention", function(um)
	local id = um:ReadShort()
	local mentionid = um:ReadShort()
	local etc = um:ReadLong()

	local pl = Entity(id)
	if pl and pl:IsValid() and pl:IsPlayer() then
		gamemode.Call("AddHonorableMention", pl, mentionid, etc)
	end
end)

usermessage.Hook("reclockedclasses", function(um)
	local str = um:ReadString()
	for classid, state in ipairs(string.Explode(",", str)) do
		local classtab = GAMEMODE.ZombieClasses[classid]
		if classtab then
			state = tonumber(state) or 0
			if state == 1 then
				classtab.Unlocked = true
				classtab.Locked = nil
			elseif state == 2 then
				classtab.Locked = true
				classtab.Unlocked = nil
			else
				classtab.Locked = nil
				classtab.Unlocked = nil
			end
		end
	end
end)

usermessage.Hook("recwavestart", function(um)
	local wave = um:ReadShort()

	gamemode.Call("SetWave", wave)
	gamemode.Call("SetWaveEnd", um:ReadFloat())

	  if wave == 10 and not LASTHUMAN then
		GAMEMODE:SplitMessage("THE FINAL WAVE HAS BEGUN! SURVIVE TWO MORE MINUTES!", "<font=ZSHUDFontSmall><color=white>ALL classes unlocked and the chance for redemption has ended!")
		surface.PlaySound("slamstand.mp3")
	  
	  elseif wave == 10 and LASTHUMAN then
		GAMEMODE:SplitMessage("HANG IN THERE SURVIVOR! ONLY TWO MORE MINUTES!", "<font=ZSHUDFontSmall><color=white>ALL classes unlocked and the chance for redemption has ended!")

	else
		local UnlockedClasses = {}
		for i, tab in ipairs(GAMEMODE.ZombieClasses) do
			if tab.Wave <= wave and not tab.Unlocked then
				tab.Unlocked = true
				UnlockedClasses[#UnlockedClasses + 1] = tab.Name
			end
		end

		GAMEMODE:SplitMessage("Wave "..wave.." has begun!", #UnlockedClasses > 0 and "<font=ZSHUDFontSmall><color=white>"..string.AndSeparate(UnlockedClasses).." unlocked!" or "")
	end

	surface.PlaySound("ambient/creatures/town_zombie_call1.wav")
end)

usermessage.Hook("recwaveend", function(um)
	local wave = um:ReadShort()
	gamemode.Call("SetWaveStart", um:ReadFloat())

	if wave < GAMEMODE:GetNumberOfWaves() and wave > 0 then
		GAMEMODE:SplitMessage("Wave "..wave.." is over!", "<color=white><font=ZSHUDFontSmall>The Undead have stopped rising and the Points Shop is "..GAMEMODE.ArsenalCrateDiscountPercentage.."% off.")

		surface.PlaySound("ambient/atmosphere/cave_hit"..math.random(6)..".wav")
	end
end)

usermessage.Hook("reczsgamestate", function(um)
	gamemode.Call("SetWave", um:ReadShort())
	gamemode.Call("SetWaveStart", um:ReadFloat())
	gamemode.Call("SetWaveEnd", um:ReadFloat())
end)

local texSkull = surface.GetTextureID("zombiesurvival/horderally")
local bossspawnedend
local function BossSpawnedPaint()
	if CurTime() > bossspawnedend then
		hook.Remove("HUDPaint", "BossSpawnedPaint")
		return
	end

	local delta = math.Clamp(bossspawnedend - CurTime(), 0, 1)
	local size = (1 - delta) * math.max(ScrW(), ScrH())

	surface.SetTexture(texSkull)
	surface.SetDrawColor(160, 0, 0, math.min(delta * 400, 180))
	surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, size, size, delta * 25)
end
usermessage.Hook("bosszombiespawned", function(um)
	local ent = um:ReadEntity()
	local classindex = um:ReadShort()

	if ent == MySelf then
		MySelf:SplitMessage("You are "..GAMEMODE.ZombieClasses[classindex].Name.."!!")
	elseif ent:IsValid() then
		MySelf:SplitMessage(ent:Name().." has risen as "..GAMEMODE.ZombieClasses[classindex].Name.."!")
	else
		MySelf:SplitMessage(GAMEMODE.ZombieClasses[classindex].Name.." has risen!")
	end

	MySelf:EmitSound("npc/zombie_poison/pz_alert1.wav", 0)

	bossspawnedend = CurTime() + 1
	hook.Add("HUDPaint", "BossSpawnedPaint", BossSpawnedPaint)
end)

hook.Add( "PreDrawHalos", "EntityHalos", function()
	local eyes = LocalPlayer():EyePos()
	local teamid = LocalPlayer():Team()
	if (teamid == TEAM_HUMAN and LocalPlayer():KeyDown(IN_SPEED)) or (teamid == TEAM_UNDEAD and GAMEMODE.m_ZombieVision) then
		local myteam = {}
		for _, pl in pairs( team.GetPlayers( teamid ) ) do
			if pl:Alive() and !TrueVisible( eyes, pl:EyePos() ) then
				table.insert( myteam, pl )
			end
		end
		halo.Add( myteam, team.GetColor(teamid), 2, 2, 1, true, true )
	end
	if teamid == TEAM_HUMAN then
		local weap = {}
		for _, ent in pairs( ents.FindByClass( "prop_weapon" )) do
			if TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
				table.insert( weap, ent )
			end
		end
		for _, ent in pairs( ents.FindByClass( "prop_ammo" )) do
			if TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
				table.insert( weap, ent )
			end
		end
		halo.Add( weap, Color( 255, 0, 0 ), 2, 2, 1, true, true )
		local health = {}
		for _, ent in pairs( ents.FindByClass( "item_health*" )) do
			if math.ceil(ent:GetCycle()*100) != 100 and TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
				table.insert( health, ent )
			end
		end
		halo.Add( health, Color( 0, 255, 0 ), 2, 2, 1, true, true )
	elseif teamid == TEAM_UNDEAD then
		local food = {}
		for _, ent in pairs( ents.FindByClass( "prop_playergib" )) do
			if TrueVisible( eyes, ent:NearestPoint( eyes ) ) then
				table.insert( food, ent )
			end
		end
		halo.Add( food, Color( 255, 0, 0 ), 2, 2, 1, true, true )
	end
end )