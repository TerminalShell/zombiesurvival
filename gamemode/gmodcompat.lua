AddCSLuaFile()

if CLIENT then

local oldgettextsize = surface.GetTextSize
function surface.GetTextSize(text)
	local a, b = oldgettextsize(text)
	if not a then return 8, 12 end

	return a, b
end

end
