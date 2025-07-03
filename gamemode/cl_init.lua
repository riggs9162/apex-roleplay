DeriveGamemode("sandbox")

apex = apex or {}

LocalPlayerInternal = LocalPlayerInternal or LocalPlayer
function LocalPlayer()
	if ( IsValid(apex.client) ) then
		return apex.client
	end

	return LocalPlayerInternal()
end

GM.NoLicense = GM.NoLicense or {}
GM.Config = GM.Config or {}

include("util.lua")
include("shared.lua")

/*---------------------------------------------------------------------------
Names
---------------------------------------------------------------------------*/
-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	return GAMEMODE.Config.allowrpnames and self.DarkRPVars and self:GetDarkRPVar("rpname") or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

function GM:GrabEarAnimation( client )
	return false
end

local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

surface.CreateFont("AckBarWriting", {
	size = 20,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "akbar"})

-- Copy from FESP(made by FPtje Falco)
-- This is no stealing since I made FESP myself.
local vector = FindMetaTable("Vector")
function vector:RPIsInSight(v, client)
	client = client or LocalPlayer()
	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = self
	trace.filter = v
	trace.mask = -1
	local TheTrace = util.TraceLine(trace)
	if TheTrace.Hit then
		return false, TheTrace.HitPos
	else
		return true, TheTrace.HitPos
	end
end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSuitPower" or
		(HelpToggled and name == "CHudChat") then
			return false
	else
		return true
	end
end

function GM:HUDDrawTargetID()
	return false
end

function GM:FindPlayer(info)
	if not info or info == "" then return nil end
	for k, v in player.Iterator() do
		if tonumber(info) == v:UserID() then
			return v
		end

		if info == v:SteamID64() then
			return v
		elseif info == v:SteamID() then
			return v
		end

		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) != nil then
			return v
		end

		if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) != nil then
			return v
		end
	end

	return nil
end

local function blackScreen(um)
	local toggle = um:ReadBool()
	if toggle then
		local black = Color(0, 0, 0)
		local w, h = ScrW(), ScrH()
		hook.Add("HUDPaintBackground", "BlackScreen", function()
			surface.SetDrawColor(black)
			surface.DrawRect(0, 0, w, h)
		end)
	else
		hook.Remove("HUDPaintBackground", "BlackScreen")
	end
end
usermessage.Hook("blackScreen", blackScreen)

function GM:PlayerStartVoice(client)
	if client == LocalPlayer() then
		client.DRPIsTalking = true
		return -- Not the original rectangle for yourself! ugh!
	end
	self.BaseClass:PlayerStartVoice(client)
end

function GM:PlayerEndVoice(client)
	if client == LocalPlayer() then
		client.DRPIsTalking = false
		return
	end

	self.BaseClass:PlayerEndVoice(client)
end

function GM:OnPlayerChat()
end

