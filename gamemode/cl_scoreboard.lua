local ScoreBoard
function GM:ScoreboardShow()
	gui.EnableScreenClicker(true)
	PlayMenuOpenSound()

	if not ScoreBoard then
		ScoreBoard = vgui.Create("ZSScoreBoard")
	end

	ScoreBoard:SetSize(math.min(ScrW(), ScrH()) * 0.8, ScrH() * 0.85)
	ScoreBoard:AlignTop(ScrH() * 0.05)
	ScoreBoard:CenterHorizontal()
	ScoreBoard:SetAlpha(0)
	ScoreBoard:AlphaTo(255, 0.5, 0)
	ScoreBoard:SetVisible(true)
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)

	if ScoreBoard then
		PlayMenuCloseSound()
		ScoreBoard:SetVisible(false)
	end
end

local PANEL = {}

PANEL.RefreshTime = 2
PANEL.NextRefresh = 0
PANEL.m_MaximumScroll = 0

function PANEL.PanelSort(a, b)
	return a:HasPriorityOver(b)
end

local function BlurPaint(self)
	draw.SimpleTextBlur(self:GetValue(), self.Font, 0, 0, self:GetTextColor())

	return true
end
local function emptypaint(self)
	return true
end
--[[local function ScrollUp(self)
	local pan = self:GetParent()
	local _, scroll = pan.m_PanelListCanvas:GetPos()

	scroll = math.Clamp(scroll + 20, -pan.m_MaximumScroll, 0)

	pan.m_PanelListCanvas:SetPos(0, scroll)
end
local function ScrollDown(self)
	local pan = self:GetParent()
	local _, scroll = pan.m_PanelListCanvas:GetPos()

	scroll = math.Clamp(scroll - 20, -pan.m_MaximumScroll, 0)

	pan.m_PanelListCanvas:SetPos(0, scroll)
end]]
local function CanvasOnMouseWheeled(self, delta)
	local _, scroll = self:GetPos()

	scroll = math.Clamp(scroll + delta * 20, -self:GetParent():GetParent().m_MaximumScroll, 0)

	self:SetPos(0, scroll)
end
function PANEL:Init()
	self.NextRefresh = RealTime() + 0.1

	self.m_TitleLabel = vgui.Create("DLabel", self)
	self.m_TitleLabel.Font = "ZSScoreBoardTitle"
	self.m_TitleLabel:SetFont(self.m_TitleLabel.Font)
	self.m_TitleLabel:SetText(GAMEMODE.Name)
	self.m_TitleLabel:SetTextColor(COLOR_GRAY)
	self.m_TitleLabel:SizeToContents()
	self.m_TitleLabel:NoClipping(true)
	self.m_TitleLabel.Paint = BlurPaint

	self.m_ServerNameLabel = vgui.Create("DLabel", self)
	self.m_ServerNameLabel.Font = "ZSScoreBoardSubTitle"
	self.m_ServerNameLabel:SetFont(self.m_ServerNameLabel.Font)
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SetTextColor(COLOR_GRAY)
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:NoClipping(true)
	self.m_ServerNameLabel.Paint = BlurPaint

	self.m_AuthorLabel = EasyLabel(self, "by "..GAMEMODE.Author.." ("..GAMEMODE.Email..")", "DefaultFontSmall", COLOR_GRAY)
	self.m_ContactLabel = EasyLabel(self, GAMEMODE.Website, "DefaultFontSmall", COLOR_GRAY)

	self.m_HumanHeading = vgui.Create("DTeamHeading", self)
	self.m_HumanHeading:SetTeam(TEAM_HUMAN)

	self.m_ZombieHeading = vgui.Create("DTeamHeading", self)
	self.m_ZombieHeading:SetTeam(TEAM_UNDEAD)

	self.m_PanelList = vgui.Create("Panel", self)
	--self.m_PanelList:NoClipping(true)
	self.m_PanelList:SetMouseInputEnabled(true)
	self.m_PanelList.Paint = emptypaint
	self.m_PanelListCanvas = vgui.Create("Panel", self.m_PanelList)
	--self.m_PanelListCanvas:NoClipping(true)
	self.m_PanelListCanvas:SetMouseInputEnabled(true)
	self.m_PanelListCanvas.Paint = emptypaint
	self.m_PanelListCanvas.OnMouseWheeled = CanvasOnMouseWheeled

	--[[self.m_ScrollUpButton = vgui.Create("DButton", self)
	self.m_ScrollUpButton:SetSize(64, 18)
	self.m_ScrollUpButton:SetText("Up")
	self.m_ScrollUpButton.DoClick = ScrollUp

	self.m_ScrollDownButton = vgui.Create("DButton", self)
	self.m_ScrollDownButton:SetSize(64, 18)
	self.m_ScrollDownButton:SetText("Down")
	self.m_ScrollDownButton.DoClick = ScrollDown]]

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.m_AuthorLabel:MoveBelow(self.m_TitleLabel)
	self.m_ContactLabel:MoveBelow(self.m_AuthorLabel)

	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	self.m_HumanHeading:SetSize(self:GetWide() / 2 - 32, 28)
	self.m_HumanHeading:SetPos(self:GetWide() * 0.25 - self.m_HumanHeading:GetWide() * 0.5, 110 - self.m_HumanHeading:GetTall())

	self.m_ZombieHeading:SetSize(self:GetWide() / 2 - 32, 28)
	self.m_ZombieHeading:SetPos(self:GetWide() * 0.75 - self.m_ZombieHeading:GetWide() * 0.5, 110 - self.m_ZombieHeading:GetTall())

	self.m_PanelList:SetSize(self:GetWide() - 16, self:GetTall() - 150)
	self.m_PanelListCanvas:SetWide(self.m_PanelList:GetWide())
	self.m_PanelList:AlignBottom(16)
	self.m_PanelList:CenterHorizontal()

	--[[self.m_ScrollUpButton:AlignLeft(8)
	self.m_ScrollUpButton:AlignBottom(8)
	self.m_ScrollDownButton:MoveRightOf(self.m_ScrollUpButton, 8)
	self.m_ScrollDownButton:AlignBottom(8)]]
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:Refresh()
	end
