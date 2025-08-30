hook.Add("PlayerInitialSpawn", "apex.ooc.amount", function(client)
	client.OOCAmount = 10

	timer.Create("apex.ooc.amount." .. client:SteamID64(), 1800, 0, function()
		client.OOCAmount = 10
	end)
end)

local function OOC(client, args)
	if ( args == "" ) then
		client:Notify("You must specify something to say!")
		return ""
	end

	timeLeft = math.floor(timer.TimeLeft("apex.ooc.amount." .. client:SteamID64()) or 0)
	timeLeft = string.NiceTime(timeLeft)

	if ( GetGlobalInt("OOCDisabled", 0) == 1 and client:IsUserGroup("user") ) then
		client:Notify("OOC is temporarily disabled on at the moment. Please wait until it is re-enabled.")
		return ""
	end

	if ( client.OOCAmount < 1 and client:IsUserGroup("user") ) then
		client:Notify("You have no OOC messages left! You need to wait " .. timeLeft .. " before you can use OOC again.")
		return ""
	end

	local DoSay = function(text)
		if ( client:IsUserGroup("user") ) then
			client.OOCAmount = client.OOCAmount - 1
			client:Notify("You have " .. client.OOCAmount .. " OOC messages left, in " .. timeLeft .. " you will have 10 messages again.")
		end

		text = tostring(text)

		for k, v in player.Iterator() do
			v:ApexChat([[Color(200, 0, 0), "[OOC] ", prefixc, steamNAME, ": ", Color(200, 200, 200), message]], client, text)
		end
	end

	return args, DoSay
end
apex.commands.Register("//", OOC, true, 1.5)
apex.commands.Register("/a", OOC, true, 1.5)
apex.commands.Register("/ooc", OOC, true, 1.5)

local function LocalOOC(client, args)
	if ( args == "" ) then
		client:Notify("You must specify something to say!")
		return ""
	end

	local DoSay = function(text)
		for k, v in pairs(ents.FindInSphere(client:GetPos(), 300)) do
			if ( v:IsPlayer() ) then
				v:ApexChat([[Color(200, 0, 0), "[LOOC] ", prefixc, steamNAME, teamCOL, " (", plyNAME, ")", ": ", Color(255, 220, 220), message]], client, args)
			end
		end
	end

	return args, DoSay
end

apex.commands.Register("///", LocalOOC)
apex.commands.Register(".//", LocalOOC)
apex.commands.Register("/looc", LocalOOC)
apex.commands.Register("/local", LocalOOC)

apex.commands.Register("/roll", function(client, args)
	local DoSay = function(text)
		local roll = math.random(0, 100)
		GAMEMODE:TalkToRange(client, "** " .. client:Nick() .. " rolled " .. roll .. " out of 100.", "", 300)
	end

	return args, DoSay
end)

apex.commands.Register("/apply", function(client, args)
	local DoSay = function(text)
		GAMEMODE:TalkToRange(client, client:Nick() .. " identifies as a member of the " .. client:GetDarkRPVar("job") .. " job.", "", 300)
	end

	return args, DoSay
end)

apex.commands.Register("/me", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify an action to perform!")
		return ""
	end

	local DoSay = function(text)
		GAMEMODE:TalkToRange(client, client:Nick() .. " " .. text, "", 250)
	end

	return args, DoSay
end)

apex.commands.Register("/mes", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify an action to perform!")
		return ""
	end

	local DoSay = function(text)
		GAMEMODE:TalkToRange(client, client:Nick() .. "'s " .. text, "", 250)
	end

	return args, DoSay
end)

apex.commands.Register("/it", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify an action to perform!")
		return ""
	end

	local DoSay = function(text)
		for k, v in pairs(ents.FindInSphere(client:GetPos(), 250)) do
			if ( v:IsPlayer() ) then
				v:ApexChat([[Color(253, 0, 0), "**** ", message]], client, args)
			end
		end
	end

	return args, DoSay
end)

apex.commands.Register("/pm", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify a player to send a private message to!")
		return ""
	end

	local name, msg = string.match(args, "^(%S+)%s+(.+)$")
	if ( !name or !msg ) then
		client:Notify("You must specify a player and a message!")
		return ""
	end

	if ( !GAMEMODE:FindPlayer(name) ) then
		client:Notify("Player not found!")
		return ""
	end

	target = GAMEMODE:FindPlayer(name)

	if ( target ) then
		GAMEMODE:TalkToPerson(target, Color(45, 154, 6), "(PM) " .. client:Nick(), Color(45, 154, 6), msg, client)
		client:ApexChat([[Color(45, 154, 6), "(PM SENT) ", plyNAME, ": ", message]], client, msg)
		client:SendLua("surface.PlaySound(\"buttons/blip1.wav\")")
		target:SendLua("surface.PlaySound(\"buttons/blip1.wav\")")
	else
		client:Notify("Player not found!")
	end

	return ""
end)

apex.commands.Register("/w", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify something to whisper!")
		return ""
	end

	local DoSay = function(text)
		for k, v in pairs(ents.FindInSphere(client:GetPos(), 96)) do
			if ( v:IsPlayer() ) then
				v:ApexChat([[Color(0, 102, 204), plyNAME, " whispers", ": ", message]], client, args)
			end
		end
	end

	return args, DoSay
end)

apex.commands.Register("/y", function(client, args)
	if ( args == "" ) then
		client:Notify("You must specify something to yell!")
		return ""
	end

	local DoSay = function(text)
		for k, v in pairs(ents.FindInSphere(client:GetPos(), 512)) do
			if ( v:IsPlayer() ) then
				v:ApexChat([[Color(255, 128, 0), plyNAME, " yells", ": ", message]], client, args)
			end
		end
	end

	return args, DoSay
end)