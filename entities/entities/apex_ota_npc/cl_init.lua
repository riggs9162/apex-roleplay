include("shared.lua")

local color_box_bg   						= Color(150, 150, 150, 100)
local color_button_error    				= Color(102, 9, 3, 230)
local color_button_error_highlighted 		= Color(102, 9, 3, 255)
local color_button_success  				= Color(9, 102, 3, 230)
local color_button_success_highlighted 		= Color(9, 102, 3, 255)
local color_frame_bg 						= Color(0, 0, 0, 200)
local color_halo     						= Color(0, 0, 255)
local color_panel_bg 						= Color(50, 50, 50, 150)
local color_topbar   						= Color(73, 147, 197, 150)

function ENT:Draw()
	self:DrawModel()
end

hook.Add("PreDrawHalos", "apex.overwatch.halo", function()
	local client = LocalPlayer()
	if ( client:Team() == TEAM_OVERWATCH ) then
		local entities = {}
		for _, ent in ipairs(ents.FindByClass("apex_ota_npc")) do
			if ( IsValid(ent) and ent:IsLineOfSightClear(client) ) then
				table.insert(entities, ent)
			end
		end

		halo.Add(entities, color_halo, 0, 0, 0)
	end
end)

local PANEL = {}

function PANEL:Init()
	if ( IsValid(apex.overwatch.panel) ) then
		apex.overwatch.panel:Close()
	end

	apex.overwatch.panel = self

	self:SetTitle("Overwatch Transhuman Arm - Rank and Division Selector")
	self:SetSize(ScrW() / 2.25, ScrH() / 3)
	self:Center()
	self:MakePopup()

	self.mainPanel = self:Add("Panel")
	self.mainPanel:Dock(FILL)

	self.topPanel = self.mainPanel:Add("Panel")
	self.topPanel:Dock(TOP)
	self.topPanel:DockMargin(10, 10, 10, 0)
	self.topPanel:SetTall(50)
	self.topPanel.Paint = function(this, width, height)
		draw.RoundedBox(0, 0, 0, width, height, color_panel_bg)
	end

	self.leftPanel = self.mainPanel:Add("Panel")
	self.leftPanel:Dock(LEFT)
	self.leftPanel:DockMargin(10, 10, 5, 10)
	self.leftPanel:SetWide(self:GetWide() * 0.4)
	self.leftPanel.Paint = function(this, width, height)
		draw.RoundedBox(0, 0, 0, width, height, color_panel_bg)
	end

	self.rightPanel = self.mainPanel:Add("Panel")
	self.rightPanel:Dock(RIGHT)
	self.rightPanel:DockMargin(5, 10, 10, 10)
	self.rightPanel:SetWide(self:GetWide() * 0.4)
	self.rightPanel.Paint = function(this, width, height)
		draw.RoundedBox(0, 0, 0, width, height, color_panel_bg)
	end

	self.centerPanel = self.mainPanel:Add("Panel")
	self.centerPanel:Dock(FILL)
	self.centerPanel:DockMargin(0, 10, 0, 10)
	self.centerPanel.Paint = nil

	self.rankBox = self.topPanel:Add("DDropListBox")
	self.rankBox:Dock(LEFT)
	self.rankBox:DockMargin(10, 10, 10, 10)
	self.rankBox:SetWide(self.leftPanel:GetWide() - 20)
	self.rankBox:SetTextColor(color_white)
	self.rankBox:SetValue("Choose a Rank")
	for k, v in ipairs(apex.overwatch.ranks) do
		self.rankBox:AddChoice(v.abbreviation .. " - " .. v.name, k)
	end
	self.rankBox.Paint = function(this, width, height)
		draw.RoundedBox(0, 0, 0, width, height, color_box_bg)
	end
	self.rankBox.OnSelect = function(panel, index, value, data)
		self.rank = data
		self:Update()
	end

	self.rankDescription = self.leftPanel:Add("DLabel")
	self.rankDescription:Dock(FILL)
	self.rankDescription:DockMargin(10, 5, 10, 40)
	self.rankDescription:SetText("")
	self.rankDescription:SetTextColor(color_white)
	self.rankDescription:SetWrap(true)
	self.rankDescription:SetAutoStretchVertical(true)

	self.rankRequirements = self.leftPanel:Add("DLabel")
	self.rankRequirements:Dock(BOTTOM)
	self.rankRequirements:DockMargin(10, 5, 10, 5)
	self.rankRequirements:SetText("")
	self.rankRequirements:SetTextColor(color_white)
	self.rankRequirements:SetWrap(true)
	self.rankRequirements:SetAutoStretchVertical(true)

	self.divisionBox = self.topPanel:Add("DDropListBox")
	self.divisionBox:Dock(RIGHT)
	self.divisionBox:DockMargin(10, 10, 10, 10)
	self.divisionBox:SetWide(self.rightPanel:GetWide() - 20)
	self.divisionBox:SetTextColor(color_white)
	self.divisionBox:SetValue("Choose a Division")
	for k, v in ipairs(apex.overwatch.divisions) do
		self.divisionBox:AddChoice(v.abbreviation .. " - " .. v.name, k)
	end
	self.divisionBox.Paint = function(this, width, height)
		draw.RoundedBox(0, 0, 0, width, height, color_box_bg)
	end
	self.divisionBox.OnSelect = function(panel, index, value, data)
		self.division = data
		self:Update()
	end

	self.divisionDescription = self.rightPanel:Add("DLabel")
	self.divisionDescription:Dock(TOP)
	self.divisionDescription:DockMargin(10, 5, 10, 40)
	self.divisionDescription:SetText("")
	self.divisionDescription:SetTextColor(color_white)
	self.divisionDescription:SetWrap(true)
	self.divisionDescription:SetAutoStretchVertical(true)

	self.divisionRequirements = self.rightPanel:Add("DLabel")
	self.divisionRequirements:Dock(BOTTOM)
	self.divisionRequirements:DockMargin(10, 5, 10, 5)
	self.divisionRequirements:SetText("")
	self.divisionRequirements:SetTextColor(color_white)
	self.divisionRequirements:SetWrap(true)
	self.divisionRequirements:SetAutoStretchVertical(true)

	self.icon = self.centerPanel:Add("DModelPanel")
	self.icon:Dock(FILL)
	self.icon:DockMargin(10, 10, 10, 10)
	self.icon:SetModel("models/player/soldier_stripped.mdl")
	self.icon.Entity.GetPlayerColor = function()
		return vector_origin
	end

	local headpos = self.icon.Entity:GetBonePosition(self.icon.Entity:LookupBone("ValveBiped.Bip01_Head1"))
	self.icon:SetLookAt(headpos + Vector(0, 0, -28))
	self.icon:SetCamPos(headpos + Vector(192, 0, -16))
	self.icon:SetFOV(14)
	self.icon.LayoutEntity = function(this, entity)
		this:RunAnimation()
	end

	self.become = self:Add("DButton")
	self.become:Dock(BOTTOM)
	self.become:DockMargin(10, 0, 10, 10)
	self.become:SetFont("NameFont")
	self.become:SetText("Choose Rank and Division")
	self.become:SetTextColor(color_white)
	self.become:SetTall(30)
	self.become.Paint = function(this, width, height)
		local hovering = this:IsHovered()
		local color = hovering and color_button_error_highlighted or color_button_error
		if ( self.rank and self.division ) then
			color = hovering and color_button_success_highlighted or color_button_success
		end

		draw.RoundedBox(0, 0, 0, width, height, color)
	end
	self.become.DoClick = function()
		if ( self.rank and self.division ) then
			net.Start("apex.overwatch.select")
				net.WriteUInt(self.rank, 8)
				net.WriteUInt(self.division, 8)
			net.SendToServer()

			self:Close()
		end
	end

	self:Update()