local FKeyBinds = {
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(client, bind, pressed)
	self.BaseClass:PlayerBindPress(client, bind, pressed)
	if client == LocalPlayer() and IsValid(client:GetActiveWeapon()) and string.find(string.lower(bind), "attack2") and client:GetActiveWeapon():GetClass() == "weapon_bugbait" then
		LocalPlayer():ConCommand("_hobo_emitsound")
	end

	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
	if bnd and FKeyBinds[bnd] and GAMEMODE[FKeyBinds[bnd]] then
		GAMEMODE[FKeyBinds[bnd]](GAMEMODE)
	end

	return
end

local function AddToChat(msg)
	local col1 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local prefixText = msg:ReadString()
	local client = msg:ReadEntity()
	client = IsValid(client) and client or LocalPlayer()

	if prefixText == "" or not prefixText then
		prefixText = client:Nick()
		prefixText = prefixText != "" and prefixText or client:SteamName()
	end

	local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local text = msg:ReadString()
	local shouldShow
	if text and text != "" then
		if IsValid(client) then
			shouldShow = hook.Call("OnPlayerChat", nil, client, text, false, not client:Alive(), prefixText, col1, col2)
		end

		if shouldShow != true then
			chat.AddText(col1, prefixText, col2, ": "..text)
		end
	else
		shouldShow = hook.Call("ChatText", nil, "0", prefixText, prefixText, "none")
		if shouldShow != true then
			chat.AddText(col1, prefixText)
		end
	end
	chat.PlaySound()
end
usermessage.Hook("DarkRP_Chat", AddToChat)

local function GetAvailableVehicles()
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(apex.getAvailableVehicles()) do
		print("\""..k.."\"")
	end
end
concommand.Add("apex_getvehicles", GetAvailableVehicles)

local function AdminLog(um)
	local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	local text = um:ReadString() .. "\n"
	MsgC(Color(255,0,0), "[crowLog] ")
	MsgC(colour, text)
end
usermessage.Hook("DRPLogMsg", AdminLog)

local function RetrieveDoorData(len)
	local door = net.ReadEntity()
	local doorData = net.ReadTable()
	if not door or not door.IsValid or not IsValid(door) or not doorData then return end

	if doorData.TeamOwn then
		local tdata = {}
		for k, v in pairs(string.Explode("\n", doorData.TeamOwn or "")) do
			if v and v != "" then
				tdata[tonumber(v)] = true
			end
		end
		doorData.TeamOwn = tdata
	else
		doorData.TeamOwn = nil
	end

	door.DoorData = doorData
end
net.Receive("DarkRP_DoorData", RetrieveDoorData)

local function UpdateDoorData(um)
	local door = um:ReadEntity()
	if not IsValid(door) then return end

	local var, value = um:ReadString(), um:ReadString()
	value = tonumber(value) or value

	if string.match(tostring(value), "Entity .([0-9]*)") then
		value = Entity(string.match(value, "Entity .([0-9]*)"))
	end

	if string.match(tostring(value), "Player .([0-9]*)") then
		value = Entity(string.match(value, "Player .([0-9]*)"))
	end

	if value == "true" or value == "false" then value = tobool(value) end

	if value == "nil" then value = nil end

	if var == "TeamOwn" then
		local decoded = {}
		for k, v in pairs(string.Explode("\n", value or "")) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
		if table.Count(decoded) == 0 then
			value = nil
		else
			value = decoded
		end
	end

	door.DoorData = door.DoorData or {}
	door.DoorData[var] = value
end
usermessage.Hook("DRP_UpdateDoorData", UpdateDoorData)

local function RetrievePlayerVar(entIndex, var, value, tries)
	local client = Entity(entIndex)

	-- Usermessages _can_ arrive before the player is valid.
	-- In this case, chances are huge that this player will become valid.
	if not IsValid(client) then
		if tries >= 5 then return end

		timer.Simple(0.5, function() RetrievePlayerVar(entIndex, var, value, tries + 1) end)
		return
	end

	client.DarkRPVars = client.DarkRPVars or {}

	local stringvalue = value
	value = tonumber(value) or value

	if string.match(stringvalue, "Entity .([0-9]*)") then
		value = Entity(string.match(stringvalue, "Entity .([0-9]*)"))
	end

	if string.match(stringvalue, "^Player .([0-9]+).") then
		value = player.GetAll()[tonumber(string.match(stringvalue, "^Player .([0-9]+)."))]
	end

	if stringvalue == "NULL" then
		value = NULL
	end

	if string.match(stringvalue, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]]) then
		local x,y,z = string.match(value, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]])
		value = Vector(x,y,z)
	end

	if stringvalue == "true" or stringvalue == "false" then value = tobool(value) end

	if stringvalue == "nil" then value = nil end

	hook.Call("DarkRPVarChanged", nil, client, var, client.DarkRPVars[var], value)
	client.DarkRPVars[var] = value
end

function pmeta:GetDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

/*---------------------------------------------------------------------------
Retrieve a player var.
Read the usermessage and attempt to set the DarkRP var
---------------------------------------------------------------------------*/
local function doRetrieve(um)
	local entIndex = um:ReadShort()
	local var, value = um:ReadString(), um:ReadString()
	RetrievePlayerVar(entIndex, var, value, 0)
end
usermessage.Hook("DarkRP_PlayerVar", doRetrieve)

local function InitializeDarkRPVars(len)
	local vars = net.ReadTable()

	if not vars then return end
	for k,v in pairs(vars) do
		if not IsValid(k) then continue end
		k.DarkRPVars = k.DarkRPVars or {}

		-- Merge the tables
		for a, b in pairs(v) do
			k.DarkRPVars[a] = b
		end
	end
end
net.Receive("DarkRP_InitializeVars", InitializeDarkRPVars)

function GM:InitPostEntity()
	RunConsoleCommand("_sendDarkRPvars")
	timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
		for k,v in player.Iterator() do
			if v.DarkRPVars and v:GetDarkRPVar("rpname") then continue end
			RunConsoleCommand("_sendDarkRPvars")
			return
		end
	end)
	hook.Call("TeamChanged", GAMEMODE, 1, 1)
end

function GM:TeamChanged(before, after)
	--self:RemoveHelpCategory(0)
	if RPExtraTeams[after] and RPExtraTeams[after].help then
		self:AddHelpCategory(0, RPExtraTeams[after].name .. " help")
		self:AddHelpLabels(0, RPExtraTeams[after].help)
	end
