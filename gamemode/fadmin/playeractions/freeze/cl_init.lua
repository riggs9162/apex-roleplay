FAdmin.StartHooks["Freeze"] = function()
	FAdmin.Access.AddPrivilege("Freeze", 2)
	FAdmin.Commands.AddCommand("freeze", nil, "<Player>")
	FAdmin.Commands.AddCommand("unfreeze", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("FAdmin_frozen") then return "Unfreeze" end
		return "Freeze"
	end, function(client)
		if client:FAdmin_GetGlobal("FAdmin_frozen") then return "FAdmin/icons/freeze", "FAdmin/icons/disable" end
		return "FAdmin/icons/freeze"
	end, Color(255, 130, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Freeze", client) end, function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_frozen") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				RunConsoleCommand("_FAdmin", "freeze", client:SteamID64(), secs)
				button:SetImage2("FAdmin/icons/disable")
				button:SetText("Unfreeze")
				button:GetParent():InvalidateLayout()
			end)
		else
			RunConsoleCommand("_FAdmin", "unfreeze", client:SteamID64())
		end

		button:SetImage2("null")
		button:SetText("Freeze")
		button:GetParent():InvalidateLayout()
	end)
end
