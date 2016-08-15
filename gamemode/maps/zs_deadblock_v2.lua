hook.Add("InitPostEntityMap", "Adding", function()
	-- I think its about time that this map be purged of blue shelves.
	for _, ent in pairs(ents.FindByClass("prop_physics")) do
		if ent:GetModel() == "models/props_wasteland/kitchen_shelf001a.mdl"then
			ent:Remove()
		end
	end

	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-264, -229, 452))
		ent2:SetAngles(Angle(90, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		ent2:SetColor(Color(0, 0, 0, 0))
              ent2:SetRenderMode( RENDERMODE_TRANSALPHA )
	end

	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-382, -227, 452))
		ent2:SetAngles(Angle(90, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		ent2:SetColor(Color(0, 0, 0, 0))
              ent2:SetRenderMode( RENDERMODE_TRANSALPHA )
	end
end)
