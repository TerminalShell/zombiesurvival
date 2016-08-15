hook.Add("InitPostEntityMap", "Adding", function()
	

	for _, class in pairs(GAMEMODE.ZombieClasses) do
		class.Unlocked = true
	end

	hook.Add("PlayerReady", "GiveAllClasses", function(pl)
		pl:SendLua("for _, class in pairs(GAMEMODE.ZombieClasses) do class.Unlocked = true end")
	end)
end)
