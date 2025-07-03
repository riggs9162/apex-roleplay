FAdmin.StartHooks["Jail"] = function()
	FAdmin.Access.AddPrivilege("Jail", 2)
	FAdmin.Commands.AddCommand("Jail", nil, "<Player>", "[Small/Normal/Big]", "[Time]")
	FAdmin.Commands.AddCommand("UnJail", nil, "<Player>")

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Jail", function(client)
		RunConsoleCommand("_FAdmin", "jail", client:SteamID64())
	end)

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("fadmin_jailed") then return "Unjail" end
		return "Jail"
	end,
	function(client)
		if client:FAdmin_GetGlobal("fadmin_jailed") then return "FAdmin/icons/jail", "FAdmin/icons/disable" end
		return "FAdmin/icons/jail"
	end,
	Color(255, 130, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Jail", client) end,
	function(client, button)
		if client:FAdmin_GetGlobal("fadmin_jailed") then RunConsoleCommand("_FAdmin", "unjail", client:SteamID64()) button:SetImage2("null") button:SetText("Jail") button:GetParent():InvalidateLayout() return end

		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jail Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		for k,v in pairs(FAdmin.PlayerActions.JailTypes) do
			if v == "Unjail" then continue end
			FAdmin.PlayerActions.addTimeSubmenu(menu, v .. " jail",
				function()
					RunConsoleCommand("_FAdmin", "Jail", client:SteamID64(), k)
					button:SetText("Unjail") button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end,
				function(secs)
					RunConsoleCommand("_FAdmin", "Jail", client:SteamID64(), k, secs)
					button:SetText("Unjail")
					button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end
			)
		end

		menu:Open()
	end)
end
