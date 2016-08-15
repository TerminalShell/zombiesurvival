-- Prevent players from getting on the edge of the map
hook.Add("SetupMove","CheckZHeight",function(pl,move)
	if (pl:GetPos().z > 175 and pl:Team() == TEAM_SURVIVORS) or (pl:GetPos().z < -444 and pl:Team() == TEAM_UNDEAD) then
		move:SetOrigin(Vector(-1670,331,150))
	end
end)
/*
-- Prevent players from falling under the map
hook.Add("Think","CheckZHeight",function()
	for k,v in pairs(player.GetAll()) do
		if v:GetPos().z<-444 then
			v:SetPos(Vector(-1670,331,919))
		end
	end
end)
*/