function GM:RenderScreenspaceEffects()
end

GM.PostProcessingEnabled = CreateClientConVar("zs_postprocessing", 1, true, false):GetBool()
cvars.AddChangeCallback("zs_postprocessing", function(cvar, oldvalue, newvalue)
	GAMEMODE.PostProcessingEnabled = tonumber(newvalue) == 1
end)

GM.FilmGrainEnabled = CreateClientConVar("zs_filmgrain", 1, true, false):GetBool()
cvars.AddChangeCallback("zs_filmgrain", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmGrainEnabled = tonumber(newvalue) == 1
end)

GM.FilmGrainOpacity = CreateClientConVar("zs_filmgrainopacity", 50, true, false):GetInt()
cvars.AddChangeCallback("zs_filmgrainopacity", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmGrainOpacity = math.Clamp(tonumber(newvalue) or 0, 0, 255)
end)

GM.ColorModEnabled = CreateClientConVar("zs_colormod", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_colormod", function(cvar, oldvalue, newvalue)
	GAMEMODE.ColorModEnabled = tonumber(newvalue) == 1
end)

GM.Auras = CreateClientConVar("zs_auras", 1, true, false):GetBool()
cvars.AddChangeCallback("zs_auras", function(cvar, oldvalue, newvalue)
	GAMEMODE.Auras = tonumber(newvalue) == 1
end)

GM.AuraColorEmpty = Color(CreateClientConVar("zs_auracolor_empty_r", 255, true, false):GetInt(), CreateClientConVar("zs_auracolor_empty_g", 0, true, false):GetInt(), CreateClientConVar("zs_auracolor_empty_b", 0, true, false):GetInt(), 255)
GM.AuraColorFull = Color(CreateClientConVar("zs_auracolor_full_r", 20, true, false):GetInt(), CreateClientConVar("zs_auracolor_full_g", 255, true, false):GetInt(), CreateClientConVar("zs_auracolor_full_b", 20, true, false):GetInt(), 255)

