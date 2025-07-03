FAdmin.StartHooks["StripWeapons"] = function()
	FAdmin.Access.AddPrivilege("StripWeapons", 2)
	FAdmin.Commands.AddCommand("StripWeapons", nil, "<Player>")
	FAdmin.Commands.AddCommand("Strip", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton("Strip weapons", {"FAdmin/icons/weapon", "FAdmin/icons/disable"}, Color(255, 130, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "StripWeapons", client) end, function(client, button)
		RunConsoleCommand("_FAdmin", "StripWeapons", client:SteamID64())
	end)
end