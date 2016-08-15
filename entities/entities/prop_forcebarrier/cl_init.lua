include("shared.lua")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
	self.AmbientSound:PlayEx(0.2, 100)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.2, 100 + RealTime() % 1)
	
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		local c = Color(100, 230, 255, 255)
		dlight.Pos = self:GetPos() + self:GetForward() * 3
		dlight.r = c.r
		dlight.g = c.g
		dlight.b = c.b
		dlight.Brightness = 0.3
		dlight.Decay = 500 * 5
		dlight.Size = 500
		dlight.DieTime = CurTime() + 1
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end