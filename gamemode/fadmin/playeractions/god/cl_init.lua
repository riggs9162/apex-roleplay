FAdmin.StartHooks["God"] = function()
	FAdmin.Access.AddPrivilege("God", 2)
	FAdmin.Commands.AddCommand("god", nil, "<Player>")
	FAdmin.Commands.AddCommand("ungod", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("FAdmin_godded") then return "Ungod" end
		return "God"
	end, function(client)
		if client:FAdmin_GetGlobal("FAdmin_godded") then return "FAdmin/icons/god", "FAdmin/icons/disable" end
		return "FAdmin/icons/god"
	end, Color(255, 130, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "God") end, function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_godded") then
			RunConsoleCommand("_FAdmin", "god", client:SteamID64())
		else
			RunConsoleCommand("_FAdmin", "ungod", client:SteamID64())
		end

		if not client:FAdmin_GetGlobal("FAdmin_godded") then button:SetImage2("FAdmin/icons/disable") button:SetText("Ungod") button:GetParent():InvalidateLayout() return end
		button:SetImage2("null")
		button:SetText("God")
		button:GetParent():InvalidateLayout()
	end)
end