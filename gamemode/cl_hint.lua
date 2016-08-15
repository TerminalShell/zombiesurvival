local Hints = {}

function GM:DrawPointWorldHints()
	for _, ent in pairs(ents.FindByClass("point_worldhint")) do ent:DrawHint() end
end

function GM:WorldHint(hint, pos, ent, lifetime)
	lifetime = lifetime or 8

	if ent and ent:IsValid() then
		if pos then
			pos = ent:WorldToLocal(pos)
		else
			pos = ent:OBBCenter()
		end
	end

	table.insert(Hints, {Hint = hint, Pos = pos, Entity = ent, StartTime = CurTime(), EndTime = CurTime() + lifetime})
end

usermessage.Hook("worldhint", function(um)
	GAMEMODE:WorldHint(um:ReadString(), um:ReadVector(), um:ReadEntity(), um:ReadFloat())
end)

local texRing = surface.GetTextureID("effects/select_ring")
local colFG = Color(220, 220, 220, 255)
function DrawWorldHint(hint, pos, delta, scale)
	local eyepos = EyePos()

	delta = delta or 10

	colFG.a = math.min(220, delta * 220)

	local ang = (eyepos - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 90)

	cam.IgnoreZ(true)
	cam.Start3D2D(pos, ang, (scale or 0.5) * math.max(250, eyepos:Distance(pos)) * delta * 0.001)

	draw.SimpleText(hint, "ZS3D2DFontSmall", 0, 32, colFG, TEXT_ALIGN_CENTER)
	draw.SimpleText("!", "zshintfont", 0, 0, colFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.SetTexture(texRing)
	for i=1, 4 do
		colFG.a = colFG.a * (1 / i)
		surface.SetDrawColor(colFG)
		local pulse = math.max(0.25, math.abs(math.sin(RealTime() * 6))) * 15 * i
		surface.DrawTexturedRectRotated(0, 0, 64 + pulse, 64 + pulse, 0)
	end

	cam.End3D2D()
	cam.IgnoreZ(false)
end
local DrawWorldHint = DrawWorldHint

function GM:DrawWorldHints()
	if #Hints > 0 then
		local curtime = CurTime()

		local done = true

		for _, hint in pairs(Hints) do
			local ent = hint.Entity
			if curtime < hint.EndTime and not (ent and not ent:IsValid()) then
				done = false

				DrawWorldHint(hint.Hint, ent and ent:LocalToWorld(hint.Pos) or hint.Pos, math.min(math.max(0, hint.EndTime - curtime), 1))
			end
		end

		if done then
			Hints = {}
		end
	end
end
