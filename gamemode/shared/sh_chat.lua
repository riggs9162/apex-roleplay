apex.commands = apex.commands or {}
apex.commands.stored = apex.commands.stored or {}

function apex.commands.Register(cmd, callback)
	local detour = function(client, arg, ...)
		if client.DarkRPUnInitialized then
			GAMEMODE:Notify(client, 1, 4, "Your data has not been loaded yet. Please wait.")
			GAMEMODE:Notify(client, 1, 4, "If this persists, try rejoining or contacting an admin.")
			return ""
		end

		return callback(client, arg, ...)
	end

	apex.commands.stored[string.lower(cmd)] = {
		cmd = cmd,
		callback = detour
	}
end

function apex.commands.Remove(cmd)
	apex.commands.stored[string.lower(cmd)] = nil
end

function apex.commands.Get(cmd)
	return apex.commands.stored[string.lower(cmd)]
end

local function RP_PlayerChat(client, text)
	apex.db.Log(client:Nick().." ("..client:SteamID64().."): "..text )
	local callback = ""
	local DoSayFunc
	local tblCmd = apex.commands.stored[string.lower( string.Explode(" ", text )[1] )];
	if tblCmd then
		callback, DoSayFunc = tblCmd.callback( client, string.sub( text, string.len( tblCmd.cmd ) + 2, string.len( text ) ) );
		if ( callback == "" ) then
			return "", "", DoSayFunc;
		end
		text = string.sub(text, string.len(tblCmd.cmd) + 2, string.len(text))
	end

	if ( callback != "" ) then
		callback = ( callback or "").." "
	end

	return text, callback, DoSayFunc;
end

local function RP_ActualDoSay(client, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(client:Team())
	local col2 = Color(255,255,255,255)
	if not client:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end

	if GAMEMODE.Config.alltalk then
		for k,v in player.Iterator() do
			GAMEMODE:TalkToPerson(v, col, callback..client:Name(), col2, text, client)
		end
	else
			if (client:IsCombine() and client:Team() != TEAM_ADMINISTRATOR) then
				text2 = hook.Call("CPTalk", nil, client, text)
				if text2 then text = text2; end
				text = "<:: "..text.." ::>";
			end

		GAMEMODE:TalkToRange(client, callback..client:Name().." says", text, 250)
	end
	return ""
end

GM.OldChatHooks = GM.OldChatHooks or {}
function GM:PlayerSay(client, text, teamonly, dead) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
	local text2 = (not teamonly and "" or "/g ") .. text
	local callback

	for k,v in pairs(self.OldChatHooks) do
		if type(v) != "function" then continue end

		if type(k) == "Entity" or type(k) == "Player" then
			text2 = v(k, client, text, teamonly, dead) or text2
		else
			text2 = v(client, text, teamonly, dead) or text2
		end
	end

	text2, callback, DoSayFunc = RP_PlayerChat(client, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end

	if game.IsDedicated() then
		ServerLog("\""..client:Nick().."<"..client:UserID()..">" .."<"..client:SteamID64()..">".."<"..team.GetName(client:Team())..">\" say \""..text.. "\"\n" .. "\n")
	end

	if DoSayFunc then DoSayFunc(text2) return "" end
	RP_ActualDoSay(client, text2, callback)

	hook.Call("PostPlayerSay", nil, client, text2, teamonly, dead)
	return ""
end

function GM:ReplaceChatHooks()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do -- Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
		self.OldChatHooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	for a,b in pairs(self.OldChatHooks) do
		if type(b) != "function" then
			self.OldChatHooks[a] = nil
		end
	end

	table.sort(self.OldChatHooks, function(a, b)
		if type(a) == "string" and type(b) == "string" then
			return a > b
		end

		return true
	end)
end

concommand.Add("apex", function(client, _, args)
	if not args[1] then for k,v in pairs(apex.commands.stored) do print(k) end return end

	local cmd = string.lower(args[1])
	local arg = table.concat(args, ' ', 2)
	local tbl = apex.commands.stored[cmd]

	if not tbl then return end

	tbl.callback(client, arg)
end)
