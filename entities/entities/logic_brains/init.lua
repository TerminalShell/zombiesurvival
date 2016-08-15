ENT.Base = "logic_points"
ENT.Type = "point"

ENT.ValidTeam = TEAM_UNDEAD

function ENT:Add(pl, amount)
	if pl and pl:IsValid() and pl:IsPlayer() and pl:Team() == self.ValidTeam then
		amount = math.Round(amount)
		if amount < 0 then
			pl:TakeBrains(-amount)
		else
			pl:AddBrains(amount)
		end
	end
end

function ENT:SetAmount(pl, amount)
	local diff = amount - pl:GetFrags()
	pl:SetFrags(amount)
	pl.BrainsEaten = pl.BrainsEaten + diff
	pl:CheckRedeem()
end

function ENT:GetAmount(pl)
	return pl:GetFrags()
end

function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setredeembrains" then
		GAMEMODE:SetRedeemBrains(tonumber(args) or 0)
	elseif name == "redeemactivator" then
		if activator and activator:IsValid() and activator:IsPlayer() and activator:Team() == TEAM_UNDEAD then
			activator:Redeem()
		end
	elseif name == "redeemcaller" then
		if caller and caller:IsValid() and caller:IsPlayer() and caller:Team() == TEAM_UNDEAD then
			caller:Redeem()
		end
	else
		self.BaseClass.AcceptInput(self, name, activator, caller, args)
	end
end
