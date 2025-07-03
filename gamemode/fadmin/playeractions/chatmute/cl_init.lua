FAdmin.StartHooks["Chatmute"] = function()
	FAdmin.Access.AddPrivilege("Chatmute", 2)
	FAdmin.Commands.AddCommand("Chatmute", nil, "<Player>")
	FAdmin.Commands.AddCommand("UnChatmute", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("FAdmin_chatmuted") then return "Unmute chat" end
		return "Mute chat"
	end, function(client)
		if client:FAdmin_GetGlobal("FAdmin_chatmuted") then return "FAdmin/icons/chatmute" end
		return "FAdmin/icons/chatmute", "FAdmin/icons/disable"
	end, Color(255, 130, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Chatmute", client) end, function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_chatmuted") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				RunConsoleCommand("_FAdmin", "chatmute", client:SteamID64(), secs)
				button:SetImage2("null")
				button:SetText("Unmute chat")
				button:GetParent():InvalidateLayout()
			end)
		else
			RunConsoleCommand("_FAdmin", "UnChatmute", client:SteamID64())
		end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute chat")
		button:GetParent():InvalidateLayout()
	end)
end
