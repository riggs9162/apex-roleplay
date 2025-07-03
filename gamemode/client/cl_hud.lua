local HUDHeightBase = 115
local HUDHeight = HUDHeightBase
local HUDWidthBase = 260
local HUDWidth = HUDWidthBase
local color_background = Color(0, 0, 0, 230)

local function CalculateHudSize()
	local client = LocalPlayer()
	local teamName = "Job: " .. ( client:GetDarkRPVar("job") or team.GetName(client:Team()) or "Unknown" )
	local clientName = "Name: " .. client:Nick()

	surface.SetFont("NameFont")
	local teamWidth = surface.GetTextSize(teamName) + 40
	local clientWidth = surface.GetTextSize(clientName) + 40

	HUDWidth = math.max(HUDWidthBase, teamWidth, clientWidth)
	HUDHeight = HUDHeightBase
end

hook.Add("OnScreenSizeChanged", "CalculateHudSize", function()
	CalculateHudSize()
end)

local lastName = ""
hook.Add("Think", "CalculateHudSize", function()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end
	if ( client:Team() <= 0 ) then return end
	if ( client:Nick() == lastName ) then return end

	lastName = client:Nick()
	CalculateHudSize()
end)

local RelativeX, RelativeY
local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local scrW, scrH = ScrW(), ScrH()

	if ( client.DRPIsTalking ) then
		local chboxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime() * "3")
		local backwards = 0
		if ( Rotating < 0 ) then
			Rotating = 1 - ( 1 + Rotating )
			backwards = 180
		end

		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRectRotated(scrW - 100, chboxY, Rotating * 96, 96, backwards)
	end
end

