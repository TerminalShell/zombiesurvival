GM.Name	=	"Zombie Survival"
GM.Version	=	"1.0.0"
GM.Author	=	"Terminal Shell"
GM.Email	=	"terminalshellclan@gmail.com"
GM.Website	=	"http://mwr247.com/"

GM.Credits = {
	{"William \"JetBoom\" Moodhe", "williammoodhe@gmail.com (www.noxiousnet.com)", "Creating Zombie Survival"},
	{"Mwr247", "mwr247@gmail.com", "Modifying Zombie Survival"},
  {"Etrius", "tmr1228@gmail.com", "Modifying Zombie Survival"},
  {"CremeOfCrispy", "kriscambridge13@gmail.com", "Modifying Zombie Survival"},
	{"Bandit Kitteh", "bandit.kitteh@hotmail.com", "Modifying Zombie Survival"},
	{"Kalafina", "http://www.sonymusic.co.jp/Music/Info/kalafina/", "Last Human music"},
	{"comeonandslam", "http://www.youtube.com/user/comeonandslam", "Wave 10 music"},
	{"11k", "tjd113@gmail.com", "Zombie view models"},
	{"Eisiger", "k2deseve@gmail.com", "Zombie kill icons"},
	{"Austin \"Little Nemo\" Killey", "austin_odyssey@yahoo.com", "Default beat set sounds"},
	{"Samuel", "samuel_games@hotmail.com", "Board Kit model"},
	{"Typhon", "lukas-tinel@hotmail.com", "HUD textures"},
	{"Zombie Panic: Source", "http://www.zombiepanic.org/", "Melee weapon models"}
}

include("sh_translate.lua")
include("sh_colors.lua")
include("sh_serialization.lua")

include("sh_globals.lua")
include("sh_crafts.lua")
include("sh_util.lua")
include("sh_options.lua")
include("sh_zombieclasses.lua")
include("sh_animations.lua")

include("obj_entity_extend.lua")
include("obj_player_extend.lua")
include("obj_weapon_extend.lua")

include("cl_fix_emitters.lua")

GM.EndRound = false

team.SetUp(TEAM_ZOMBIE, "The Undead", Color(0, 255, 0, 255))
team.SetUp(TEAM_SURVIVORS, "Survivors", Color(0, 160, 255, 255))

local validmodels = player_manager.AllValidModels()
validmodels["tf01"] = nil
validmodels["tf02"] = nil

vector_tiny = Vector(0.001, 0.001, 0.001)

function GM:CanRemoveOthersNail(pl, nailowner, ent)
	return true
end

function GM:SetRedeemBrains(amount)
	SetGlobalInt("redeembrains", amount)
end

function GM:GetRedeemBrains()
	return GetGlobalInt("redeembrains", self.DefaultRedeem)
end

function GM:PlayerIsAdmin(pl)
	return pl:IsAdmin()
end

function GM:GetFallDamage(pl, fallspeed)
	return 0
end

function GM:ShouldRestartRound()
	if self.TimeLimit == -1 or self.RoundLimit == -1 then return true end

	if self.TimeLimit > 0 and CurTime() >= self.TimeLimit or self.RoundLimit > 0 and self.CurrentRound >= self.RoundLimit then return false end

	return true
end

function GM:ZombieSpawnDistanceSort(other)
	return self._ZombieSpawnDistance < other._ZombieSpawnDistance
end

function GM:SortZombieSpawnDistances(allplayers)
	local zspawns = ents.FindByClass("zombiegasses")
	for _, pl in pairs(allplayers) do
		if pl:Team() == TEAM_UNDEAD or pl:GetNetworkedBool("pvolunteer", false) then
			pl._ZombieSpawnDistance = -1
		else
			local plpos = pl:GetPos()
			local closest = 9999999
			for _, ent in pairs(zspawns) do
				local dist = ent:GetPos():Distance(plpos)
				if dist < closest then
					closest = dist
				end
			end
			if ( evolve and evolve.donors and evolve:IsDonor( pl ) ) then
				closest = closest * 2
			end
			pl._ZombieSpawnDistance = closest
		end
	end

	table.sort(allplayers, self.ZombieSpawnDistanceSort)
end

function GM:SetDynamicSpawning(onoff)
	SetGlobalBool("DynamicSpawningDisabled", not onoff)
	self.DynamicSpawning = onoff
end

function GM:ValidMenuLockOnTarget(pl, ent)
	if ent and ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_HUMAN and ent:Alive() then
		local startpos = pl:EyePos()
		local endpos = ent:NearestPoint(startpos)
		if startpos:Distance(endpos) <= 48 and TrueVisible(startpos, endpos) then
			return true
		end
	end

	return false
end

