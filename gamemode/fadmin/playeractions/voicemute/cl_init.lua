hook.Add("PlayerBindPress", "FAdmin_voicemuted", function(client, bind, pressed)
	if client:FAdmin_GetGlobal("FAdmin_voicemuted") and string.find(string.lower(bind), "voicerecord") then return true end
	-- The voice muting is not done clientside, this is just so people know they can't talk
end)

FAdmin.StartHooks["Voicemute"] = function()
	FAdmin.Access.AddPrivilege("Voicemute", 2)
	FAdmin.Commands.AddCommand("Voicemute", nil, "<Player>")
	FAdmin.Commands.AddCommand("UnVoicemute", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
			if client:FAdmin_GetGlobal("FAdmin_voicemuted") then return "Unmute globally" end
			return "Mute globally"
		end,

	function(client)
		if client:FAdmin_GetGlobal("FAdmin_voicemuted") then return "FAdmin/icons/voicemute" end
		return "FAdmin/icons/voicemute", "FAdmin/icons/disable"
	end,
	Color(255, 130, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Voicemute", client) end,
	function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_voicemuted") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				RunConsoleCommand("_FAdmin", "Voicemute", client:SteamID64(), secs)
				button:SetImage2("null")
				button:SetText("Unmute voice")
				button:GetParent():InvalidateLayout()
			end)
		else
			RunConsoleCommand("_FAdmin", "UnVoicemute", client:SteamID64())
		end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute voice")
		button:GetParent():InvalidateLayout()
	end)

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		return client.FAdminMuted and "Unmute" or "Mute"
	end,
	function(client)
		if client.FAdminMuted then return "FAdmin/icons/voicemute" end
		return "FAdmin/icons/voicemute", "FAdmin/icons/disable"
	end,
	Color(255, 130, 0, 255),

	true,

	function(client, button)
		client:SetMuted(not client.FAdminMuted)
		client.FAdminMuted = not client.FAdminMuted

		if client.FAdminMuted then button:SetImage2("null") button:SetText("Unmute") button:GetParent():InvalidateLayout() return end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute")
		button:GetParent():InvalidateLayout()
	end)

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Mute/Unmute", function(client, Panel)
		client:SetMuted(not client.FAdminMuted)
		client.FAdminMuted = not client.FAdminMuted
	end)
end
