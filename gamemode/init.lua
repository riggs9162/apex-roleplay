DeriveGamemode("sandbox")

apex = apex or {}
apex.db = apex.db or {}

GM.NoLicense = GM.NoLicense or {}
GM.Config = GM.Config or {}

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("util.lua")
include("util.lua")

AddCSLuaFile("shared.lua")
include("shared.lua")

MySQL.initialize()
MySQLite.initialize()

-- RP Name Overrides

local meta = FindMetaTable("Player")
meta.SteamName = meta.SteamName or meta.Name
function meta:Name()
	return GAMEMODE.Config.allowrpnames and self.DarkRPVars and self:GetDarkRPVar("rpname") or self:SteamName()
end

meta.Nick = meta.Name
meta.GetName = meta.Name

-- End

util.AddNetworkString("DarkRP_InitializeVars")
util.AddNetworkString("DarkRP_DoorData")
util.AddNetworkString("DarkRP_keypadData")

-- Falco's prop protection
local BlockedModelsExist = sql.QueryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS1;") != false
if not BlockedModelsExist then
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS1(model VARCHAR(140) NOT NULL PRIMARY KEY);")
	include("fpp/FPP_DefaultBlockedModels.lua") -- Load the default blocked models
end

concommand.Add("apex_getvehicles_sv", function(client)
	if IsValid(client) and not client:IsAdmin() then return end
	ServerLog("Available vehicles for custom vehicles:" .. "\n")
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(apex.getAvailableVehicles()) do
		ServerLog("\""..k.."\"" .. "\n")
		print("\""..k.."\"")
	end
end)

local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}
FPP.AddDefaultBlocked(blockTypes, "chatindicator")
FPP.AddDefaultBlocked(blockTypes, "darkrp_console")
FPP.AddDefaultBlocked(blockTypes, "darkrp_cheque")
FPP.AddDefaultBlocked(blockTypes, "drug")
FPP.AddDefaultBlocked(blockTypes, "drug_lab")
FPP.AddDefaultBlocked(blockTypes, "fadmin_jail")
FPP.AddDefaultBlocked(blockTypes, "food")
FPP.AddDefaultBlocked(blockTypes, "gunlab")
FPP.AddDefaultBlocked(blockTypes, "letter")
FPP.AddDefaultBlocked(blockTypes, "meteor")
FPP.AddDefaultBlocked(blockTypes, "spawned_food")
FPP.AddDefaultBlocked(blockTypes, "spawned_money")
FPP.AddDefaultBlocked(blockTypes, "spawned_shipment")
FPP.AddDefaultBlocked(blockTypes, "spawned_weapon")
FPP.AddDefaultBlocked("Spawning1", "darkrp_laws")

concommand.Add("gmod_admin_cleanup", function()
	return false
end)