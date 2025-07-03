local function EnableDisableNoclip(client)
	return client:FAdmin_GetGlobal("FADmin_CanNoclip") or
		((FAdmin.Access.PlayerHasPrivilege(client, "Noclip") or util.tobool(GetConVarNumber("sbox_noclip")))
			and not client:FAdmin_GetGlobal("FADmin_DisableNoclip"))
end

FAdmin.StartHooks["zz_Noclip"] = function()
	FAdmin.Access.AddPrivilege("Noclip", 2)
	FAdmin.Access.AddPrivilege("SetNoclip", 2)

	FAdmin.Commands.AddCommand("SetNoclip", nil, "<Player>", "<Toggle 1/0>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(client)
		if EnableDisableNoclip(client) then
			return "Disable noclip"
		end
		return "Enable noclip"
	end, function(client) return "FAdmin/icons/Noclip", (EnableDisableNoclip(client) and "FAdmin/icons/disable") end, Color(0, 200, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetNoclip") end, function(client, button)
		if EnableDisableNoclip(client) then
			RunConsoleCommand("_FAdmin", "SetNoclip", client:SteamID64(), 0)
		else
			RunConsoleCommand("_FAdmin", "SetNoclip", client:SteamID64(), 1)
		end

		if EnableDisableNoclip(client) then
			button:SetText("Enable noclip")
			button:SetImage2("null")
			button:GetParent():InvalidateLayout()
			return
		end
		button:SetText("Disable noclip")
		button:SetImage2("FAdmin/icons/disable")
		button:GetParent():InvalidateLayout()
	end)
end