end

function PANEL:Update()
	local rankData = apex.overwatch.ranks[self.rank]
	if ( rankData ) then
		self.rankDescription:SetText(rankData.description or "")

		if ( rankData.roguePerms ) then
			self.rankDescription:SetText(self.rankDescription:GetText() .. "\n\n-- You are permitted to become a rogue unit with this rank. --")
		else
			self.rankDescription:SetText(self.rankDescription:GetText() .. "\n\n-- You are not permitted to become a rogue unit with this rank! --")
		end

		self.rankRequirements:SetText("XP Requirement: " .. (rankData.xp or "N/A"))

		if ( rankData.max and rankData.max > 0 ) then
			self.rankRequirements:SetText(self.rankRequirements:GetText() .. "\nMax Units: " .. rankData.max)
		end
	end

	local divisionData = apex.overwatch.divisions[self.division]
	if ( divisionData ) then
		self.divisionDescription:SetText(divisionData.description or "")

		if ( divisionData.roguePerms ) then
			self.divisionDescription:SetText(self.divisionDescription:GetText() .. "\n\n-- You are permitted to become a rogue unit with this division. --")
		else
			self.divisionDescription:SetText(self.divisionDescription:GetText() .. "\n\n-- You are not permitted to become a rogue unit with this division! --")
		end

		self.divisionRequirements:SetText("XP Requirement: " .. (divisionData.xp or "N/A"))

		if ( divisionData.max and divisionData.max > 0 ) then
			self.divisionRequirements:SetText(self.divisionRequirements:GetText() .. "\nMax Units: " .. divisionData.max)
		end

		self.icon:SetModel(divisionData.model or "models/player/soldier_stripped.mdl")
		self.icon.Entity:SetSkin(divisionData.skin or 0)
	end

	if ( rankData and self.division == DIVISION_OWC ) then
		self.become:SetText("Choose Division (" .. (divisionData.abbreviation or "") .. ")")
	elseif ( rankData and divisionData ) then
		self.become:SetText("Choose Rank (" .. (rankData.abbreviation or "") .. ") and Division (" .. (divisionData.abbreviation or "") .. ")")
	elseif ( !rankData and !divisionData ) then
		self.become:SetText("Choose Rank and Division")
	elseif ( rankData and !divisionData ) then
		self.become:SetText("Now choose a Division")
	elseif ( !rankData and divisionData ) then
		self.become:SetText("Now choose a Rank")
	end
end

function PANEL:Paint(width, height)
	draw.RoundedBox(0, 0, 0, width, height, color_frame_bg)
	draw.RoundedBox(0, 0, 0, width, 25, color_topbar)
end

vgui.Register("apex.overwatch.menu", PANEL, "DFrame")

net.Receive("apex.overwatch.menu", function()
	vgui.Create("apex.overwatch.menu")
end)

if ( IsValid(apex.overwatch.panel) ) then
	apex.overwatch.panel:Close()

	vgui.Create("apex.overwatch.menu")
end