end

local texRightEdge = surface.GetTextureID("gui/gradient")
local texCorner = surface.GetTextureID("zombiesurvival/circlegradient")
local texDownEdge = surface.GetTextureID("gui/gradient_down")
function PANEL:Paint()
	local wid, hei = self:GetSize()
	local barw = 64

	surface.SetDrawColor(5, 5, 5, 180)
	surface.DrawRect(0, 64, wid, hei - 64)
	surface.SetDrawColor(90, 90, 90, 180)
	surface.DrawOutlinedRect(0, 64, wid, hei - 64)

	surface.SetDrawColor(5, 5, 5, 220)
	PaintGenericFrame(self, 0, 0, wid, 64, 32)

	surface.SetDrawColor(5, 5, 5, 160)
	surface.DrawRect(wid * 0.5 - 16, 64, 32, hei - 128)
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRect(wid * 0.5 + 16, 64, barw, hei - 128)
	surface.DrawTexturedRectRotated(wid * 0.5 - 16 - barw / 2, 64 + (hei - 128) / 2, barw, hei - 128, 180)
	surface.SetTexture(texCorner)
	surface.DrawTexturedRectRotated(wid * 0.5 - 16 - barw / 2, hei - 32, barw, 64, 90)
	surface.DrawTexturedRectRotated(wid * 0.5 + 16 + barw / 2, hei - 32, barw, 64, 180)
	surface.SetTexture(texDownEdge)
	surface.DrawTexturedRect(wid * 0.5 - 16, hei - 64, 32, 64)
end

function PANEL:GetPlayerPanel(pl)
	for _, panel in pairs(self.PlayerPanels) do
		if panel:Valid() and panel:GetPlayer() == pl then
			return panel
		end
	end
end

function PANEL:CreatePlayerPanel(pl)
	local panel = vgui.Create("ZSPlayerPanel", self.m_PanelListCanvas)
	panel:SetPlayer(pl)
	panel:SetSize(panel:GetParent():GetWide() / 2 - 32, 32)
	self.PlayerPanels[pl] = panel

	return panel
end

function PANEL:ArrangePanels(tab, mid)
	local y = 0
	for k, panel in ipairs(tab) do
		local x = mid - panel:GetWide() / 2
		panel:SetPos(x, y)

		y = y + panel:GetTall() + 2
	end

	return y
end