local playerheight = Vector(0, 0, 72)
local playermins = Vector(-17, -17, 0)
local playermaxs = Vector(17, 17, 4)

local function SkewedDistance(a, b, skew)
	if a.z > b.z then
		return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + ((a.z - b.z) * skew) ^ 2)
	end

	return a:Distance(b)
end

function GM:DynamicSpawnIsValid(zombie, humans, allplayers)
	-- Optional caching for these.
	if not humans then humans = team.GetPlayers(TEAM_HUMAN) end
	if not allplayers then allplayers = player.GetAll() end

	local pos = zombie:GetPos() + Vector(0, 0, 1)
	if zombie:Alive() and zombie:GetMoveType() == MOVETYPE_WALK and zombie:OnGround()
	and not util.TraceHull({start = pos, endpos = pos + playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID, filter = allplayers}).Hit then
		local vtr = util.TraceHull({start = pos, endpos = pos - playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID_BRUSHONLY})
		if not vtr.HitSky and not vtr.HitNoDraw then
			local valid = true

			for _, human in pairs(humans) do
				local hpos = human:GetPos()
				local nearest = zombie:NearestPoint(hpos)
				local dist = SkewedDistance(hpos, nearest, 2.75) -- We make it so that the Z distance between a human and a zombie is skewed if the zombie is below the human.
				if dist <= 640 or dist <= 2048 and WorldVisible(hpos, nearest) then -- Zombies can't be in radius of any humans. Zombies can't be clearly visible by any humans.
					valid = false
					break
				end
			end

			return valid
		end
	end

	return false
end

function GM:GetBestDynamicSpawn(pl)
	local spawns = self:GetDynamicSpawns(pl)
	if #spawns == 0 then return end

	return self:GetClosestSpawnPoint(spawns, self:GetTeamEpicentre(TEAM_HUMAN)) or table.Random(spawns)
end

function GM:GetDynamicSpawns(pl)
	local tab = {}

	local allplayers = player.GetAll()
	local humans = team.GetPlayers(TEAM_HUMAN)
	for _, zombie in pairs(team.GetPlayers(TEAM_UNDEAD)) do
		local pos = zombie:GetPos() + Vector(0, 0, 1)
		if zombie ~= pl and self:DynamicSpawnIsValid(zombie, humans, allplayers) then
			table.insert(tab, zombie)
		end
	end

	return tab
end

function GM:GetDesiredStartingZombies()
	local numplayers = #player.GetAll()
	return math.min(math.max(1, math.ceil(numplayers * self.WaveOneZombies)), numplayers - 1)
end

function GM:GetEndRound()
	return self.EndRound
end

function GM:PrecacheResources()
	util.PrecacheSound("physics/body/body_medium_break2.wav")
	util.PrecacheSound("physics/body/body_medium_break3.wav")
	util.PrecacheSound("physics/body/body_medium_break4.wav")
	for name, mdl in pairs(player_manager.AllValidModels()) do
		util.PrecacheModel(mdl)
	end
end

function GM:ShouldCollide(enta, entb)
	if enta.ShouldNotCollide and enta:ShouldNotCollide(entb) or entb.ShouldNotCollide and entb:ShouldNotCollide(enta) then
		return false
	end

	return true
end

function GM:Move(pl, move)
	if pl:Team() == TEAM_HUMAN then
		if pl:GetBarricadeGhosting() then
			if pl:ActiveBarricadeGhosting() then
				move:SetMaxSpeed(25)
				move:SetMaxClientSpeed(25)
			else
				move:SetMaxSpeed(75)
				move:SetMaxClientSpeed(75)
			end
		elseif move:GetForwardSpeed() < 0 then
			move:SetMaxSpeed(move:GetMaxSpeed() * 0.45)
			move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.45)
		end
	elseif pl:CallZombieFunction("Move", move) then
		return
	end

	local legdamage = pl:GetLegDamage()
	if legdamage > 0 then
		local scale = 1 - math.min(1, legdamage * 0.33)
		move:SetMaxSpeed(move:GetMaxSpeed() * scale)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * scale)
	end
end

function GM:OnPlayerHitGround(pl, inwater, hitfloater, speed)
	if inwater then return true end

	if pl:Team() == TEAM_UNDEAD then
		if pl:GetZombieClassTable().NoFallDamage then return true end

		speed = math.max(0, speed - 200)
	else
		pl:PreventSkyCade()
	end

	if pl:Team() ~= TEAM_UNDEAD or not pl:GetZombieClassTable().NoFallSlowdown then
		pl:RawCapLegDamage(CurTime() + math.min(2, speed * 0))
	end

	if SERVER then
		local damage = (0.1 * (speed - 600)) ^ 1.5
		if hitfloater then damage = damage / 2 end

		if math.floor(damage) > 0 then
			if 20 <= damage and damage < pl:Health() then
				pl:KnockDown(damage * 0.05)
			end
			pl:TakeSpecialDamage(damage, DMG_FALL, game.GetWorld(), game.GetWorld(), pl:GetPos())
			pl:EmitSound("player/pl_fallpain"..(math.random(0, 1) == 1 and 3 or 1)..".wav")
		end
	end

	return true
