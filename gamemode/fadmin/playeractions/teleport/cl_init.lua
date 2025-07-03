local function EnableDisableNoclip(client)
	return client:GetNWBool("FADmin_CanNoclip") or
		((FAdmin.Access.PlayerHasPrivilege(client, "Noclip") or util.tobool(GetConVarNumber("sbox_noclip")))
			and not client:GetNWBool("FADmin_DisableNoclip"))
end

FAdmin.StartHooks["zz_Teleport"] = function()
	FAdmin.Access.AddPrivilege("Teleport", 2)

	FAdmin.Commands.AddCommand("Teleport", nil, "[Player]")
	FAdmin.Commands.AddCommand("TP", nil, "[Player]")
	FAdmin.Commands.AddCommand("Bring", nil, "<Player>", "[Player]")
	FAdmin.Commands.AddCommand("goto", nil, "<Player>")


	FAdmin.ScoreBoard.Player:AddActionButton("Teleport", "FAdmin/icons/Teleport", Color(0, 200, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport")/* and client == LocalPlayer()*/ end,
	function(client, button)
		RunConsoleCommand("_FAdmin", "Teleport", client:SteamID64())
	end)

	FAdmin.ScoreBoard.Player:AddActionButton("Goto", "FAdmin/icons/Teleport", Color(0, 200, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and client != LocalPlayer() end,
	function(client, button)
		RunConsoleCommand("_FAdmin", "goto", client:SteamID64())
	end)

	FAdmin.ScoreBoard.Player:AddActionButton("Bring", "FAdmin/icons/Teleport", Color(0, 200, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and client != LocalPlayer() end,
	function(client, button)
		local menu = DermaMenu()

		local Title = vgui.Create("DLabel")
		Title:SetText("  Bring to:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		menu:AddOption("Yourself", function() RunConsoleCommand("_FAdmin", "bring", client:SteamID64()) end)
		for k, v in player.Iterator() do
			if v != LocalPlayer() then
				menu:AddOption(v:Nick(), function() RunConsoleCommand("_FAdmin", "bring", client:SteamID64(), v:SteamID64()) end)
			end
		end
		menu:Open()
	end)
end