function PANEL:Refresh()
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	if self.PlayerPanels == nil then self.PlayerPanels = {} end

	for _, panel in pairs(self.PlayerPanels) do
		if not panel:Valid() then
			self:RemovePlayerPanel(panel)
		end
	end

	for _, pl in pairs(player.GetAll()) do
		if not self:GetPlayerPanel(pl) then
			self:CreatePlayerPanel(pl)
		end
	end

	local sortedhumans = {}
	local sortedzombies = {}
	for _, panel in pairs(self.PlayerPanels) do
		if panel:Valid() then
			local pl = panel:GetPlayer()
			if pl:IsValid() then
				if pl:Team() == TEAM_HUMAN then
					table.insert(sortedhumans, panel)
				else
					table.insert(sortedzombies, panel)
				end
			end
		end
	end
	table.sort(sortedhumans, self.PanelSort)
	table.sort(sortedzombies, self.PanelSort)

	local y = self:ArrangePanels(sortedhumans, self.m_PanelListCanvas:GetWide() * 0.25)
	y = math.max(y, self:ArrangePanels(sortedzombies, self.m_PanelListCanvas:GetWide() * 0.75))

	self.m_PanelListCanvas:SetTall(y)

	self.m_MaximumScroll = math.max(0, y - self.m_PanelList:GetTall())

	local _, scroll = self.m_PanelListCanvas:GetPos()
	scroll = -scroll
	if scroll > self.m_MaximumScroll then
		self.m_PanelListCanvas:SetPos(0, -self.m_MaximumScroll)
	end
end

function PANEL:RemovePlayerPanel(panel)
	if panel:Valid() then
		self.PlayerPanels[panel:GetPlayer()] = nil
		panel:Remove()
	end
end

vgui.Register("ZSScoreBoard", PANEL, "Panel")

local PANEL = {}

PANEL.RefreshTime = 3

PANEL.m_Player = NULL
PANEL.NextRefresh = 0

local function MuteDoClick(self)
	local pl = self:GetParent():GetPlayer()
	if pl:IsValid() then
		pl:SetMuted(not pl:IsMuted())
		self:GetParent().NextRefresh = RealTime()
	end
end

local function AvatarDoClick(self)
	local pl = self.PlayerPanel:GetPlayer()
	if pl:IsValid() and pl:IsPlayer() then
		pl:ShowProfile()
	end
end

local function empty() end

function PANEL:Init()
	self.m_AvatarButton = self:Add("DButton", self)
	self.m_AvatarButton:SetText(" ")
	self.m_AvatarButton:SetSize(32, 32)
	self.m_AvatarButton:Center()
	self.m_AvatarButton.DoClick = AvatarDoClick
	self.m_AvatarButton.Paint = empty
	self.m_AvatarButton.PlayerPanel = self

	self.m_Avatar = vgui.Create("AvatarImage", self.m_AvatarButton)
	self.m_Avatar:SetSize(32, 32)
	self.m_Avatar:SetVisible(false)
	self.m_Avatar:SetMouseInputEnabled(false)

	self.m_SpecialImage = vgui.Create("DImage", self)
	self.m_SpecialImage:SetSize(16, 16)
	self.m_SpecialImage:SetMouseInputEnabled(true)
	self.m_SpecialImage:SetVisible(false)

	self.m_ClassImage = vgui.Create("DImage", self)
	self.m_ClassImage:SetSize(22, 22)
	self.m_ClassImage:SetMouseInputEnabled(false)
	self.m_ClassImage:SetVisible(false)

	self.m_PlayerLabel = EasyLabel(self, " ", "ZSScoreBoardPlayer", COLOR_WHITE)
	self.m_ScoreLabel = EasyLabel(self, " ", "ZSScoreBoardPlayerSmall", COLOR_WHITE)

	self.m_PingMeter = vgui.Create("DPingMeter", self)
	self.m_PingMeter.PingBars = 5

	self.m_Mute = vgui.Create("DImageButton", self)
	self.m_Mute.DoClick = MuteDoClick
end

local colTemp = Color(255, 255, 255, 220)
function PANEL:Paint()
	local col = color_black_alpha220
	local mul = 0.5
	local pl = self:GetPlayer()
	if pl:IsValid() then
		col = team.GetColor(pl:Team())

		if pl:SteamID() == "STEAM_0:1:16889502" or pl:SteamID() == "STEAM_0:0:17321155" then
			mul = 0.6 + math.abs(math.sin(RealTime() * 6)) * 0.4
		elseif pl == MySelf then
			mul = 0.8
		end
	end

	if self.Hovered then
		mul = math.min(1, mul * 1.5)
	end

	colTemp.r = col.r * mul
	colTemp.g = col.g * mul
	colTemp.b = col.b * mul
	draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), colTemp)

	return true
