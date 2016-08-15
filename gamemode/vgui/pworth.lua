hook.Add("SetWave", "CloseWorthOnWave1", function(wave)
	if wave > 0 then
		if pWorth and pWorth:Valid() then
			pWorth:Close()
		end

		hook.Remove("SetWave", "CloseWorthOnWave1")
	end
end)

local cvarDefaultCart = CreateClientConVar("zs_defaultcart", "", true, false)

local function DefaultDoClick(btn)
	if cvarDefaultCart:GetString() == btn.Name then
		RunConsoleCommand("zs_defaultcart", "")
		surface.PlaySound("buttons/button11.wav")
	else
		RunConsoleCommand("zs_defaultcart", btn.Name)
		surface.PlaySound("buttons/button14.wav")
	end

	timer.Simple(0.1, MakepWorth)
end

local WorthRemaining = 0
local WorthButtons = {}
local function CartDoClick(self, silent, force)
	local id = self.ID
	local tab = FindStartingItem(id)
	if not tab then return end

	if self.On then
		self.On = nil
		self:SetImage("icon16/cart_add.png")
		if not silent then
			surface.PlaySound("buttons/button18.wav")
		end
		self:SetTooltip("Add to cart")
		WorthRemaining = WorthRemaining + tab.Worth
	else
		if WorthRemaining < tab.Worth and not force then
			surface.PlaySound("buttons/button8.wav")
			return
		end
		self.On = true
		self:SetImage("icon16/cart_delete.png")
		if not silent then
			surface.PlaySound("buttons/button17.wav")
		end
		self:SetTooltip("Remove from cart")
		WorthRemaining = WorthRemaining - tab.Worth
	end

	pWorth.WorthLab:SetText("Worth: ".. WorthRemaining)
	if WorthRemaining <= 0 then
		pWorth.WorthLab:SetTextColor(COLOR_RED)
	elseif WorthRemaining <= GAMEMODE.StartingWorth * 0.25 then
		pWorth.WorthLab:SetTextColor(COLOR_YELLOW)
	else
		pWorth.WorthLab:SetTextColor(COLOR_LIMEGREEN)
	end
	pWorth.WorthLab:SizeToContents()
end

local function Checkout(tobuy)
	if tobuy and #tobuy > 0 then
		gamemode.Call("SuppressArsenalUpgrades", 1)

		RunConsoleCommand("worthcheckout", unpack(tobuy))

		if pWorth and pWorth:Valid() then
			pWorth:Close()
		end
	else
		surface.PlaySound("buttons/combine_button_locked.wav")
	end
end

local function CheckoutDoClick(self)
	local tobuy = {}
	for _, btn in pairs(WorthButtons) do
		if btn and btn.On and btn.ID then
			table.insert(tobuy, btn.ID)
		end
	end

	Checkout(tobuy)
end

local function RandDoClick(self)
	gamemode.Call("SuppressArsenalUpgrades", 1)

	RunConsoleCommand("worthrandom")

	if pWorth and pWorth:Valid() then
		pWorth:Close()
	end
end

GM.SavedCarts = {}
hook.Add("Initialize", "LoadCarts", function()
	if file.Exists("FQD_ZS_carts.txt", "DATA") then
		GAMEMODE.SavedCarts = Deserialize(file.Read("FQD_ZS_carts.txt")) or {}
	end
end)

local function LoadCart(cartid, silent)
	if GAMEMODE.SavedCarts[cartid] then
		MakepWorth()
		for _, id in pairs(GAMEMODE.SavedCarts[cartid][2]) do
			for __, btn in pairs(WorthButtons) do
				if btn and (btn.ID == id or GAMEMODE.Items[id] and GAMEMODE.Items[id].Signature == btn.ID) then
					btn:DoClick(true, true)
				end
			end
		end
		if not silent then
			surface.PlaySound("buttons/combine_button1.wav")
		end
	end
end

local function LoadDoClick(self)
	LoadCart(self.ID)
end

