hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")
	-- Secret room blocker.
	local entBlock=ents.Create("prop_dynamic_override")
	if entBlock:IsValid() then
		entBlock:SetPos(Vector(-255,1247,10))
		entBlock:SetAngles(Angle(0,0,0))
		entBlock:SetKeyValue("solid", "6")
		entBlock:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock:SetMaterial("models/effects/vol_light001")
		entBlock:SetColor(Color(0,0,0,0))
		entBlock:Spawn()
	end
	-- Spawn camping blocker
	local entBlock=ents.Create("prop_dynamic_override")
	if entBlock:IsValid() then
		entBlock:SetPos(Vector(303,-5707,307))
		entBlock:SetAngles(Angle(47,90,90))
		entBlock:SetKeyValue("solid", "6")
		entBlock:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock:Spawn()
	end
end)