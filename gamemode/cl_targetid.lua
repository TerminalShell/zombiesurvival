local trace = {mask = MASK_SHOT, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), filter = {}}
local entitylist = {}

local colTemp = Color(255, 255, 255)
function GM:DrawTargetID(ent, fade)
	fade = fade or 1
	local ts = ent:GetPos():ToScreen()
	local x, y = ts.x, math.Clamp(ts.y, 0, ScrH() * 0.95)

	colTemp.a = fade * 255
	util.ColorCopy(team.GetColor(LocalPlayer():Team()), colTemp)

	local name = ent:Name()
	draw.SimpleTextBlur(name, "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
	surface.SetFont("ZSHUDFontSmaller")
	local texw, texh = surface.GetTextSize(name)
	y = y + texh + 4

	local healthfraction = math.max(ent:Health() / (ent:Team() == TEAM_UNDEAD and ent:GetMaxZombieHealth() or ent:GetMaxHealth()), 0)
	if healthfraction ~= 1 then
		util.ColorCopy(0.75 <= healthfraction and COLOR_HEALTHY or 0.5 <= healthfraction and COLOR_SCRATCHED or 0.25 <= healthfraction and COLOR_HURT or COLOR_CRITICAL, colTemp)

		local healthdisplay = math.ceil(healthfraction * 100).."%"
		surface.SetFont("ZSHUDFont")
		draw.SimpleTextBlur(healthdisplay, "ZSHUDFont", x, y, colTemp, TEXT_ALIGN_CENTER)
		local texw, texh = surface.GetTextSize(healthdisplay)
		y = y + texh + 4
	end

	util.ColorCopy(color_white, colTemp)

	if ent:Team() == TEAM_UNDEAD then
		local classname = ent:GetZombieClassTable().Name
		if classname then
			draw.SimpleTextBlur(classname, "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		end
	else
		local wep = ent:GetActiveWeapon()
		if wep:IsValid() then
			draw.SimpleTextBlur(wep:GetPrintName(), "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		end
	end
end

function GM:HUDDrawTargetID(teamid)
	local start = EyePos()
	trace.start = start
	trace.endpos = start + EyeAngles():Forward() * 2048
	trace.filter[1] = MySelf
	trace.filter[2] = MySelf:GetObserverTarget()

	local entity = util.TraceHull(trace).Entity
	if entity:IsValid() and entity:IsPlayer() and entity:Team() == teamid then
		entitylist[entity] = CurTime()
	end

	for ent, time in pairs(entitylist) do
		if ent:IsValid() and not (ent:IsPlayer() and ent:Team() ~= teamid) and CurTime() < time + 2 then
			self:DrawTargetID(ent, 1 - math.Clamp((CurTime() - time) / 2, 0, 1))
		else
			entitylist[ent] = nil
		end
	end
end
