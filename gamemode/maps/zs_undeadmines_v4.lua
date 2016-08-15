hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")
	-- Secret room blockers.
	local entBlock=ents.Create("prop_dynamic_override")
	if entBlock:IsValid() then
		entBlock:SetPos(Vector(196,2912,453))
		entBlock:SetAngles(Angle(0,0,0))
		entBlock:SetKeyValue("solid", "6")
		entBlock:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock:SetMaterial("models/props_wasteland/wood_fence01a")
		entBlock:Spawn()
	end
	
	local entBlock2=ents.Create("prop_dynamic_override")
	if entBlock2:IsValid() then
		entBlock2:SetPos(Vector(196,2912,559))
		entBlock2:SetAngles(Angle(0,0,0))
		entBlock2:SetKeyValue("solid", "6")
		entBlock2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock2:SetMaterial("models/props_wasteland/wood_fence01a")
		entBlock2:Spawn()
	end
	
	local entBlock3=ents.Create("prop_dynamic_override")
	if entBlock3:IsValid() then
		entBlock3:SetPos(Vector(196,2912,665))
		entBlock3:SetAngles(Angle(0,0,0))
		entBlock3:SetKeyValue("solid", "6")
		entBlock3:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock3:SetMaterial("models/props_wasteland/wood_fence01a")
		entBlock3:Spawn()
	end
end)