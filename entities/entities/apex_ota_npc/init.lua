AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("apex.overwatch.menu")
util.AddNetworkString("apex.overwatch.select")

function ENT:Initialize()
	self:SetModel("models/combine_super_soldier.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE, CAP_TURN_HEAD)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetPersistent(false)
	self:SetMaxYawSpeed(90)
end

function ENT:OnTakeDamage()
	return false
end

local function HasCooldown(client)
	if ( !IsValid(client) or !client:IsPlayer() ) then return false end
	if ( !client.LastOverwatchSet or !client.LastOverwatchSet.start ) then
		return false
	end

	if ( client:IsAdmin() ) then
		return false
	end

	local lastSet = client.LastOverwatchSet
	local start = lastSet.start
	local duration = lastSet.duration or 120
	local cooldown = math.Round(duration - (CurTime() - start), 0)
	if ( cooldown > 0 ) then
		return cooldown
	end

	return false
end

function ENT:Use(client)
	if ( !IsValid(client) or !client:IsPlayer() ) then return end

	local name = client:Nick()
	if ( GAMEMODE:IsValidName(name) ) then
		client:SetPData("oldname", name)
	end

	if ( client:Team() != TEAM_OVERWATCH ) then
		client:Notify("You are not a member of the Overwatch Transhuman Arm.")
		return
	end

	local cd = HasCooldown(client)
	if ( cd ) then
		client:Notify("You must wait " .. string.NiceTime(cd) .. " before you can change your rank or division again!")
		return
	end

	net.Start("apex.overwatch.menu")
	net.Send(client)
end

local function GiveWeapons(client, weaponTable)
	for _, weapon in ipairs(weaponTable or {}) do
		client:Give(weapon)
	end
end

net.Receive("apex.overwatch.select", function(_, client)
	if ( !IsValid(client) or !client:IsPlayer() ) then return end

	local rankID = net.ReadUInt(8)
	local divisionID = net.ReadUInt(8)

	local rankData = apex.overwatch.ranks[rankID]
	local divData = apex.overwatch.divisions[divisionID]
	if ( !rankData or !divData or client:Team() != TEAM_OVERWATCH ) then return end

	local cd = HasCooldown(client)
	if ( cd ) then
		client:Notify("You must wait " .. string.NiceTime(cd) .. " before you can change your rank or division again!")
		return
	end

	if ( !client:IsAdmin() ) then
		if ( rankData.xp > client:GetXP() ) then
			client:Notify("You do not have enough XP to be this rank!")
			return
		end

		if ( divData.xp > client:GetXP() ) then
			client:Notify("You do not have enough XP to be in this division!")
			return
		end
	end

	local existingRank = client:GetDarkRPVar("rank")
	local existingDiv = client:GetDarkRPVar("division")
	if ( existingRank == rankData.id and existingDiv == divData.id ) then
		client:Notify("You are already a part of this division and rank!")
		return
	end

	-- Check DvL uniqueness
	if ( rankData.id == RANK_DVL ) then
		for _, v in player.Iterator() do
			if (
				v:GetDarkRPVar("division") == divData.id and
				v:GetDarkRPVar("rank") == rankData.id and
				v:Team() == TEAM_OVERWATCH
			) then
				client:Notify("There is already a DvL for this division!")
				return
			end
		end
	end

	-- Check max per division
	local current = 0
	for _, v in player.Iterator() do
		if (
			v:GetDarkRPVar("division") == divData.id and
			v:Team() == TEAM_OVERWATCH
		) then
			current = current + 1
		end
	end

	if ( divData.max and current >= divData.max ) then
		client:Notify("This division is already at its maximum capacity of " .. divData.max .. " members!")
		return
	end

	-- Apply changes
	client:StripWeapons()
	GiveWeapons(client, {"weapon_physcannon", "gmod_tool", "weapon_physgun", "keys", "pocket", "door_ram", "weaponchecker"})
	GiveWeapons(client, divData.weapons[rankID])

	client:SetSkin(divData.skin or 0)

	local jobTitle = "Overwatch Transhuman Arm (" .. divData.abbreviation .. " - " .. rankData.abbreviation .. ")"
	local model = divData.model
	local id = math.random(100002, 990000)
	local name = "OTA:" .. divData.abbreviation .. "-" .. rankData.abbreviation .. "-" .. id

	if ( divData.noRank ) then
		name = "OTA:" .. divData.abbreviation .. "-" .. id
	end

	client:UpdateJob(jobTitle)
	client:SetModel(model)
	client:SetDarkRPVar("division", divData.id)
	client:SetDarkRPVar("rank", rankData.id)
	client:SetDarkRPVar("rpname", name)
	client.LastOverwatchSet = {
		start = CurTime(),
		rank = rankData.id,
		division = divData.id,
		duration = 120
	}
	client:SetArmor(0)

	client:Notify("You are now a " .. divData.name .. " " .. rankData.name)
end)