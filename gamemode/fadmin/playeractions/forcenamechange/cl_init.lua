FAdmin.StartHooks["Force namechange"] = function()
	FAdmin.Access.AddPrivilege("Force namechange", 2)
	FAdmin.Commands.AddCommand("fname", nil, "<Player>", "[Normal/Silent/Explode/Rocket]")

	FAdmin.ScoreBoard.Player:AddActionButton("Force namechange", "fadmin/icons/ragdoll", Color(73,147,197),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Force namechange") end,
	function(client, button)
		RunConsoleCommand("_FAdmin", "fname", client:SteamID64())
	end)
	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Force namechange", function(client)
		if client:IsAdmin() then return end
		RunConsoleCommand("_FAdmin", "fname", client:SteamID64())
	end)
end