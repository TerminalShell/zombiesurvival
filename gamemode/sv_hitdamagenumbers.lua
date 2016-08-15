AddCSLuaFile("cl_hitdamagenumbers.lua")

util.AddNetworkString( "imHDN_createHitNumber" )

local on = true
CreateConVar( "sv_hitnums_show", 1 )
cvars.AddChangeCallback( "sv_hitnums_show", function()
	on = (GetConVarNumber("sv_hitnums_show") ~= 0)
end )

local showAll = false
CreateConVar( "sv_hitnums_showalldamage", 0 )
cvars.AddChangeCallback( "sv_hitnums_showalldamage", function()
	showAll = (GetConVarNumber("sv_hitnums_showalldamage") ~= 0)
end )

function EntDamage(target, dmginfo)
	
	if not on then return end
	
	local attacker = dmginfo:GetAttacker()
	if target:IsValid() and (attacker:IsValid() or showAll) then
		
		if (showAll or attacker:IsPlayer()) and target:Health()>0
			and target:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS then
		
			net.Start("imHDN_createHitNumber")
				
				-- Damage amount
				net.WriteFloat(dmginfo:GetDamage())
				
				-- Type of damage
				net.WriteUInt(dmginfo:GetDamageType(), 32)
				
				-- Is it a critical hit? (for players and npcs only)
				net.WriteBit( (dmginfo:GetDamage() >= target:GetMaxHealth())
							and (target:IsPlayer() or target:IsNPC()) )
				
				-- Get damage position
				local pos
				if dmginfo:IsBulletDamage() then
					pos = dmginfo:GetDamagePosition()
				else
					if target:IsPlayer() or target:IsNPC() then
						pos = target:GetPos() + Vector(0,0,48)
					else
						pos = target:GetPos()
					end
				end
				net.WriteVector(pos)
				
			if showAll then net.Broadcast() else
			net.Send(attacker) end
			
		end
		
	end
	
end
hook.Add("EntityTakeDamage", "ihHDN_EntDamage", EntDamage)
