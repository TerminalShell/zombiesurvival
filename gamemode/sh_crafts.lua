GM.CraftingRange = 72

GM.Crafts = {
	{
		Name = "a big wooden crate",
		a = {"*physics*", {"models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate001a_damaged.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl"}},
		b = {"*physics*", {"models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate001a_damaged.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl"}},
		Result = {"prop_physics", Model("models/props_junk/wood_crate002a.mdl")}
	},
	{
		Name = "an oil-filled barrel",
		a = {"*physics*", "models/props_junk/gascan001a.mdl"},
		b = {"*physics*", "models/props_c17/oildrum001.mdl"},
		Result = {"prop_physics", Model("models/props_c17/oildrum001_explosive.mdl")}
	}
}

function GM:GetCraftingRecipe(enta, entb)
	if not enta:IsValid() or not entb:IsValid() or enta == entb then return end

	for _, recipe in pairs(self.Crafts) do
		if self:CraftingRecipeMatches(enta, entb, recipe) then return recipe end
	end
end

function GM:GetCraftTarget(enta, entb)
	return enta:OBBMaxs():Distance(enta:OBBMins()) > entb:OBBMaxs():Distance(entb:OBBMins()) and enta or entb
end

function GM:CraftingRecipeMatches(enta, entb, recipe, checkedswap)
	local entaclass = enta:GetClass()
	local entbclass = entb:GetClass()
	local entaisphysics = string.sub(entaclass, 1, 12) == "prop_physics"
	local entbisphysics = string.sub(entbclass, 1, 12) == "prop_physics"

	if recipe.callback and recipe.callback(enta, entb) then
		return true
	end

	if recipe.a and recipe.b and (recipe.a[1] == entaclass or entaisphysics and recipe.a[1] == "*physics*") and (recipe.b[1] == entbclass or entaisphysics and recipe.a[1] == "*physics*") then
		local mdla = string.lower(enta:GetModel())
		local mdlb = string.lower(entb:GetModel())
		if (recipe.a[2] == nil or type(recipe.a[2]) == "table" and table.HasValue(recipe.a[2], mdla) or mdla == recipe.a[2]) and (recipe.b[2] == nil or type(recipe.b[2]) == "table" and table.HasValue(recipe.b[2], mdlb) or mdlb == recipe.b[2]) then
			return true
		end
	end

	if not checkedswap then
		return self:CraftingRecipeMatches(entb, enta, recipe, true)
	end
end

function GM:CanCraft(pl, enta, entb)
	if self:GetCraftingRecipe(enta, entb) == nil or not pl:IsValid() or not pl:Alive() or pl:Team() ~= TEAM_HUMAN then return false end

	if enta:IsBarricadeProp() or entb:IsBarricadeProp() or enta:GetName() ~= "" or entb:GetName() ~= "" then return false end

	local nearestb = entb:NearestPoint(enta:LocalToWorld(enta:OBBCenter()))
	local nearesta = enta:NearestPoint(entb:LocalToWorld(entb:OBBCenter()))
	if nearesta:Distance(nearestb) > self.CraftingRange or not TrueVisibleFilters(nearesta, nearestb, pl, enta, entb) then return false end

	local eyepos = pl:EyePos()
	if enta:NearestPoint(eyepos):Distance(eyepos) > self.CraftingRange or entb:NearestPoint(eyepos):Distance(eyepos) > self.CraftingRange then return false end

	if not TrueVisibleFilters(nearesta, eyepos, pl, enta, entb) or not TrueVisibleFilters(nearestb, eyepos, pl, enta, entb) then return false end

	return true
end

local meta = FindMetaTable("Entity")
if not meta then return end

function meta:IsPhysicsModel(mdl)
	return string.sub(self:GetClass(), 1, 12) == "prop_physics" and (not mdl or string.lower(self:GetModel()) == mdl)
end

function meta:IsWeaponType(class)
	return self:GetClass() == "prop_weapon" and self:GetWeaponType() == class
end
