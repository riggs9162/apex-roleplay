-- Default team
GM.DefaultTeam = TEAM_CITIZEN

-- Teams who are counted as Combine
GM.CivilProtection = {
	[TEAM_CP] = true,
	[TEAM_OVERWATCH] = true,
	[TEAM_ADMINISTRATOR] = true
}

-- No License Weapons
GM.NoLicense["adminstick"] = true
GM.NoLicense["gmod_camera"] = true
GM.NoLicense["gmod_tool"] = true
GM.NoLicense["weapon_bugbait"] = true
GM.NoLicense["weapon_physcannon"] = true
GM.NoLicense["weapon_physgun"] = true
GM.NoLicense["tbfy_surrendered"] = true
GM.NoLicense["weapon_r_cuffed"] = true

-- Ammo types
GM:AddAmmoType("357", ".357 ammo", "models/items/357ammo.mdl", 30, 4, function(client)
	return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN
end)

GM:AddAmmoType("buckshot", "Shotgun ammo", "models/Items/BoxBuckshot.mdl", 20, 8, function(client)
	return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN
end)

GM:AddAmmoType("pistol", "9mm ammo", "models/Items/BoxSRounds.mdl", 10, 24, function(client)
	return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN
end)

GM:AddAmmoType("smg1", "Rifle ammo", "models/Items/BoxMRounds.mdl", 60, 30, function(client)
	return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN
end)

-- Door groups
AddDoorGroup("Civil Worker's Union", TEAM_CWU, TEAM_CP, TEAM_OVERWATCH, TEAM_ADMINISTRATOR)
AddDoorGroup("Civil Protection", TEAM_CP, TEAM_OVERWATCH, TEAM_ADMINISTRATOR)

-- Group chats
GM:AddGroupChat(function(client)
	return client:IsCombine()
end)