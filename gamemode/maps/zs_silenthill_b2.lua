hook.Add("InitPostEntityMap", "Adding", function()
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(502, 912, -747))
		ent2:SetAngles(Angle(0,0,-90))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001b.mdl"))
		ent2:Spawn()
		ent2:SetColor(Color(0, 0, 0, 0))
              ent2:SetRenderMode( RENDERMODE_TRANSALPHA )
	end
end)
