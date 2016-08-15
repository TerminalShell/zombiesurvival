local PANEL = {}

function PANEL:Init()
	self.m_HumanCount = vgui.Create("DTeamCounter", self)
	self.m_HumanCount:SetTeam(TEAM_HUMAN)
	self.m_HumanCount:SetImage("zombiesurvival/humanhead")

	self.m_ZombieCount = vgui.Create("DTeamCounter", self)
	self.m_ZombieCount:SetTeam(TEAM_UNDEAD)
	self.m_ZombieCount:SetImage("zombiesurvival/zombiehead")

	self.m_Text1 = vgui.Create("DLabel", self)
	self.m_Text2 = vgui.Create("DLabel", self)
	self.m_Text3 = vgui.Create("DLabel", self)
	self.m_Text4 = vgui.Create("DLabel", self)
	self:SetTextFont("ZSHUDFontTiny")
	self:SetTextFont2("ZSHUDFontTiny")

	self.m_Text1.Paint = self.Text1Paint
	self.m_Text2.Paint = self.Text2Paint
	self.m_Text3.Paint = self.Text3Paint
	self.m_Text4.Paint = self.Text4Paint

	self:InvalidateLayout()
end

function PANEL:SetTextFont(font)
	self.m_Text1.Font = font
	self.m_Text1:SetFont(font)
	self.m_Text2.Font = font
	self.m_Text2:SetFont(font)
	self.m_Text3.Font = font
	self.m_Text3:SetFont(font)

	self:InvalidateLayout()
end

function PANEL:SetTextFont2(font)
	self.m_Text4.Font = font
	self.m_Text4:SetFont(font)

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	local hs = self:GetTall() * 0.43
	self.m_HumanCount:SetSize(hs, hs)
	self.m_ZombieCount:SetSize(hs, hs)
	self.m_ZombieCount:AlignTop(hs)

	self.m_Text1:SetWide(self:GetWide())
	self.m_Text1:SizeToContentsY()
	self.m_Text1:MoveRightOf(self.m_HumanCount, 10)
	self.m_Text1:AlignTop(4)
	
	self.m_Text2:SetWide(self:GetWide())
	self.m_Text2:SizeToContentsY()
	self.m_Text2:MoveRightOf(self.m_HumanCount, 10)
	self.m_Text2:MoveBelow(self.m_Text1, 1)
	
	self.m_Text3:SetWide(self:GetWide())
	self.m_Text3:SizeToContentsY()
	self.m_Text3:MoveRightOf(self.m_HumanCount, 10)
	self.m_Text3:MoveBelow(self.m_Text2, 1)
	
	self.m_Text4:SetWide(self:GetWide())
	self.m_Text4:SizeToContentsY()
	self.m_Text4:MoveRightOf(self.m_HumanCount, 10)
	self.m_Text4:MoveBelow(self.m_Text3)
end

function PANEL:Text1Paint()
	local text
	local override = MYSELFVALID and GetGlobalString("hudoverride"..MySelf:Team(), "")

	if override and #override > 0 then
		text = override
	else
		local wave = GAMEMODE:GetWave()
		if wave <= 0 then
			text = translate.Get("prepare_yourself")
		else
			local maxwaves = GAMEMODE:GetNumberOfWaves()
			if maxwaves ~= -1 then
				if GAMEMODE:GetWaveActive() then
					text = "Wave ".. wave .. " of ".. maxwaves
				else
					text = "Intermission - Wave ".. wave .. " of ".. maxwaves
				end
			elseif not GAMEMODE:GetWaveActive() then
				text = "Intermission"
			end
		end
	end

	if text then
		draw.SimpleText(text, self.Font, 0, 0, COLOR_WHITE)
	end

	return true
end

function PANEL:Text2Paint()
	if GAMEMODE:GetWave() <= 0 then
		local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())
		if timeleft < 10 then
			local glow = math.sin(RealTime() * 8) * 200 + 255
			draw.SimpleText("Zombie invasion in "..util.ToMinutesSeconds(timeleft), self.Font, 0, 0, Color(255, glow, glow))
		else
			draw.SimpleText("Zombie invasion in "..util.ToMinutesSeconds(timeleft), self.Font, 0, 0, COLOR_WHITE)
		end
	elseif GAMEMODE:GetWaveActive() then
		local waveend = GAMEMODE:GetWaveEnd()
		if waveend ~= -1 then
			local timeleft = math.max(0, waveend - CurTime())
			draw.SimpleText("Wave ends in "..util.ToMinutesSeconds(timeleft), self.Font, 0, 0, 10 < timeleft and COLOR_WHITE or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	else
		local wavestart = GAMEMODE:GetWaveStart()
		if wavestart ~= -1 then
			local timeleft = math.max(0, wavestart - CurTime())
			draw.SimpleText("Next wave in "..util.ToMinutesSeconds(timeleft), self.Font, 0, 0, 10 < timeleft and COLOR_WHITE or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	end

	return true
end

function PANEL:Text3Paint()
	if MYSELFVALID then
		if MySelf:Team() == TEAM_UNDEAD then
			local toredeem = GAMEMODE:GetRedeemBrains()
			if toredeem > 0 then
				draw.SimpleText("Brains eaten: "..MySelf:Frags().." / "..toredeem, self.Font, 0, 0, COLOR_RED)
			else
				draw.SimpleText("Brains eaten: "..MySelf:Frags(), self.Font, 0, 0, COLOR_RED)
			end
		else
			draw.SimpleText("Points: "..MySelf:GetPoints().." / "..MySelf:Frags(), self.Font, 0, 0, COLOR_RED)
		end
	end
	
	return true
end

function PANEL:Text4Paint()
	if MYSELFVALID then
		if MySelf:Team() == TEAM_HUMAN then
			local p = MySelf:GetPoints()
			local wutnext = 0
			for k,v in pairs(GAMEMODE.Wut) do
				if v > p then wutnext = v break end
			end
			local autnext = 0
			for k,v in pairs(GAMEMODE.Aut) do
				if v > p then autnext = v break end
			end
			local putnext = 0
			for k,v in pairs(GAMEMODE.Put) do
				if v > p then putnext = v break end
			end
			if math.Max(wutnext,autnext,putnext) > 0 then
				local mode = nil
				local goal = 0
				if wutnext > 0 and (autnext > 0 and wutnext < autnext) and (putnext > 0 and wutnext < putnext) then
					mode = "Weapon"
					goal = wutnext
				elseif autnext > 0 and (wutnext > 0 and autnext < wutnext) and (putnext > 0 and autnext < putnext) then
					mode = "Ammo"
					goal = autnext
				elseif putnext > 0 and (wutnext > 0 and putnext < wutnext) and (autnext > 0 and putnext < autnext) then
					mode = "Powerup"
					goal = putnext
				else
					return true
				end
				draw.SimpleText(mode.." in: "..(goal-p).." Points", self.Font, 0, 0, COLOR_WHITE)
			end
		end
	end
	
	return true
end

function PANEL:Paint()
	return true
end

vgui.Register("DGameState", PANEL, "DPanel")