local function DrawLockDown()
	local scrW, scrH = ScrW(), ScrH()
	local width, height = scrW / 8, 30
	local x, y = scrW / 2 - width / 2, scrH - height - 10

	if ( GetGlobalBool("jw", false) ) then
		draw.RoundedBox(0, x, y, width, height, color_background)
		draw.SimpleText("Judgement Waiver in progress!", "NameFont", x + width / 2, y + height / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ( GetGlobalBool("lockdown", false) ) then
		draw.RoundedBox(0, x, y, width, height, color_background)
		draw.SimpleText("Lockdown in progress!", "NameFont", x + width / 2, y + height / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		local client = LocalPlayer()
		if ( !IsValid(client) ) then return end

		if CurTime() - StartArrested <= ArrestedUntil and client:GetDarkRPVar("Arrested") then
		draw.DrawText(apex.language.GetPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD2", ScrW()/2, ScrH() - ScrH()/12, Color(color_white,255), 1)
		elseif not client:GetDarkRPVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

net.Receive("apex.admin.tell.all", function()
	local scrW, scrH = ScrW(), ScrH()
	local width, height = scrW / 2 - 20, 20
	local x, y = scrW / 2 - width / 2, 10

	local message = net.ReadString()
	local wrapped = GAMEMODE:GetWrappedText(message, "ChatFont", width - 20)
	local titleHeight = draw.GetFontHeight("GModToolName")
	local textHeight = draw.GetFontHeight("ChatFont")
	height = height + titleHeight + #wrapped * textHeight

	AdminTell = function()
		draw.RoundedBox(0, x, y, width, height, color_background)
		draw.SimpleText(apex.language.GetPhrase("listen_up"), "GModToolName", x + width / 2, y + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		for i, line in ipairs(wrapped) do
			draw.SimpleText(line, "ChatFont", x + width / 2, y + titleHeight + 10 + (i - 1) * textHeight, Color(200, 30, 30, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	local time = string.len(message) / 20 + 5
	timer.Simple(time, function()
		AdminTell = function() end
	end)
end)

DermaShown = nil

local function DrawPlayerModel()
	if !DermaShown then
		if IsValid(PlayerIcon) then
			PlayerIcon:Remove()
		end
		
		PlayerIcon = vgui.Create("SpawnIcon")
		PlayerIcon:SetPos( 25, ScrH() - 125 )
		PlayerIcon:SetSize(60, 60)
		PlayerIcon:SetToolTip("")
		PlayerIcon:SetModel(LocalPlayer():GetModel())

		DermaShown = true

	end
	PlayerIcon:SetModel(LocalPlayer():GetModel() or "models/noesis/doapex.mdl")
end

local function DrawInfo()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	if not HL2RP_texCache then HL2RP_texCache = {} end
	if not HL2RP_texCache["SilkUser"] then HL2RP_texCache["SilkUser"] = Material("icon16/user.png") end
	if not HL2RP_texCache["SilkShield"] then HL2RP_texCache["SilkShield"] = Material("icon16/shield.png") end
	if not HL2RP_texCache["SilkJob"] then HL2RP_texCache["SilkJob"] = Material("icon16/group.png") end
	if not HL2RP_texCache["SilkHeart"] then HL2RP_texCache["SilkHeart"] = Material("icon16/heart.png") end
	if not HL2RP_texCache["SilkMoney"] then HL2RP_texCache["SilkMoney"] = Material("icon16/money.png") end
	if not HL2RP_texCache["SilkSalary"] then HL2RP_texCache["SilkSalary"] = Material("icon16/money_add.png") end
	if not HL2RP_texCache["StrawberryIcon"] then HL2RP_texCache["StrawberryIcon"] = Material("hl2rp/strawberryicon.vtf") end
	if not HL2RP_texCache["SilkWarning"] then HL2RP_texCache["SilkWarning"] = Material("icon16/exclamation.png") end

	surface.SetDrawColor(color_white)
	surface.SetMaterial(HL2RP_texCache["SilkUser"])
	surface.DrawTexturedRect(18,ScrH() - 173,16,16)
	draw.DrawText("Name: " .. client:Nick(), "NameFont", RelativeX + 40, RelativeY - HUDHeight - 57, color_white, 0)


	local job = client:GetDarkRPVar("job") or ""
	local money = client:GetDarkRPVar("money") or ""
	if client:GetDarkRPVar("Energy") then
		energy = math.Round(client:GetDarkRPVar("Energy")) or 0
	else
		energy = 0
	end

	local salery = client:GetDarkRPVar("salary") or 0
	surface.SetDrawColor(color_white)
	surface.SetMaterial(HL2RP_texCache["SilkJob"])
	surface.DrawTexturedRect(18,ScrH() - 31,16,16)
	draw.DrawText("Job: " .. job, "NameFont", RelativeX + 40, RelativeY - HUDHeight + 85, color_white, 0)

	surface.SetMaterial(HL2RP_texCache["SilkHeart"])
	surface.DrawTexturedRect( RelativeX + 100,ScrH() - 140,16,16)
	draw.DrawText("Health: " .. client:Health() or "", "NameFont", RelativeX + 125, ScrH() - 140, color_white, 0)

	surface.SetMaterial(HL2RP_texCache["SilkShield"])
	surface.DrawTexturedRect( RelativeX + 100,ScrH() - 120,16,16)
	draw.DrawText("Armour: " .. client:Armor() or "", "NameFont", RelativeX + 125, ScrH() - 120, color_white, 0)

	surface.SetMaterial(HL2RP_texCache["SilkMoney"])
	surface.DrawTexturedRect( RelativeX + 100,ScrH() - 100,16,16)
	draw.DrawText("Tokens: " .. "T" .. money or 0, "NameFont", RelativeX + 125, ScrH() - 100, color_white, 0)

	surface.SetMaterial(HL2RP_texCache["SilkSalary"])
	surface.DrawTexturedRect( RelativeX + 100,ScrH() - 80,16,16)
	draw.DrawText("Salary: " .. "T" .. salery, "NameFont", RelativeX + 125, ScrH() - 80, color_white, 0)

	surface.SetMaterial(HL2RP_texCache["StrawberryIcon"])
	surface.DrawTexturedRect( RelativeX + 100,ScrH() - 60,16,16)
	draw.DrawText("Food: " .. energy .. "%", "NameFont", RelativeX + 125, ScrH() - 60, color_white, 0)


end

local function DrawWarningBox(weaponName)
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local scrW, scrH = ScrW(), ScrH()
	draw.RoundedBox(0, 10, scrH - HUDHeight - 136, HUDWidth, 70, Color(40, 0, 0, 240))

	surface.SetDrawColor(color_white)
	surface.SetMaterial(HL2RP_texCache["SilkWarning"])
	surface.DrawTexturedRect(RelativeX + 10 + 8, scrH - 220, 16, 16)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(HL2RP_texCache["SilkWarning"])
	surface.DrawTexturedRect(RelativeX + HUDWidth + 10 - 16 - 8, scrH - 220, 16, 16)

	draw.DrawText("You should only use the " .. weaponName .. "\nwhile building. Using it in a RP\nsituation is FailRP and punishable.", "NameFont", RelativeX + 10 + HUDWidth / 2, RelativeY - 237.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawWarning()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local weapon = client:GetActiveWeapon()
	if ( !IsValid(weapon) ) then return end

	if ( client:Alive() and IsValid(weapon) and weapon:GetClass() == "weapon_physgun" ) then
		DrawWarningBox("physgun")
	elseif ( client:Alive() and IsValid(weapon) and weapon:GetClass() == "gmod_tool" ) then
		DrawWarningBox("tool gun")
	elseif ( client:Alive() and IsValid(weapon) and weapon:GetClass() == "weapon_physcannon" ) then
		DrawWarningBox("gravity gun")
	end
end

local function DrawSide()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local scrW, scrH = ScrW(), ScrH()
	local xp = client:GetXP() or 0

	draw.RoundedBox(0, scrW - 120, 80, 140, 30, Color( 0, 0, 0, 230 ) )
	draw.DrawText("XP: " .. xp, "NameFont", scrW - 110, 87, color_white, 0)

	draw.RoundedBox(0, scrW - 120, 120, 140, 50, Color( 0, 0, 0, 230 ) )
	draw.DrawText("Time: " .. os.date( "%H:%M" ), "NameFont", scrW - 110, 127, color_white, 0)
	local ICTime = StormFox2 and StormFox2.Time and StormFox2.Time.GetDisplay and StormFox2.Time.GetDisplay() or "N/A"
	draw.DrawText("IC-Time: " .. ICTime, "NameFont", scrW - 110, 147, color_white, 0)
end

net.Receive("apex.time", function()
	STime = net.ReadString() or ""
end)

local function DrawDoubleXPNotice(client)
	local amount = 10
	local usergroup = client:GetUserGroup()
	if ( usergroup == "vip" or usergroup == "superadmin" or usergroup == "admin" or usergroup == "moderator" ) then
		amount = 20
	end

	local text = "Double XP is currently active! You will receive " .. amount .. " XP for every 10 minutes played!"
	surface.SetFont("DermaDefaultBold")
	local textWidth = surface.GetTextSize(text)

	draw.RoundedBox(2, 10, 10, textWidth + 20, 30, Color(0, 0, 0, 230))

	local x = 20
	for i = 1, #text do
		local char = text:sub(i, i)
		local hue = (CurTime() * 20 + i * 8) % 360
		local color = HSVToColor(hue, 0.5, 0.8)
		surface.SetFont("DermaDefaultBold")
		local w, h = surface.GetTextSize(char)
		draw.SimpleText(char, "DermaDefaultBold", x, 20, color, TEXT_ALIGN_LEFT)
		x = x + w
	end
end

local function DrawHUD()
	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_HUD")
	if ( shouldDraw == false ) then return end

	scrW, scrH = ScrW(), ScrH()
	RelativeX, RelativeY = 0, scrH

	-- Background
	draw.RoundedBox(0, 10, scrH - HUDHeight - 65, HUDWidth, 30, color_background)
	draw.RoundedBox(0, 10, scrH - HUDHeight - 34, HUDWidth, 110, color_background)
	draw.RoundedBox(0, 10, scrH - HUDHeight + 77, HUDWidth, 30, color_background)

	-- Double XP Notice
	if ( apex.xp.double:GetBool() ) then
		DrawDoubleXPNotice(client)
	end

	DrawInfo()
	DrawWarning()
	DrawPlayerModel()
	DrawVoiceChat()
	DrawLockDown()

	Arrested()
	AdminTell()

	DrawSide()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
local function DrawPlayerInfo(client)
	local pos = client:EyePos()

	pos.z = pos.z + 5 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text

	if GAMEMODE.Config.showname and not client:GetDarkRPVar("wanted") and client:GetNoDraw() == true then return else
		draw.DrawText(client:Nick(), "TargetID", pos.x, pos.y, team.GetColor(client:Team()), 1)
	end

	if client:Health() < 35 then
		draw.DrawText("Seriously injured", "DermaDefaultBold", pos.x + 1, pos.y + 12, Color(204, 0, 0, 255), 1)        
		elseif client:Health() < 70 then
		draw.DrawText("Injured", "DermaDefaultBold", pos.x + 1, pos.y + 12, Color(255, 153, 51, 255), 1)
	end

	if client:GetDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(color_white,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
	if shouldDraw == false then return end

	local client = LocalPlayer()
	if ( !IsValid(client) ) then return end

	local shootPos = client:GetShootPos()
	local aimVec = client:GetAimVector()

	for k, v in player.Iterator() do
		if not v:Alive() then continue end
		local hisPos = v:GetShootPos()
		if v:GetDarkRPVar("wanted") then DrawWantedInfo(v) end

		if GAMEMODE.Config.globalshow and v != client then
			DrawPlayerInfo(v)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:Distance(shootPos) < 400 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, client)
				if trace.Hit and trace.Entity != v then return end
				if not v:FAdmin_GetGlobal("FAdmin_cloaked") then
					DrawPlayerInfo(v)
				end
			end
		end
	end

	local tr = client:GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:IsOwnable() and tr.Entity:GetPos():Distance(client:GetPos()) < 200 then
		tr.Entity:DrawOwnableInfo()
	end
end

usermessage.Hook("KilledBy", function(data)
	deathcause = data:ReadString() or ""
end)

local function DrawDead()
	local scrW, scrH = ScrW(), ScrH()
	local width, height = scrW / 6, scrH / 10
	local x, y = scrW / 2 - width / 2, scrH / 1.75 - height / 2

	if ( !deathcause ) then
		deathcause = ""
	end

	if ( !LocalPlayer():Alive() ) then
		if ( !spawntime ) then
			spawntime = 30
		end

		draw.RoundedBox(0, 0, 0, scrW, scrH, Color(10,10,10,200))
		draw.RoundedBox(0, x, y, width, height, Color(0, 0, 0, 252))

		draw.DrawText("YOU ARE DEAD!", "DermaLarge", x + width / 2, y + height / 4, color_white,TEXT_ALIGN_CENTER)
		draw.DrawText("You were killed by " .. deathcause, "DermaDefault", x + width / 2, y + height / 4 + 35, color_white,TEXT_ALIGN_CENTER)

		if ( spawntime <= 0 ) then
			draw.DrawText("Click your mouse to respawn", "DermaDefault", x + width / 2, y + height / 4 + 55, color_white,TEXT_ALIGN_CENTER)
		else
			draw.DrawText("You are able to respawn in " .. string.NiceTime(spawntime), "DermaDefault", x + width / 2, y + height / 4 + 55, color_white,TEXT_ALIGN_CENTER)
		end
	end
end

hook.Add("HUDShouldDraw", "apex.hud.hide", function(name)
	if ( name == "CHudCrosshair" ) then
		return false
	end

	if ( name == "CHudDamageIndicator" ) then
		if ( !LocalPlayer():Alive() ) then
			return false
		else
			return true
		end
	end
end)

function DrawScanner(entity)
	local PICTURE_WIDTH, PICTURE_HEIGHT = 580, 420
	local PICTURE_WIDTH2, PICTURE_HEIGHT2 = PICTURE_WIDTH * 0.5, PICTURE_HEIGHT * 0.5

	local view = {}
	local zoom = 0
	local deltaZoom = zoom
	local nextClick = 0

	local scrW, scrH = surface.ScreenWidth() * 0.5, surface.ScreenHeight() * 0.5
			local x, y = scrW - PICTURE_WIDTH2, scrH - PICTURE_HEIGHT2

			local position = entity:GetPos()
			local angle = LocalPlayer():GetAimVector():Angle()

			draw.SimpleText("POS ("..math.floor(position[1])..", "..math.floor(position[2])..", "..math.floor(position[3])..")", "nutScannerFont", x + 8, y + 8, color_white)
			draw.SimpleText("ANG ("..math.floor(angle[1])..", "..math.floor(angle[2])..", "..math.floor(angle[3])..")", "nutScannerFont", x + 8, y + 24, color_white)
			draw.SimpleText("ID  ("..LocalPlayer():Name()..")", "nutScannerFont", x + 8, y + 40, color_white)
		--	draw.SimpleText("ZM  ("..(math.Round(zoom / 40, 2) * 100).."%)", "nutScannerFont", x + 8, y + 56, color_white)

			surface.SetDrawColor(235, 235, 235, 230)

			surface.DrawLine(0, scrH, x - 128, scrH)
			surface.DrawLine(scrW + PICTURE_WIDTH2 + 128, scrH, ScrW(), scrH)
			surface.DrawLine(scrW, 0, scrW, y - 128)
			surface.DrawLine(scrW, scrH + PICTURE_HEIGHT2 + 128, scrW, ScrH())

			surface.DrawLine(x, y, x + 128, y)
			surface.DrawLine(x, y, x, y + 128)
--
			x = scrW + PICTURE_WIDTH2

			surface.DrawLine(x, y, x - 128, y)
			surface.DrawLine(x, y, x, y + 128)

			x = scrW - PICTURE_WIDTH2
			y = scrH + PICTURE_HEIGHT2

			surface.DrawLine(x, y, x + 128, y)
			surface.DrawLine(x, y, x, y - 128)

			x = scrW + PICTURE_WIDTH2

			surface.DrawLine(x, y, x - 128, y)
			surface.DrawLine(x, y, x, y - 128)

			surface.DrawLine(scrW - 48, scrH, scrW - 8, scrH)
			surface.DrawLine(scrW + 48, scrH, scrW + 8, scrH)
			surface.DrawLine(scrW, scrH - 48, scrW, scrH - 8)
			surface.DrawLine(scrW, scrH + 48, scrW, scrH + 8)
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
		local entity = LocalPlayer():GetViewEntity()

		if (IsValid(entity) and entity:GetClass():find("scanner")) then
			DrawScanner(entity)
		end
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
	DrawDead()
end