-- Prevent players from getting on roof
hook.Add("SetupMove","CheckZHeight",function(pl,move)
	if pl:GetPos().z > 480 and pl:Team() == TEAM_SURVIVORS then
		move:SetOrigin(Vector(700,-150,235))
	end
end)