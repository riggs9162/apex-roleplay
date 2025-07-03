local function GiveWeaponGui(client)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Give weapon")
	frame:SetSize(ScrW() / 2, ScrH() - 50)
	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()

	local WeaponMenu = vgui.Create("FAdmin_weaponPanel", frame)
	WeaponMenu:StretchToParent(0,25,0,0)

	function WeaponMenu:DoGiveWeapon(SpawnName, IsAmmo)
		if not client:IsValid() then return end
		local giveWhat = (IsAmmo and "ammo") or "weapon"

		RunConsoleCommand("FAdmin", "give"..giveWhat, client:SteamID64(), SpawnName)
	end

	WeaponMenu:BuildList()
end

FAdmin.StartHooks["GiveWeapons"] = function()
	FAdmin.Access.AddPrivilege("giveweapon", 2)
	FAdmin.Commands.AddCommand("giveweapon", nil, "<Player>", "<weapon>")

	FAdmin.ScoreBoard.Player:AddActionButton("Give weapon(s)", "FAdmin/icons/weapon", Color(255, 130, 0, 255),

	function(client) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "giveweapon") end, function(client, button)
		GiveWeaponGui(client)
	end)
end