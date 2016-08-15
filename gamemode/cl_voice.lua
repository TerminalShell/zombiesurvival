local PANEL = {}
local PlayerVoicePanels = {}

function PANEL:Init()
	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "GModNotify" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 8, 0, 0, 0 )
	self.LabelName:SetTextColor( Color( 255, 255, 255, 255 ) )

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT );
	self.Avatar:SetSize( 32, 32 )

	self.Color = color_transparent

	self:SetSize( 250, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 2, 2, 2, 2 )
	self:Dock( BOTTOM )
end

function PANEL:Setup( ply )
	self.ply = ply
	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	self.Color = team.GetColor( ply:Team() )
	self:InvalidateLayout()
end

function PANEL:Paint( w, h )
	if ( !IsValid( self.ply ) ) then return end
	
	local wide = w
	local tall = h
	local x = 0
	local y = 0
	
	if ( evolve and evolve.donors and evolve:IsDonor( self.ply ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 226, 179, 41, 240 ) )
		wide = w - 4
		tall = h - 4
		x = 2
		y = 2
	else
		
	end
	
	local c = Color( 0, self.ply:VoiceVolume() * 255, 0, 240 )
	if ( self.ply:Team() == 4 ) then
		c = Color( 0, self.ply:VoiceVolume() * 160, self.ply:VoiceVolume() * 255, 240 )
	end
	
	draw.RoundedBox( 4, x, y, wide, tall, c )
end

function PANEL:Think( )
	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end
end

function PANEL:FadeOut( anim, delta, data )
	if ( anim.Finished ) then
		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil
			return
		end
		
	return end
	self:SetAlpha( 255 - (255 * delta) )
end
derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

function GM:PlayerStartVoice( ply )
	if ( !IsValid( g_VoicePanelList ) ) then return end
	if not VoiceDrain:CanSpeak() then return end
	
	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )
	
	if ply == LocalPlayer() then 
		VoiceDrain:SetSpeaking(true)
	end
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		if ( PlayerVoicePanels[ ply ].fadeAnim ) then
			PlayerVoicePanels[ ply ].fadeAnim:Stop()
			PlayerVoicePanels[ ply ].fadeAnim = nil
		end

		PlayerVoicePanels[ ply ]:SetAlpha( 255 )
		return;
	end
	
	if ( !IsValid( ply ) ) then return end
	local pnl = g_VoicePanelList:Add( "VoiceNotify" )
	pnl:Setup( ply )
	PlayerVoicePanels[ ply ] = pnl
end


local function VoiceClean()
	for k, v in pairs( PlayerVoicePanels ) do
		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end
	end
end
timer.Create( "VoiceClean", 10, 0, VoiceClean )

function GM:PlayerEndVoice( ply )
   if ply == LocalPlayer() then
      VoiceDrain:SetSpeaking(false)
   end
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end
		PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
		PlayerVoicePanels[ ply ].fadeAnim:Start( 2 )
	end
end

local function CreateVoiceVGUI()
	g_VoicePanelList = vgui.Create( "DPanel" )
	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetPos( ScrW() - 300, 100 )
	g_VoicePanelList:SetSize( 250, ScrH() - 250 )
	g_VoicePanelList:SetDrawBackground( false )
end
hook.Add( "InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI )

/* Voice drain */

VoiceDrain = {}
VoiceDrain.battery_max = 100
VoiceDrain.battery_min = 10
VoiceDrain.battery_drain = 0.2
VoiceDrain.battery_drain_admin = 0.2
VoiceDrain.battery_recharge = 0.2
VoiceDrain.battery_recharge_admin = 0.2

hook.Add("InitPostEntity", "VoiceDrainInit", function()
	LocalPlayer().voice_battery = VoiceDrain.battery_max
	LocalPlayer().speaking = false
end)

function VoiceDrain:GetRechargeRate()
	local ply = LocalPlayer()
	if (not IsValid(ply)) then return false end
	
	local r = self.battery_recharge
	if ply:IsAdmin() then r = self.battery_recharge_admin end
	if LocalPlayer().voice_battery < self.battery_min then 
		r = r / 2
	end
	return r
end

function VoiceDrain:GetDrainRate()
	local ply = LocalPlayer()
	if (not IsValid(ply)) then return false end
	
	if ply:IsAdmin() then
		return self.battery_drain_admin
	else
		return self.battery_drain
	end
end

hook.Add("Tick", "VoiceDrainTick", function()
	local ply = LocalPlayer()
	if VoiceDrain:IsSpeaking() then
		ply.voice_battery = ply.voice_battery - VoiceDrain:GetDrainRate()
		if not VoiceDrain:CanSpeak() then
			ply.voice_battery = 0
			RunConsoleCommand("-voicerecord")
		end
	elseif ply.voice_battery!=nil and ply.voice_battery < VoiceDrain.battery_max then
		ply.voice_battery = ply.voice_battery + VoiceDrain:GetRechargeRate()
	end
end)

-- Player:IsSpeaking() does not work for localplayer
function VoiceDrain:IsSpeaking() return LocalPlayer().speaking end
function VoiceDrain:SetSpeaking(state) LocalPlayer().speaking = state end

function VoiceDrain:CanSpeak()
   return LocalPlayer().voice_battery > self.battery_min
end

local speaker = surface.GetTextureID("voice/icntlk_sv")
hook.Add("HUDPaint", "VoiceDrainHUD", function()
	local ply = LocalPlayer()
	local bat = ply.voice_battery
	if bat >= VoiceDrain.battery_max then return end
	
	local d = 168
	local m = 16
	local w = 16
	local h = 120
	local x = ScrW()-w-m
	local y = ScrH()-h-d-5
	
	local r = 0
	local g = 120
	if bat < VoiceDrain.battery_min and CurTime() % 0.2 < 0.1 then
		r = 160
		g = 0
	end
	
	surface.SetDrawColor(r/2, g/2, 0, 120)
	surface.SetTexture(speaker)
	surface.DrawTexturedRect(ScrW()-m-w+1, ScrH()-d+1, 16, 16)
	surface.DrawOutlinedRect(x+1, y+1, w, h)

	if bat < VoiceDrain.battery_min and CurTime() % 0.2 < 0.1 then
		surface.SetDrawColor(r, g, 0, 255)
	else
		surface.SetDrawColor(r, g, 0, 255)
	end
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetTexture(speaker)
	surface.DrawTexturedRect(ScrW()-m-w, ScrH()-d, 16, 16)

	x = x + 1
	y = y + 1
	w = w - 2
	h = h - 1
	
	local scale = h * math.Clamp((ply.voice_battery - 10) / 90, 0, 1)
	surface.SetDrawColor(0, 180, 0, 255)
	surface.DrawRect(x, y + h - scale, w, scale)
end)