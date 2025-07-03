CPPI = CPPI or {}
CPPI.CPPI_DEFER = 102112 --\102\112 = fp
CPPI.CPPI_NOTIMPLEMENTED = 7080// FP

function CPPI:GetName()
	return "Falco's prop protection"
end

function CPPI:GetVersion()
	return "addon.2"
end

function CPPI:GetInterfaceVersion()
	return 1.1
end

function CPPI:GetNameFromUID(uid)
	return CPPI.CPPI_NOTIMPLEMENTED
end

local PLAYER = FindMetaTable("Player")
function PLAYER:CPPIGetFriends()
	if not self.Buddies then return CPPI.CPPI_DEFER end
	local FriendsTable = {}
	for k,v in pairs(self.Buddies) do
		for _,client in player.Iterator() do
			if client:SteamID64() == k then
				table.insert(FriendsTable, client)
				break
			end
		end
	end
	return FriendsTable
end

local ENTITY = FindMetaTable("Entity")
function ENTITY:CPPIGetOwner()
	local Owner = self.FPPOwner
	if not IsValid(Owner) or not Owner:IsPlayer() then return Owner, self.FPPOwnerID end
	return Owner, Owner:UniqueID()
end

if SERVER then
	function ENTITY:CPPISetOwner(client)
		self.FPPOwner = client
		self.FPPOwnerID = client:SteamID64()
		return true
	end

	function ENTITY:CPPISetOwnerUID(UID)
		local client = player.GetByUniqueID(tostring(UID))
		if self.FPPOwner and client:IsValid() then
			if self.AllowedPlayers then
				table.insert(self.AllowedPlayers, client)
			else
				self.AllowedPlayers = {client}
			end
			return true
		elseif client:IsValid() then
			self.FPPOwner = client
			self.FPPOwnerID = client:SteamID64()
			return true
		end
		return false
	end

	function ENTITY:CPPICanTool(client, tool)
		local Value = FPP.Protect.CanTool(client, nil, tool, self)
		if Value != false and Value != true then Value = true end
		return Value-- fourth argument is entity, to avoid traces.
	end

	function ENTITY:CPPICanPhysgun(client)
		return FPP.PlayerCanTouchEnt(client, self, "Physgun1", "FPP_PHYSGUN1")
	end

	function ENTITY:CPPICanPickup(client)
		return FPP.PlayerCanTouchEnt(client, self, "Gravgun1", "FPP_GRAVGUN1")
	end

	function ENTITY:CPPICanPunt(client)
		return FPP.PlayerCanTouchEnt(client, self, "Gravgun1", "FPP_GRAVGUN1")
	end
end