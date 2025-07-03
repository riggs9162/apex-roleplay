apex.notify = apex.notify or {}
apex.notify.stored = apex.notify.stored or {}

surface.CreateFont("apex.notify", {
	font = "Bitstream Vera Sans",
	size = 16,
	weight = 2000,
	antialias = true
})

local color_panel_background = Color(230, 230, 230, 10)
local color_panel_foreground = Color(0, 0, 0, 230)
local color_panel_border = Color(0, 0, 0, 45)
local color_shadow = Color(0, 0, 0, 150)
local color_cyan = Color(0, 255, 255)

local PANEL = {}

function PANEL:Init()
	self:SetSize(256, 30)
	self:SetContentAlignment(5)
	self:SetExpensiveShadow(1, color_shadow)
	self:SetFont("apex.notify")
	self:SetTextColor(color_white)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(color_panel_background)
	surface.DrawRect(0, 0, width, height)

	if ( self.start ) then
		local widthFraction = math.TimeFraction(self.start, self.endTime, CurTime()) * width
		surface.SetDrawColor(color_panel_foreground)
		surface.DrawRect(0, 0, width, height)

		surface.SetDrawColor(color_white)
		surface.DrawRect(widthFraction, height - 2, width - widthFraction, 2)
	end

	surface.SetDrawColor(color_panel_border)
	surface.DrawOutlinedRect(0, 0, width, height)
end

vgui.Register("apex.notify", PANEL, "DLabel")

function apex.notify.Organize()
	local stored = apex.notify.stored
	if ( #stored == 0 ) then return end

	local scrW, scrH = ScrW(), ScrH()
	local scale2 = ScreenScale(2)
	local scale16 = ScreenScale(16)
	for k, v in ipairs(stored) do
		local wide = v:GetWide()
		local tall = v:GetTall()
		local i = k - 1 -- Index starts at 0 for calculations.
		v:MoveTo(scrW - wide, scrH - scale16 - ( k - i ) * ( tall + scale2 ) - i * ( tall + scale2 ), 0.15, (k / #stored) * 0.25, nil)
	end
end

function apex.notify.Send(message)
	local notice = vgui.Create("apex.notify")
	local i = table.insert(apex.notify.stored, notice)
	local scrW, scrH = ScrW(), ScrH()

	local scale4 = ScreenScale(4)
	local scale8 = ScreenScale(8)

	-- Set up information for the notice.
	notice:SetText(message)
	notice:SetPos(scrW, scrH - (i - 1) * (notice:GetTall() + scale4) + scale4)
	notice:SizeToContents()
	notice:SetSize(notice:GetWide() + scale8, notice:GetTall() + scale4)
	notice.start = CurTime() + 0.25
	notice.endTime = CurTime() + 7.75

	apex.notify.Organize()

	-- Show the notification in the console.
	MsgC(color_cyan, message .. "\n")

	-- Once the notice appears, make a sound and message.
	timer.Simple(0.15, function()
		surface.PlaySound("buttons/lightswitch2.wav")
	end)

	-- After the notice has displayed for 7.5 seconds, remove it.
	timer.Simple(7.75, function()
		if ( IsValid(notice) ) then
			-- Search for the notice to remove.
			for k, v in ipairs(apex.notify.stored) do
				if ( v == notice ) then
					-- Move the notice off the screen.
					notice:MoveTo(scrW, notice.y, 0.15, 0.1, nil, function()
						notice:Remove()
					end)

					-- Remove the notice from the list and move other apex.notify.stored.
					table.remove(apex.notify.stored, k)
					apex.notify.Organize()

					break
				end
			end
		end
	end)
end

local meta = FindMetaTable("Player")
function meta:Notify(message)
	apex.notify.Send(message)
end

net.Receive("apex.notify", function()
	local string = net.ReadString()
	apex.notify.Send(string)
end)