hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")
	-- Secret room blocker.
	local entBlock=ents.Create("prop_dynamic_override")
	if entBlock:IsValid() then
		entBlock:SetPos(Vector(1560,-451,-25))
		entBlock:SetAngles(Angle(0,90,90))
		entBlock:SetKeyValue("solid", "6")
		entBlock:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		entBlock:Spawn()
	end
end)