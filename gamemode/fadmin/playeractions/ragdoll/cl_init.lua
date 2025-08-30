FAdmin.StartHooks["Ragdoll"] = function()
	FAdmin.Access.AddPrivilege("Ragdoll", 2)
	FAdmin.Commands.AddCommand("Ragdoll", nil, "<Player>", "[normal/hang/kick]")
	FAdmin.Commands.AddCommand("UnRagdoll", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if client:FAdmin_GetGlobal("fadmin_ragdolled") then return "Unragdoll" end
		return "Ragdoll"
	end,
	function(client)
		if client:FAdmin_GetGlobal("fadmin_ragdolled") then return "FAdmin/icons/ragdoll", "FAdmin/icons/disable" end
		return "FAdmin/icons/ragdoll"
	end,
	Color(255, 130, 0, 255),
	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ragdoll", client) end,
	function(client, button)
		if client:FAdmin_GetGlobal("fadmin_ragdolled") then
			RunConsoleCommand("_FAdmin", "unragdoll", client:SteamID64())
			button:SetImage2("null")
			button:SetText("Ragdoll")
			button:GetParent():InvalidateLayout()
		return end

		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Ragdoll Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(Color(0, 0, 0))

		menu:AddPanel(Title)

		for k,v in pairs(FAdmin.PlayerActions.RagdollTypes) do
			if v == "Unragdoll" then continue end
			FAdmin.PlayerActions.addTimeSubmenu(menu, v,
				function()
					RunConsoleCommand("_FAdmin", "Ragdoll", client:SteamID64(), k)
					button:SetImage2("FAdmin/icons/disable")
					button:SetText("Unragdoll")
					button:GetParent():InvalidateLayout()
				end,
				function(secs)
					RunConsoleCommand("_FAdmin", "Ragdoll", client:SteamID64(), k, secs)
					button:SetImage2("FAdmin/icons/disable")
					button:SetText("Unragdoll")
					button:GetParent():InvalidateLayout()
				end
			)
		end

		menu:Open()
	end)
end