end

function PANEL:DoClick()
	local pl = self:GetPlayer()
	if pl:IsValid() then
		gamemode.Call("ClickedPlayerButton", pl, self)
	end
end

function PANEL:PerformLayout()
	self.m_AvatarButton:AlignLeft(16)
	self.m_AvatarButton:CenterVertical()

	self.m_PlayerLabel:SizeToContents()
	self.m_PlayerLabel:MoveRightOf(self.m_AvatarButton, 4)
	self.m_PlayerLabel:CenterVertical()

	self.m_ScoreLabel:SizeToContents()
	self.m_ScoreLabel:SetPos((self:GetWide() - self.m_ScoreLabel:GetWide()) / 2, 0)
	self.m_ScoreLabel:CenterVertical()

	self.m_SpecialImage:CenterVertical()

	self.m_ClassImage:SetSize(self:GetTall(), self:GetTall())
	self.m_ClassImage:SetPos(self:GetWide() * 0.75 - self.m_ClassImage:GetWide() * 0.5, 0)
	self.m_ClassImage:CenterVertical()

	local pingsize = self:GetTall() - 4

	self.m_PingMeter:SetSize(pingsize, pingsize)
	self.m_PingMeter:AlignRight(8)
	self.m_PingMeter:CenterVertical()

	self.m_Mute:SetSize(16, 16)
	self.m_Mute:MoveLeftOf(self.m_PingMeter, 8)
	self.m_Mute:CenterVertical()
end

function PANEL:Refresh()
	local pl = self:GetPlayer()
	if not pl:IsValid() then
		self:Remove()
		return
	end

	local name = pl:Name()
	if #name > 26 then
		name = string.sub(name, 1, 24)..".."
	end
	self.m_PlayerLabel:SetText(name)
	self.m_ScoreLabel:SetText(pl:Frags())

	if pl:Team() == TEAM_UNDEAD and pl:GetZombieClassTable().Icon then
		self.m_ClassImage:SetVisible(true)
		self.m_ClassImage:SetImage(pl:GetZombieClassTable().Icon)
	else
		self.m_ClassImage:SetVisible(false)
	end

	if pl == LocalPlayer() then
		self.m_Mute:SetVisible(false)
	else
		if pl:IsMuted() then
			self.m_Mute:SetImage("icon16/sound_mute.png")
		else
			self.m_Mute:SetImage("icon16/sound.png")
		end
	end

	self:InvalidateLayout()
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:Refresh()
	end
end

function PANEL:SetPlayer(pl)
	self.m_Player = pl or NULL

	if pl:IsValid() and pl:IsPlayer() then
		self.m_Avatar:SetPlayer(pl)
		self.m_Avatar:SetVisible(true)

		if gamemode.Call("IsSpecialPerson", pl, self.m_SpecialImage) then
			self.m_SpecialImage:SetVisible(true)
		else
			self.m_SpecialImage:SetTooltip()
			self.m_SpecialImage:SetVisible(false)
		end
	else
		self.m_Avatar:SetVisible(false)
		self.m_SpecialImage:SetVisible(false)
	end

	self.m_PingMeter:SetPlayer(pl)

	self:Refresh()
end

function PANEL:GetPlayer()
	return self.m_Player
end

function PANEL:HasPriorityOver(b)
	local mypl = self:GetPlayer()
	local otherpl = b:GetPlayer()
	if mypl:IsValid() then
		if not otherpl:IsValid() then
			return true
		end

		local plteam = mypl:Team()
		local otherteam = otherpl:Team()
		if plteam ~= otherteam then
			return plteam < otherteam
		end

		local plfrags = mypl:Frags()
		local otherplfrags = otherpl:Frags()
		if plfrags ~= otherplfrags then
			return plfrags > otherplfrags
		end

		local pldeaths = mypl:Deaths()
		local otherpldeaths = otherpl:Deaths()
		if pldeaths ~= otherpldeaths then
			return pldeaths < otherpldeaths
		end

		return mypl:UserID() < otherpl:UserID()
	elseif otherpl:IsValid() then
		return false
	end

	return true
end

vgui.Register("ZSPlayerPanel", PANEL, "Button")