end

function GM:PlayerCanBeHealed(pl)
	return not pl:GetHemophilia()
end

function GM:PlayerCanPurchase(pl)
	return pl:IsValid() and pl:Team() == TEAM_HUMAN and pl:Alive() and self:GetWave() > 0 and pl:NearArsenalCrate()
end

function GM:PlayerTraceAttack(pl, dmginfo, dir, trace)
end

function GM:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if dmginfo:IsBulletDamage() then
		if hitgroup == HITGROUP_HEAD then
			pl.m_LastHeadShot = CurTime()
		end

		-- Reduce bullet damage based on distance.
		--[[local attacker = dmginfo:GetAttacker()
		if attacker:IsPlayer() then
			local inflictor = dmginfo:GetInflictor()
			if inflictor:IsValid() and not inflictor.NoDistanceReduction then
				local dist = inflictor:GetPos():Distance(dmginfo:GetDamagePosition())
				if dist > 400 then
					dist = dist - 400
					dmginfo:SetDamage(dmginfo:GetDamage() * (1 - math.min(1, dist / 400) * 0.4))
				end
			end
		end]]
	end

	if not pl:CallZombieFunction("ScalePlayerDamage", hitgroup, dmginfo) then
		if hitgroup == HITGROUP_HEAD then
			dmginfo:SetDamage(dmginfo:GetDamage() * 2)
		elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.25)
		elseif hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.75)
		end
	end

	if (hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG) and self:PlayerShouldTakeDamage(pl, dmginfo:GetAttacker()) then
		pl:AddLegDamage(dmginfo:GetDamage())
	end
end

function GM:CanDamageNail(ent, attacker, inflictor, damage, dmginfo)
	return not attacker:IsPlayer() or attacker:Team() ~= TEAM_HUMAN
end

function GM:GetZombieDamageScale(pos, ignore)
	return self.ZombieDamageMultiplier --* (1 - self:GetFearMeterPower(pos, TEAM_UNDEAD, ignore) * 0.25)
end

local temppos
local function SortByDistance(a, b)
	return a:GetPos():Distance(temppos) < b:GetPos():Distance(temppos)
end

function GM:GetClosestSpawnPoint(teamid, pos)
	temppos = pos
	local spawnpoints
	if type(teamid) == "table" then
		spawnpoints = teamid
	else
		spawnpoints = team.GetSpawnPoint(teamid)
	end
	table.sort(spawnpoints, SortByDistance)
	return spawnpoints[1]
end

local FEAR_RANGE = 768
local FEAR_PERINSTANCE = 0.075
local RALLYPOINT_THRESHOLD = 0.3

local function GetEpicenter(tab)
	local vec = Vector(0, 0, 0)
	if #tab == 0 then return vec end

	for k, v in pairs(tab) do
		vec = vec + v:GetPos()
	end

	return vec / #tab
end