local function SaveCurrentCart(name)
	local tobuy = {}
	for _, btn in pairs(WorthButtons) do
		if btn and btn.On and btn.ID then
			table.insert(tobuy, btn.ID)
		end
	end
	for i, cart in ipairs(GAMEMODE.SavedCarts) do
		if string.lower(cart[1]) == string.lower(name) then
			cart[1] = name
			cart[2] = tobuy

			file.Write("FQD_ZS_carts.txt", Serialize(GAMEMODE.SavedCarts))
			print("Saved cart "..tostring(name))

			LoadCart(i, true)
			return
		end
	end

	GAMEMODE.SavedCarts[#GAMEMODE.SavedCarts + 1] = {name, tobuy}

	file.Write("FQD_ZS_carts.txt", Serialize(GAMEMODE.SavedCarts))
	print("Saved cart "..tostring(name))

	LoadCart(#GAMEMODE.SavedCarts, true)
end

local function SaveDoClick(self)
	Derma_StringRequest("Save cart", "Enter a name for this cart.", "Name", 
	function(strTextOut) SaveCurrentCart(strTextOut) end,
	function(strTextOut) end,
	"OK", "Cancel")
end

local function DeleteDoClick(self)
	if GAMEMODE.SavedCarts[self.ID] then
		table.remove(GAMEMODE.SavedCarts, self.ID)
		file.Write("FQD_ZS_carts.txt", Serialize(GAMEMODE.SavedCarts))
		surface.PlaySound("buttons/button19.wav")
		MakepWorth()
	end
end

local function QuickCheckDoClick(self)
	if GAMEMODE.SavedCarts[self.ID] then
		Checkout(GAMEMODE.SavedCarts[self.ID][2])
	end
end

function MakepWorth()
	if pWorth and pWorth:Valid() then
		pWorth:Remove()
		pWorth = nil
	end

	local maxworth = GAMEMODE.StartingWorth
	WorthRemaining = maxworth

	local wid, hei = 480, 480

	local frame = vgui.Create("DFrame")
	pWorth = frame
	frame:SetSize(wid, hei)
	frame:SetDeleteOnClose(false)
	frame:SetKeyboardInputEnabled(false)
	frame:SetTitle("Choose your starting arsenal")

	local propertysheet = vgui.Create("DPropertySheet", frame)
	propertysheet:StretchToParent(4, 24, 4, 50)

	local list = vgui.Create("DPanelList", propertysheet)
	propertysheet:AddSheet("Favorites", list, "icon16/heart.png", false, false)
	list:EnableVerticalScrollbar(true)
	list:SetWide(propertysheet:GetWide() - 16)
	list:SetSpacing(2)
	list:SetPadding(2)

	local savebutton = EasyButton(nil, "Save the current cart", 0, 10)
	savebutton.DoClick = SaveDoClick
	list:AddItem(savebutton)

	local fontname
	local panhei
	if #GAMEMODE.SavedCarts >= 8 then
		panfont = "DefaultFontBold"
		panhei = 24
	else
		panfont = "ZSHUDFontSmall"
		panhei = 40
	end

	local defaultcart = cvarDefaultCart:GetString()

	for i, savetab in ipairs(GAMEMODE.SavedCarts) do
		local cartpan = vgui.Create("DPanel")
		cartpan:SetCursor("pointer")
		cartpan:SetSize(list:GetWide(), panhei)

		local cartname = savetab[1]

		local x = 8

		if defaultcart == cartname then
			local defimage = vgui.Create("DImage", cartpan)
			defimage:SetImage("icon16/heart.png")
			defimage:SizeToContents()
			defimage:SetMouseInputEnabled(true)
			defimage:SetTooltip("This is your default cart.\nIf you join the game late then you'll spawn with this cart.")
			defimage:SetPos(x, cartpan:GetTall() * 0.5 - defimage:GetTall() * 0.5)
			x = x + defimage:GetWide() + 4
		end

		local cartnamelabel = EasyLabel(cartpan, cartname, panfont)
		cartnamelabel:SetPos(x, cartpan:GetTall() * 0.5 - cartnamelabel:GetTall() * 0.5)

		x = cartpan:GetWide() - 20

		local checkbutton = vgui.Create("DImageButton", cartpan)
		checkbutton:SetImage("icon16/accept.png")
		checkbutton:SizeToContents()
		checkbutton:SetTooltip("Purchase this saved cart.")
		x = x - checkbutton:GetWide() - 4
		checkbutton:SetPos(x, cartpan:GetTall() * 0.5 - checkbutton:GetTall() * 0.5)
		checkbutton.ID = i
		checkbutton.DoClick = QuickCheckDoClick

		local loadbutton = vgui.Create("DImageButton", cartpan)
		loadbutton:SetImage("icon16/folder_go.png")
		loadbutton:SizeToContents()
		loadbutton:SetTooltip("Load this saved cart.")
		x = x - loadbutton:GetWide() - 4
		loadbutton:SetPos(x, cartpan:GetTall() * 0.5 - loadbutton:GetTall() * 0.5)
		loadbutton.ID = i
		loadbutton.DoClick = LoadDoClick

		local defaultbutton = vgui.Create("DImageButton", cartpan)
		defaultbutton:SetImage("icon16/heart.png")
		defaultbutton:SizeToContents()
		if cartname == defaultcart then
			defaultbutton:SetTooltip("Remove this cart as your default.")
		else
			defaultbutton:SetTooltip("Make this cart your default.")
		end
		x = x - defaultbutton:GetWide() - 4
		defaultbutton:SetPos(x, cartpan:GetTall() * 0.5 - defaultbutton:GetTall() * 0.5)
		defaultbutton.Name = cartname
		defaultbutton.DoClick = DefaultDoClick

		local deletebutton = vgui.Create("DImageButton", cartpan)
		deletebutton:SetImage("icon16/bin.png")
		deletebutton:SizeToContents()
		deletebutton:SetTooltip("Delete this saved cart.")
		x = x - deletebutton:GetWide() - 4
		deletebutton:SetPos(x, cartpan:GetTall() * 0.5 - loadbutton:GetTall() * 0.5)
		deletebutton.ID = i
		deletebutton.DoClick = DeleteDoClick

		list:AddItem(cartpan)
	end

	local isclassic = GAMEMODE:IsClassicMode()

	for catid, catname in ipairs(GAMEMODE.ItemCategories) do
		local list = vgui.Create("DPanelList", propertysheet)
		list:SetPaintBackground(false)
		propertysheet:AddSheet(catname, list, GAMEMODE.ItemCategoryIcons[catid], false, false)
		list:EnableVerticalScrollbar(true)
		list:SetWide(propertysheet:GetWide() - 16)
		list:SetSpacing(2)
		list:SetPadding(2)

		for i, tab in ipairs(GAMEMODE.Items) do
			if tab.Category == catid and tab.WorthShop then
				local itempan = vgui.Create("DPanel")
				itempan:SetSize(list:GetWide(), 40)
				list:AddItem(itempan)

				local mdlframe = vgui.Create("DPanel", itempan)
				mdlframe:SetSize(32, 32)
				mdlframe:SetPos(4, 4)

				local mdl = tab.Model or (weapons.GetStored(tab.SWEP) or tab).WorldModel
				if mdl then
					local mdlpanel = vgui.Create("DModelPanel", mdlframe)
					mdlpanel:SetSize(mdlframe:GetSize())
					mdlpanel:SetModel(mdl)
					local mins, maxs = mdlpanel.Entity:GetRenderBounds()
					mdlpanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
					mdlpanel:SetLookAt((mins + maxs) / 2)
				end

				if tab.SWEP or tab.Countables then
					local counter = vgui.Create("ItemAmountCounter", itempan)
					counter:SetItemID(i)
				end

				local namelab = EasyLabel(itempan, tab.Name or "", "ZSHUDFontSmall")
				namelab:SetPos(42, itempan:GetTall() * 0.5 - namelab:GetTall() * 0.5)

				local pricelab = EasyLabel(itempan, tostring(tab.Worth).." Worth", "ZSHUDFontTiny")
				pricelab:SetPos(itempan:GetWide() - 20 - pricelab:GetWide(), 4)

				local button = vgui.Create("DImageButton", itempan)
				button:SetImage("icon16/cart_add.png")
				button:SizeToContents()
				button:SetPos(itempan:GetWide() - 20 - button:GetWide(), itempan:GetTall() - button:GetTall() - 4)
				button:SetTooltip("Add to cart")
				button.ID = tab.Signature or i
				button.DoClick = CartDoClick
				WorthButtons[i] = button

				if tab.Description then
					itempan:SetTooltip(tab.Description)
				end

				if tab.NoClassicMode and isclassic then
					itempan:SetAlpha(120)
				end
			end
		end
	end

	local worthlab = EasyLabel(frame, "Worth: "..tostring(WorthRemaining), "ZSHUDFontSmall", COLOR_LIMEGREEN)
	worthlab:SetPos(8, frame:GetTall() - worthlab:GetTall() - 8)
	frame.WorthLab = worthlab

	local checkout = EasyButton(frame, "Checkout", 8, 4)
	checkout:SetPos(frame:GetWide() * 0.5 - checkout:GetWide() * 0.5, frame:GetTall() - checkout:GetTall() - 8)
	checkout.DoClick = CheckoutDoClick

	local rand = EasyButton(frame, "Random", 8, 4)
	rand:SetPos(frame:GetWide() - rand:GetWide() - 8, frame:GetTall() - rand:GetTall() - 8)
	rand.DoClick = RandDoClick

	if #GAMEMODE.SavedCarts == 0 then
		propertysheet:SetActiveTab(propertysheet.Items[math.min(2, #propertysheet.Items)].Tab)
	end

	frame:Center()
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.5, 0)
	frame:MakePopup()

	return frame
end

local PANEL = {}
PANEL.m_ItemID = 0
PANEL.RefreshTime = 1.5
PANEL.NextRefresh = 0

function PANEL:Init()
	self:SetFont("DefaultFontSmall")
end

function PANEL:Think()
	if CurTime() >= self.NextRefresh then
		self.NextRefresh = CurTime() + self.RefreshTime
		self:Refresh()
	end
end

function PANEL:Refresh()
	local count = GAMEMODE:GetCurrentEquipmentCount(self:GetItemID())
	if count == 0 then
		self:SetText(" ")
	else
		self:SetText(count)
	end

	self:SizeToContents()
end

function PANEL:SetItemID(id) self.m_ItemID = id end
function PANEL:GetItemID() return self.m_ItemID end

vgui.Register("ItemAmountCounter", PANEL, "DLabel")
