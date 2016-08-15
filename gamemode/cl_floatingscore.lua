usermessage.Hook("HealedOtherPlayer", function(um)
	gamemode.Call("HealedOtherPlayer", um:ReadEntity(), um:ReadShort())
end)

usermessage.Hook("RepairedObject", function(um)
	gamemode.Call("RepairedObject", um:ReadEntity(), um:ReadShort())
end)

usermessage.Hook("ReceivedCommission", function(um)
	gamemode.Call("ReceivedCommission", um:ReadEntity(), um:ReadEntity(), um:ReadShort())
end)

function GM:ReceivedCommission(crate, buyer, points)
	gamemode.Call("FloatingScore", crate, "floatingscore_com", points)
end

function GM:HealedOtherPlayer(other, points)
	gamemode.Call("FloatingScore", other, "floatingscore", points)
end

function GM:RepairedObject(other, points)
	gamemode.Call("FloatingScore", other, "floatingscore", points)
end

local cvarNoFloatingScore = CreateClientConVar("zs_nofloatingscore", 0, true, false)
function GM:FloatingScore(victim, effectname, frags, flags)
	local isvec = type(victim) == "Vector"

	if cvarNoFloatingScore:GetBool() or not isvec and victim:IsPlayer() and victim:Team() == MySelf:Team() then return end

	effectname = effectname or "floatingscore"

	local pos = isvec and victim or victim:NearestPoint(EyePos())

	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetScale(flags or 0)
	if effectname == "floatingscore_und" then
		effectdata:SetMagnitude(frags or GAMEMODE.ZombieClasses[victim:GetZombieClass()].Points or 1)
	else
		effectdata:SetMagnitude(frags or 1)
	end
	util.Effect(effectname, effectdata, true, true)
end
