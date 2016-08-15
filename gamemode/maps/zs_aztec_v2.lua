hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")
	-- Secret button remover.
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
end)