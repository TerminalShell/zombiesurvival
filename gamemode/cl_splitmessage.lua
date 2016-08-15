local CachedMarkups = {}

local ToDraw = {}
local DrawTime = 0

local function DrawSplitMessage()
	local curtime = CurTime()

	if curtime > DrawTime then
		hook.Remove("HUDPaint", "DrawSplitMessage")
		DrawTime = nil
		return
	end

	local dh = ScrH() * 0.65

	for i, marked in ipairs(ToDraw) do
		local delta = DrawTime - curtime

		local th = marked.totalHeight
		local tw = marked.totalWidth

		if delta > 3.5 then
			delta = delta - 3.5
			delta = 0.5 - delta

			local halfw = tw * 0.5

			marked:Draw(w * (1 - delta) - halfw, dh)
			marked:Draw(w * delta - halfw, dh)
		else
			local mid = w * 0.5 - tw * 0.5

			local alpha = math.min(1, delta) * 255
			marked:Draw(mid, dh, nil, nil, alpha)
			marked:Draw(mid + math.random(-1, 1), dh + math.random(-1, 1), nil, nil, alpha)
		end

		dh = dh + th
	end
end

function GM:SplitMessage(...)
	local arg = {...}

	ToDraw = {}
	DrawTime = CurTime() + 4

	for i=1, #arg do
		local str = "<color=ltred><font=ZSHUDFont>"..arg[i]
		if not CachedMarkups[str] then
			CachedMarkups[str] = markup.Parse(str, ScrW() - 8)
		end

		table.insert(ToDraw, CachedMarkups[str])
	end

	hook.Add("HUDPaint", "DrawSplitMessage", DrawSplitMessage)
end
