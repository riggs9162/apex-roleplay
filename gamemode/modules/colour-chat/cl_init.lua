local oocTags = {
	["superadmin"]	= "Super Admin",
	["admin"]		= "Admin",
	["gamemaster"]	= "Game Master",
	["moderator"]	= "Mod",
	["vip"]			= "VIP"
}

local ooccolour = {
	["superadmin"]	= Color(235, 1, 1),
	["admin"]		= Color(53, 209, 22),
	["gamemaster"]	= Color(242, 0, 255),
	["moderator"]	= Color(34, 88, 216),
	["vip"]			= Color(212, 185, 9),
	["user"]        = Color(255, 255, 255)
}

net.Receive("apex.chat.data", function()
	data = net.ReadString()
	message = net.ReadString()
	client = net.ReadEntity()

	if ( !data or data == "" ) then return end
	if ( !message or message == "" ) then return end
	if ( !IsValid(client) ) then return end

	plyNAME = client:Nick()
	teamCOL = team.GetColor(client:Team())
	steamNAME = client:SteamName()
	usergroup = client:GetUserGroup()
	steamID = client:SteamID64()

	prefix = ""

	if ( ooccolour[usergroup] ) then
		prefixc = ooccolour[usergroup]
	else
		prefixc = ""
	end

	local data1 = "chat.AddText(" .. data .. ")"
	local data2 = CompileString(data1, "ChatColourPrint")

	data2()
end)