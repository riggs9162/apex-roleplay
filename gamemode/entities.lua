--Medical
AddCustomShipment("Health Kit", {
	model = "models/Items/HealthKit.mdl",
	entity = "item_healthkit",
	price = 20,
	amount = 40,
	seperate = true,
	pricesep = 60,
	noship = true,
	allowed = {TEAM_CWU},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 5 and client:Team() == TEAM_CWU or client:Team() == TEAM_CP and client.DarkRPVars.Division and client.DarkRPVars.Division == 2 end
})

AddCustomShipment("Health Vital", {
	model = "models/healthvial.mdl",
	entity = "item_healthvial",
	price = 5,
	amount = 20,
	seperate = true,
	pricesep = 20,
	noship = true,
	allowed = {TEAM_CWU},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 5 and client:Team() == TEAM_CWU or client:Team() == TEAM_CP and client.DarkRPVars.Division and client.DarkRPVars.Division == 2 end
})
--Weapons
AddCustomShipment("USP Match Pistol", {
	model = "models/weapons/w_pistol.mdl",
	entity = "ironsight_pistol",
	price = 50,
	amount = 40,
	seperate = true,
	pricesep = 300,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

AddCustomShipment("USP Match Pistol 2", {
	model = "models/apexwep/weapons/w_zistol.mdl",
	entity = "sight_usp2",
	price = 150,
	amount = 20,
	seperate = true,
	pricesep = 600,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

AddCustomShipment(".357", {
	model = "models/weapons/W_357.mdl",
	entity = "ironsight_357",
	price = 3600,
	amount = 20,
	seperate = true,
	pricesep = 8000,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

AddCustomShipment("SMG", {
	model = "models/weapons/w_smg1.mdl",
	entity = "weapon_smg1",
	price = 670,
	amount = 100,
	seperate = true,
	pricesep = 2000,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

AddCustomShipment("M4A1 Assault Rifle", {
	model = "models/apexwep/weapons/w_smg4.mdl",
	entity = "sight_smg2",
	price = 1000,
	amount = 20,
	seperate = true,
	pricesep = 4000,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})


AddCustomShipment("Shotgun", {
	model = "models/weapons/w_shotgun.mdl",
	entity = "sight_shotgun",
	price = 1550,
	amount = 20,
	seperate = true,
	pricesep = 6000,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})
-- CP
AddCustomShipment("AR3 Emplacement Gun", {
	model = "models/props_combine/combine_barricade_short02a.mdl",
	entity = "sent_zar3",
	price = 3000,
	amount = 1,
	seperate = true,
	pricesep = 3000,
	noship = true,
	allowed = {TEAM_CP},
	customCheck = function(client)
	if string.find(client:Name(), "GRID") and client:IsCombine() then
if not client:IsAdmin() then return false end
print("ssssssssss")
return true
	--for v,k in pairs(ents.FindInBox(Vector(6943.508789, -3166.320801, 5855.707031), Vector(975.108276, 1182.699341, -85.910248)))do
	--if k:IsPlayer() and k:SteamID64() == client:SteamID64() then
	--return true
	--else
	--return false
	--end
	--end

	else
	return false
	end


	end
})

AddCustomShipment("Lock Pick", {
	model = "models/weapons/w_crowbar.mdl",
	entity = "lockpick",
	price = 500,
	amount = 100,
	seperate = true,
	pricesep = 420,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

AddCustomShipment("Brewing barrel", {
	model = "models/props/de_inferno/wine_barrel.mdl",
	entity = "hl2rp_beerbrewer",
	price = 100,
	amount = 1,
	seperate = true,
	pricesep = 100,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN and ((SERVER and !client:hasMaxBarrels()) or CLIENT) end
})

AddCustomShipment("Yeast", {
	model = "models/props_junk/plasticbucket001a.mdl",
	entity = "hl2rp_yeast",
	price = 60,
	max = 4,
	amount = 1,
	seperate = true,
	pricesep = 60,
	noship = true,
	allowed = {TEAM_CITIZEN},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CITIZEN end
})

-- Vort

--[[AddCustomShipment("Larval extract", {
	model = "models/props_hive/larval_essence.mdl",
	entity = "hl2rp_vortessence",
	price = 1000,
	amount = 1,
	seperate = true,
	pricesep = 1000,
	noship = true,
	allowed = {TEAM_VORT},
	customCheck = function(client) return client:Team()==TEAM_VORT and client:GetModel()=='models/vortigaunt.mdl' end
})
]]

-- CWU
AddCustomShipment("Gin", {
	model = "models/bioshockinfinite/jin_bottle.mdl",
	entity = "hl2rp_gin",
	price = 200,
	max = 4,
	amount = 1,
	seperate = true,
	pricesep = 5000,
	noship = true,
	allowed = {TEAM_CWU},
	customCheck = function(client) return client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 2 and client:Team() == TEAM_CWU end
})