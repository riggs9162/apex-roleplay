FAdmin.StartHooks["Ignite"] = function()
	FAdmin.Access.AddPrivilege("Ignite", 2)
	FAdmin.Commands.AddCommand("Ignite", nil, "<Player>", "[time]")
	FAdmin.Commands.AddCommand("unignite", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client) return (client:FAdmin_GetGlobal("FAdmin_ignited") and "Extinguish") or "Ignite" end,
	function(client) local disabled = (client:FAdmin_GetGlobal("FAdmin_ignited") and "FAdmin/icons/disable") or nil return "FAdmin/icons/ignite", disabled end,
	Color(255, 130, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ignite", client) end,
	function(client, button)
		if not client:FAdmin_GetGlobal("FAdmin_ignited") then
			RunConsoleCommand("_FAdmin", "ignite", client:SteamID64())
			button:SetImage2("FAdmin/icons/disable")
			button:SetText("Extinguish")
			button:GetParent():InvalidateLayout()
		else
			RunConsoleCommand("_FAdmin", "unignite", client:SteamID64())
			button:SetImage2("null")
			button:SetText("Ignite")
			button:GetParent():InvalidateLayout()
		end
	end)
end