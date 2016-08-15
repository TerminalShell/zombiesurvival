local PANEL = {}

PANEL.m_Team = 0

PANEL.NextRefresh = 0

function PANEL:Init()
	self.m_Image = vgui.Create("DImage", self)
	self.m_Image:SetImage("icon16/check_off.png")

	self.m_Counter = vgui.Create("DLabel", self)
	self.m_Counter:SetFont("ZSHUDFontSmaller")

	self:Refresh()
end

function PANEL:Paint()
	return true
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + 1
		self:Refresh()
	end
end

function PANEL:SetTeam(teamid)
	self.m_Team = teamid
	self.m_Counter:SetTextColor(team.GetColor(teamid) or color_white)
end

function PANEL:SetImage(mat)
	self.m_Image:SetImage(mat)

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.m_Image:SetSize(self:GetSize())
	self.m_Counter:AlignBottom()
	self.m_Counter:AlignRight()
end

function PANEL:Refresh()
	self.m_Counter:SetText(team.NumPlayers(self.m_Team))
	self.m_Counter:SizeToContents()

	self:InvalidateLayout()
end

vgui.Register("DTeamCounter", PANEL, "DPanel")
