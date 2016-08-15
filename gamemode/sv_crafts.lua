function GM:CraftItem(pl, recipe, enta, entb)
	if enta._USEDINCRAFTING or entb._USEDINCRAFTING then return end

	if not recipe.OnCraft or not recipe.OnCraft(pl, enta, entb) then
		enta._USEDINCRAFTING = true
		entb._USEDINCRAFTING = true

		local result = recipe.Result
		if result then
			local target = self:GetCraftTarget(enta, entb)
			local ent = ents.Create(result[1])
			if ent:IsValid() then
				ent:SetPos(target:GetPos())
				ent:SetAngles(target:GetAngles())
				if result[2] then
					ent:SetModel(result[2])
				end
				ent:Spawn()

				if recipe.OnCrafted then
					recipe.OnCrafted(pl, recipe, enta, entb, ent)
				end

				ent:TemporaryBarricadeObject()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocity(target:GetVelocity())
				end
			end
		end

		enta:Remove()
		entb:Remove()
	end

	pl:SendLua("GAMEMODE:SplitMessage(\"Crafting Successful!\", \"<color=white><font=ZSHUDFontSmall>"..recipe.Name.."\") surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")
	PrintMessage(HUD_PRINTCONSOLE, pl:Name().." crafted "..recipe.Name..".")
end

concommand.Add("_zs_craftcombine", function(sender, command, arguments)
	local enta = Entity(tonumber(arguments[1] or 0) or 0)
	local entb = Entity(tonumber(arguments[2] or 0) or 0)

	local recipe = GAMEMODE:GetCraftingRecipe(enta, entb)
	if recipe and gamemode.Call("CanCraft", sender, enta, entb) then
		gamemode.Call("CraftItem", sender, recipe, enta, entb)
	end
end)

concommand.Add("_zs_useobject", function(sender, command, arguments)
	if not pl:IsValid() or not pl:Alive() or pl:Team() ~= TEAM_HUMAN then return end

	local ent = Entity(tonumber(arguments[1] or 0) or 0)
	local action = arguments[2] or ""

	if ent:IsValid() then
		local func = ent["Action_"..string.upper(action)]
		if func then
			local eyepos = sender:EyePos()
			local nearest = ent:NearestPoint(eyepos)
			if eyepos:Distance(nearest) <= 64 and TrueVisibleFilters(eyepos, nearest, sender, ent) then
				func(ent, sender, unpack(arguments[3]))
			end
		end
	end
end)