cvars.AddChangeCallback("zs_auracolor_empty_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.r = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_auracolor_empty_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.g = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_auracolor_empty_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.b = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_auracolor_full_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.r = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_auracolor_full_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.g = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_auracolor_full_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.b = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

GM.RallyColorFull = Color(CreateClientConVar("zs_rallycolor_full_r", 255, true, false):GetInt(), CreateClientConVar("zs_rallycolor_full_g", 0, true, false):GetInt(), CreateClientConVar("zs_rallycolor_full_b", 0, true, false):GetInt(), 255)
GM.RallyColorEmpty = Color(CreateClientConVar("zs_rallycolor_empty_r", 0, true, false):GetInt(), CreateClientConVar("zs_rallycolor_empty_g", 255, true, false):GetInt(), CreateClientConVar("zs_rallycolor_empty_b", 0, true, false):GetInt(), 255)

cvars.AddChangeCallback("zs_rallycolor_empty_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorEmpty.r = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_rallycolor_empty_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorEmpty.g = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_rallycolor_empty_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorEmpty.b = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_rallycolor_full_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorFull.r = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_rallycolor_full_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorFull.g = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

cvars.AddChangeCallback("zs_rallycolor_full_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.RallyColorFull.b = math.min(math.max(math.ceil(tonumber(newvalue) or 0), 0), 255)
end)

local tColorModDead = {
	["$pp_colour_contrast"] = 1.25,
	["$pp_colour_colour"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.02,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local tColorModHuman = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local tColorModZombie = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.25,
	["$pp_colour_colour"] = 0.5,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local tColorModZombieVision = {
	["$pp_colour_colour"] = 0.75,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.5,
	["$pp_colour_mulr"]	= 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0
}

local fear = 0
local DrawColorModify = DrawColorModify
local surface = surface
local EyePos = EyePos
local EyeAngles = EyeAngles
local TEAM_HUMAN = TEAM_HUMAN
local TEAM_UNDEAD = TEAM_UNDEAD
local matTankGlass = Material("models/props_lab/Tank_Glass001")
function GM:_RenderScreenspaceEffects()
	if render.GetDXLevel() < 80 then return end

	if MySelf.Confusion and MySelf.Confusion:IsValid() then
		MySelf.Confusion:RenderScreenSpaceEffects()
	end

	fear = math.Approach(fear, self:CachedFearPower(), FrameTime())

	if not self.PostProcessingEnabled then return end

	if self.DrawPainFlash and self.HurtEffect > 0 then
		DrawSharpen(1, math.min(6, self.HurtEffect * 3))
	end

	if MySelf:Team() == TEAM_UNDEAD and self.m_ZombieVision and not matTankGlass:IsError() then
		render.UpdateScreenEffectTexture()
		matTankGlass:SetFloat("$envmap", 0)
		matTankGlass:SetFloat("$envmaptint", 0)
		matTankGlass:SetFloat("$refractamount", 0.035)
		matTankGlass:SetInt("$ignorez", 1)
		render.SetMaterial(matTankGlass)
		render.DrawScreenQuad()
	end

	if self.ColorModEnabled then
		if not MySelf:Alive() and MySelf:GetObserverMode() ~= OBS_MODE_CHASE then
			tColorModDead["$pp_colour_colour"] = (1 - math.min(1, CurTime() - self.LastTimeAlive)) * 0.5
			DrawColorModify(tColorModDead)
		elseif MySelf:Team() == TEAM_UNDEAD then
			if self.m_ZombieVision then
				DrawColorModify(tColorModZombieVision)
			else
				tColorModZombie["$pp_colour_colour"] = math.min(1, 0.25 + math.min(1, (CurTime() - self.LastTimeDead) * 0.5) * 1.75 * fear)

				DrawColorModify(tColorModZombie)
			end
		else
			local curr = tColorModHuman["$pp_colour_addr"]
			local health = MySelf:Health()
			if health <= 50 then
				tColorModHuman["$pp_colour_addr"] = math.min(0.3 - health * 0.006, curr + FrameTime() * 0.055)
			elseif 0 < curr then
				tColorModHuman["$pp_colour_addr"] = math.max(0, curr - FrameTime() * 0.1)
			end

			tColorModHuman["$pp_colour_brightness"] = fear * -0.045
			tColorModHuman["$pp_colour_contrast"] = 1 + fear * 0.15
			tColorModHuman["$pp_colour_colour"] = 1 - fear * 0.725 --0.85

			DrawColorModify(tColorModHuman)
		end
	end
end

local matGlow = Material("Sprites/light_glow02_add_noz")
local colHealthEmpty = GM.AuraColorEmpty
local colHealthFull = GM.AuraColorFull
local colHealth = Color(255, 255, 255, 255)
local matRally = Material("zombiesurvival/horderally")
local colRallyEmpty = GM.RallyColorEmpty
local colRallyFull = GM.RallyColorFull
local colRally = Color(255, 255, 255, 255)
local matPullBeam = Material("cable/rope")
local colPullBeam = Color(255, 255, 255, 255)


function GM:_PostDrawOpaqueRenderables()
	if MySelf:Team() == TEAM_UNDEAD then
		if self.Auras then
			local eyepos = EyePos()
			for _, pl in pairs(team.GetPlayers(TEAM_HUMAN)) do
				if pl:Alive() and pl:GetPos():Distance(eyepos) <= pl:GetAuraRange() then
					local healthfrac = math.max(pl:Health(), 0) / pl:GetMaxHealth()
					colHealth.r = math.Approach(colHealthEmpty.r, colHealthFull.r, math.abs(colHealthEmpty.r - colHealthFull.r) * healthfrac)
					colHealth.g = math.Approach(colHealthEmpty.g, colHealthFull.g, math.abs(colHealthEmpty.g - colHealthFull.g) * healthfrac)
					colHealth.b = math.Approach(colHealthEmpty.b, colHealthFull.b, math.abs(colHealthEmpty.b - colHealthFull.b) * healthfrac)

					local attach = pl:GetAttachment(pl:LookupAttachment("chest"))
					local pos = attach and attach.Pos or pl:LocalToWorld(pl:OBBCenter())

					render.SetMaterial(matGlow)
					render.DrawSprite(pos, 13, 13, colHealth)
					local size = math.sin(self.HeartBeatTime + pl:EntIndex()) * 50 - 21
					if size > 0 then
						render.DrawSprite(pos, size * 1.5, size, colHealth)
						render.DrawSprite(pos, size, size * 1.5, colHealth)
					end
				end
			end
		end

		if self.RallyPointsEnabled then
			local points = self:GetTeamRallyPoints(TEAM_UNDEAD)
			if #points > 0 then
				local eyepos = EyePos()

				render.SetMaterial(matRally)
				for _, point in pairs(points) do
					local pos = point[1] + Vector(0, 0, 128)
					local magnitude = point[2]
					local size = 12 + math.max(0, math.sin(RealTime() * 4)) * 5 + magnitude * 8

					colRally.r = math.Approach(colRallyEmpty.r, colRallyFull.r, math.abs(colRallyEmpty.r - colRallyFull.r) * magnitude)
					colRally.g = math.Approach(colRallyEmpty.g, colRallyFull.g, math.abs(colRallyEmpty.g - colRallyFull.g) * magnitude)
					colRally.b = math.Approach(colRallyEmpty.b, colRallyFull.b, math.abs(colRallyEmpty.b - colRallyFull.b) * magnitude)
					colRally.a = 16 + magnitude * 200 * math.min(1, pos:Distance(EyePos()) / 256)

					render.DrawSprite(pos, size, size, colRally)
				end
			end
		end
	else
		self:DrawCraftingEntity()

		local holding = MySelf.status_human_holding
		if holding and holding:IsValid() and holding:GetIsHeavy() then
			local object = holding:GetObject()
			if object:IsValid() then
				local pullpos = holding:GetPullPos()
				local hingepos = holding:GetHingePos()
				local r, g, b = render.GetLightRGB(hingepos)
				colPullBeam.r = r * 255
				colPullBeam.g = g * 255
				colPullBeam.b = b * 255
				render.SetMaterial(matPullBeam)
				render.DrawBeam(hingepos, pullpos, 0.5, 0, pullpos:Distance(hingepos) / 128, colPullBeam)
			end
		end
	end
end

function GM:ToggleZombieVision(onoff)
	if onoff == nil then
		onoff = not self.m_ZombieVision
	end

	if onoff then
		if not self.m_ZombieVision then
			self.m_ZombieVision = true
			MySelf:EmitSound("npc/stalker/breathing3.wav", 0, 230)
			MySelf:SetDSP(5)
		end
	elseif self.m_ZombieVision then
		self.m_ZombieVision = nil
		MySelf:EmitSound("npc/zombie/zombie_pain6.wav", 0, 110)
		MySelf:SetDSP(0)
	end
end
