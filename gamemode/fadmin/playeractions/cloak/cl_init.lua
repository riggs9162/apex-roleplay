FAdmin.StartHooks["zz_Cloak"] = function()
	FAdmin.Access.AddPrivilege("Cloak", 2)
	FAdmin.Commands.AddCommand("Cloak", nil, "<Player>")
	FAdmin.Commands.AddCommand("Uncloak", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("FAdmin_cloaked") then return "Uncloak" end
		return "Cloak"
	end, function(client)
		if client:FAdmin_GetGlobal("FAdmin_cloaked") then return "FAdmin/icons/cloak", "FAdmin/icons/disable" end
		return "FAdmin/icons/cloak"
	end, Color(0, 200, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Cloak", client) end, function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_cloaked") then
			RunConsoleCommand("_FAdmin", "Cloak", client:SteamID64())
		else
			RunConsoleCommand("_FAdmin", "Uncloak", client:SteamID64())
		end

		if not client:FAdmin_GetGlobal("FAdmin_cloaked") then button:SetImage2("FAdmin/icons/disable") button:SetText("Uncloak") button:GetParent():InvalidateLayout() return end
		button:SetImage2("null")
		button:SetText("Cloak")
		button:GetParent():InvalidateLayout()
	end)
end