function GM:GetTeamRallyGroups(teamid)
	local groups = {}
	local ingroup = {}

	local plys = team.GetPlayers(teamid)

	for _, pl in pairs(plys) do
		if not ingroup[pl] and pl:Alive() then
			local plpos = pl:GetPos()
			local group = {pl}

			for __, otherpl in pairs(plys) do
				if otherpl ~= pl and not ingroup[otherpl] and otherpl:Alive() and otherpl:GetPos():Distance(plpos) <= FEAR_RANGE then
					group[#group + 1] = otherpl
				end
			end

			if #group * FEAR_PERINSTANCE >= RALLYPOINT_THRESHOLD then
				for k, v in pairs(group) do
					ingroup[v] = true
				end
				groups[#groups + 1] = group
			end
		end
	end

	return groups
end

function GM:GetTeamRallyPoints(teamid)
	local points = {}

	for _, group in pairs(self:GetTeamRallyGroups(teamid)) do
		points[#points + 1] = {GetEpicenter(group), math.min(1, (#group * FEAR_PERINSTANCE - RALLYPOINT_THRESHOLD) / (1 - RALLYPOINT_THRESHOLD))}
	end

	return points
end

local CachedTeamRallyPointTimes = {}
local CachedTeamRallyPoints = {}
function GM:GetCachedTeamRallyPoints(teamid)
	if CachedTeamRallyPoints[teamid] and CurTime() < CachedTeamRallyPointTimes[teamid] then
		return CachedTeamRallyPoints[teamid]
	end

	local points = self:GetTeamRallyPoints(teamid)

	CachedTeamRallyPoints[teamid] = points
	CachedTeamRallyPointTimes[teamid] = CurTime() + 0.1

	return points
end

local CachedEpicentreTimes = {}
local CachedEpicentres = {}
function GM:GetTeamEpicentre(teamid, nocache)
	if not nocache and CachedEpicentres[teamid] and CurTime() < CachedEpicentreTimes[teamid] then
		return CachedEpicentres[teamid]
	end

	local plys = team.GetPlayers(teamid)
	local vVec = Vector(0, 0, 0)
	for _, pl in pairs(plys) do
		if pl:Alive() then
			vVec = vVec + pl:GetPos()
		end
	end

	local epicentre = vVec / #plys
	if not nocache then
		CachedEpicentreTimes[teamid] = CurTime() + 0.5
		CachedEpicentres[teamid] = epicentre
	end

	return epicentre
end
GM.GetTeamEpicenter = GM.GetTeamEpicentre

function GM:GetCurrentEquipmentCount(id)
	local count = 0

	local item = self.Items[id]
	if item then
		if item.Countables then
			if type(item.Countables) == "table" then
				for k, v in pairs(item.Countables) do
					count = count + #ents.FindByClass(v)
				end
			else
				count = count + #ents.FindByClass(item.Countables)
			end
		end

		if item.SWEP then
			count = count + #ents.FindByClass(item.SWEP)
		end
	end

	return count
end

function GM:GetFearMeterPower(pos, teamid, ignore)
	if LASTHUMAN then return 1 end

	local power = 0

	for _, pl in pairs(player.GetAll()) do
		if pl ~= ignore and pl:Team() == teamid and not pl:CallZombieFunction("DoesntGiveFear") and pl:Alive() then
			local dist = pl:NearestPoint(pos):Distance(pos)
			if dist <= FEAR_RANGE then
				power = power + ((FEAR_RANGE - dist) / FEAR_RANGE) * (pl:GetZombieClassTable().FearPerInstance or FEAR_PERINSTANCE)
			end
		end
	end

	return math.min(1, power)
end

function GM:GetRagdollEyes(pl)
	local Ragdoll = pl:GetRagdollEntity()
	if not Ragdoll then return end

	local att = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
	if att then
		att.Pos = att.Pos + att.Ang:Forward() * -2
		att.Ang = att.Ang

		return att.Pos, att.Ang
	end
end

function GM:PlayerNoClip(pl, on)
	if pl:IsAdmin() then
		if SERVER then
			PrintMessage(HUD_PRINTCONSOLE, pl:Name().." turned "..(on and "on" or "off").." noclip.")
		end

		return true
	end

	return false
end

function GM:IsSpecialPerson(pl, image)
	local img, tooltip

	if pl:SteamID() == "STEAM_0:1:3307510" then
		img = "rosette"
		tooltip = "Creator of Zombie Survival"
  elseif pl:SteamID() == "STEAM_0:0:17321155" then
		img = "award_star_gold_1"
		tooltip = "Owner of Terminal Shell"
	elseif pl:SteamID() == "STEAM_0:1:19367918" then
		img = "medal_gold_1"
		tooltip = "Co-owner of Terminal Shell"
	elseif pl:SteamID() == "STEAM_0:0:13473110" then
		img = "award_star_silver_2"
		tooltip = "Founder of Terminal Shell"
	elseif ( evolve and evolve.donors and evolve:IsDonor( pl ) ) then
		img = "heart"
		tooltip = "Community Investor"
	end

	if img then
		if CLIENT then
			image:SetImage("icon16/"..img..".png")
			image:SetTooltip(tooltip)
		end

		return true
	end

	return false
end

function GM:GetWaveEnd()
	return GetGlobalFloat("waveend", 0)
end

function GM:SetWaveEnd(wave)
	SetGlobalFloat("waveend", wave)
end

function GM:GetWaveStart()
	return GetGlobalFloat("wavestart", self.WaveZeroLength)
end

function GM:SetWaveStart(wave)
	SetGlobalFloat("wavestart", wave)
end

function GM:GetWave()
	return GetGlobalInt("wave", 0)
end

if GM:GetWave() == 0 then
	GM:SetWaveStart(GM.WaveZeroLength)
	GM:SetWaveEnd(GM.WaveZeroLength + GM:GetWaveOneLength())
end

function GM:GetWaveActive()
	return GetGlobalBool("waveactive", false)
end

function GM:SetWaveActive(active)
	if self.RoundEnded then return end

	if self:GetWaveActive() ~= active then
		SetGlobalBool("waveactive", active)

		if SERVER then
			gamemode.Call("WaveStateChanged", active)
		end
	end
end
