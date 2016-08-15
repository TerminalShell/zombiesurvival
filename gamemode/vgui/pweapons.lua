local function WeaponButtonDoClick(self)
	local swep = self.SWEP
	if swep then
		pWeapons:SetWeaponViewerSWEP(self.SWEP)
	end
end

local function FeatureBar(displayname, value, min, max, inversebar)
	local panel = EasyLabel(nil, displayname..": "..value)
	return panel
end

local Features = {
{"WalkSpeed", "Movement speed"},
{"MeleeDamage", "Damage"},
{"MeleeRange", "Range"},
{"MeleeSize", "Size"},

{"ClipSize", "Clip size", 0, 50, false, "Primary"},
{"Damage", "Damage", 2, 100, false, "Primary"},
{"NumShots", "Number of shots", 1, 12, false, "Primary"},
{"Delay", "Rate of fire", 0.05, 3, true, "Primary"},

{"ConeMax", "Minimum accuracy"},
{"ConeMin", "Maximum accuracy"}
}

local function SetWeaponViewerSWEP(self, swep)
	if self.Viewer then
		if self.Viewer:Valid() then
			self.Viewer:Remove()
		end
		self.Viewer = nil
	end

	local wid, hei = self:GetWide() * 0.6 - 16, self:GetTall() - self.ViewerY - 8
	local halfwid = wid * 0.5

	local viewer = vgui.Create("DPanel", self)
	viewer:SetPaintBackground(false)
	viewer:SetSize(wid, hei)
	viewer:SetPos(self:GetWide() - viewer:GetWide() - 8, self.ViewerY)
	self.Viewer = viewer

	if not swep then return end

	local sweptable = weapons.GetStored(swep)
	if not sweptable then return end

	local y = 8

	local title = EasyLabel(viewer, sweptable.PrintName or swep, "ZSHUDFontSmall", COLOR_GRAY)
	title:SetPos(halfwid - title:GetWide() * 0.5, y)
	y = y + title:GetTall() + 8

	if sweptable.WorldModel then
		local bg = vgui.Create("DPanel", viewer)
		bg:SetSize(92, 92)
		bg:SetPos(halfwid - bg:GetWide() * 0.5, y)

		local modelpanel = vgui.Create("DModelPanelEx", bg)
		modelpanel:SetSize(bg:GetWide(), bg:GetTall())
		modelpanel:SetModel(sweptable.WorldModel)
		modelpanel:AutoCam()

		y = y + bg:GetTall() + 8
	end

	if sweptable.Description then
		local desc = EasyLabel(viewer, sweptable.Description)
		desc:SetPos(8, y)
		y = y + desc:GetTall() + 8
	end

	for i, featuretab in ipairs(Features) do
		local touse
		if featuretab[6] then
			touse = sweptable[ featuretab[6] ]
		else
			touse = sweptable
		end
		local value = touse[ featuretab[1] ]
		if value then
			local pan = FeatureBar(featuretab[2], value, featuretab[3], featuretab[4], featuretab[5])
			pan:SetParent(viewer)
			pan:SetPos(8, y)
			y = y + pan:GetTall() + 2
		end
	end
end

function MakepWeapons(silent)
	if not silent then
		PlayMenuOpenSound()
	end

	if pWeapons then
		pWeapons:SetAlpha(0)
		pWeapons:AlphaTo(255, 0.5, 0)
		pWeapons:SetVisible(true)
		pWeapons:MakePopup()
		return
	end

	local added = {}

	local weps = {}
	for _, tab in pairs(GAMEMODE.Items) do
		if tab.SWEP and not added[tab.SWEP] then
			weps[#weps + 1] = tab.SWEP
		end
	end

	local wid, hei = 600, 400

	local frame = vgui.Create("DFrame")
	frame:SetDeleteOnClose(false)
	frame:SetSize(wid, hei)
	frame:SetTitle(" ")
	frame:Center()
	frame.SetWeaponViewerSWEP = SetWeaponViewerSWEP
	pWeapons = frame

	local y = 8

	local title = EasyLabel(frame, "Weapon Database", "ZSHUDFont", color_white)
	title:SetPos(wid * 0.5 - title:GetWide() * 0.5, y)
	y = y + title:GetTall() + 8

	frame.ViewerY = y

	local tree = vgui.Create("DTree", frame)
	tree:SetSize(wid * 0.4 - 8, hei - y - 8)
	tree:SetPos(8, y)
	tree:SetIndentSize(4)
	frame.Tree = tree

	for _, wep in pairs(weps) do
		local enttab = weapons.GetStored(wep)
		local wepnode
		if enttab then
			wepnode = tree:AddNode(enttab.PrintName or wep)
		else
			wepnode = tree:AddNode(wep)
		end
		wepnode.SWEP = wep
		wepnode.DoClick = WeaponButtonDoClick
	end

	frame:SetWeaponViewerSWEP()

	MakepWeapons(true)
end