end

local function OnChangedTeam(um)
	hook.Call("TeamChanged", GAMEMODE, um:ReadShort(), um:ReadShort())
end
usermessage.Hook("OnChangedTeam", OnChangedTeam)

function GM:TextWrap(text, font, pxWidth)
	local total = 0

	surface.SetFont(font)
	text = text:gsub(".", function(char)
		if char == "\n" then
			total = 0
		end

		total = total + surface.GetTextSize(char)

		-- Wrap around when the max width is reached
		if total >= pxWidth then
			total = 0
			return "\n" .. char
		end

		return char
	end)

	return text
end


-- Please only ADD to the credits
-- Removing people from the credits will make at least one person very angry.
local creds =
[[LightRP:
Rick darkalonio

DarkRP:
Rickster
Picwizdan
Sibre
PhilXYZ
[GNC] Matt
Chromebolt A.K.A. unib5 (STEAM_0:1:19045957)
Falco A.K.A. FPtje (STEAM_0:0:8944068)
Eusion (STEAM_0:0:20450406)
Drakehawke (STEAM_0:0:22342869)]]

local function credits(um)
	chat.AddText(Color(255,0,0,255), "CREDITS FOR DARKRP", Color(0,0,255,255), creds)
end
usermessage.Hook("DarkRP_Credits", credits)

local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
	n = tostring(n)
	local sep = sep or ","
	local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
	end
	return n
end

if not FAdmin or not FAdmin.StartHooks then return end
FAdmin.StartHooks["DarkRP"] = function()
	-- DarkRP information:
	FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(client) return client:SteamName() end, true)
	FAdmin.ScoreBoard.Player:AddInformation("Money", function(client) if LocalPlayer():IsAdmin() and client.DarkRPVars and client:GetDarkRPVar("money") then return GAMEMODE.Config.currency..formatNumber(client:GetDarkRPVar("money")) end end)
	FAdmin.ScoreBoard.Player:AddInformation("Community link", function(client) return FAdmin.SteamToProfile(client) end)
	FAdmin.ScoreBoard.Player:AddInformation("XP", function(client) return client:GetDarkRPVar("xp") or "" end, true)
	FAdmin.ScoreBoard.Player:AddInformation("Rank", function(client)
		if FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SeeAdmins") then
			return client:GetNWString("usergroup")
		end
	end)


	-- Warrant

	--Teamban
	local function teamban(client, button)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jobs:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		local command = "apex_teamban"

		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
			local submenu = menu:AddSubMenu(v.name)
			submenu:AddOption("2 minutes", function() RunConsoleCommand(command, client:UserID(), k, 120) end)
			submenu:AddOption("Half an hour", function() RunConsoleCommand(command, client:UserID(), k, 1800) end)
			submenu:AddOption("An hour", function() RunConsoleCommand(command, client:UserID(), k, 3600) end)
			submenu:AddOption("Until restart", function() RunConsoleCommand(command, client:UserID(), k, 0) end)
		end
		menu:Open()
	end
	FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "FAdmin/icons/changeteam", Color(200, 0, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "apex_commands", client) end, teamban)

	local function teamunban(client, button)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jobs:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		local command = "apex_teamunban"

		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
			menu:AddOption(v.name, function() RunConsoleCommand(command, client:UserID(), k) end)
		end
		menu:Open()
	end
	FAdmin.ScoreBoard.Player:AddActionButton("Unban from job", function() return "FAdmin/icons/changeteam", "FAdmin/icons/disable" end, Color(200, 0, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "apex_commands", client) end, teamunban)
end

function Spawntimer(client)
--if LocalPlayer():Alive() == false then
spawntime = 30

	if LocalPlayer():GetNWString("usergroup") and LocalPlayer():GetNWString("usergroup") == "vip" then
		spawntime = 10
	end



	timer.Create( "SendSpawnTime", 1, 0, function()
	if spawntime == 0 then timer.Stop("SendSpawnTime")  else
		spawntime = spawntime -1

	end
	end)
end
concommand.Add( "SpawnTimer", Spawntimer )

local function ScaryGman()
	RunConsoleCommand("play","music/stingers/hl1_stinger_song27.mp3")
end
concommand.Add("_10140", ScaryGman)

hook.Add("ForceDermaSkin", "DarkRPForceDermaSkin", function()
	if GAMEMODE.Config.DarkRPSkin and GAMEMODE.Config.DarkRPSkin != "" then
		return GAMEMODE.Config.DarkRPSkin
	end

	return "DarkRP"
end)