/*---------------------------------------------------------------------------
DarkRP hooks
---------------------------------------------------------------------------*/

function GM:GetGameDescription()
	return "apex-roleplay.com | Half-Life 2 Roleplay"
end

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:PlayerBuyDoor( objPl, objEnt )
	return true
end

function GM:PlayerSellDoor( objPl, objEnt )
	return false
end

function GM:GetDoorCost( objPl, objEnt )
	return GAMEMODE.Config.doorcost != 0 and  GAMEMODE.Config.doorcost or 30;
end

function GM:GetVehicleCost( objPl, objEnt )
	return GAMEMODE.Config.vehiclecost != 0 and  GAMEMODE.Config.vehiclecost or 40;
end

local notAllowed = {
	"CP",
	"CmD",
	"DvL",
	"SeC",
	"n/a",
	"ooc",
	"shared",
	"world",
}

function GM:CanChangeRPName(client, name)
	local latestNameChanges = apex.latestNameChanges[client]
	if ( !latestNameChanges ) then
		latestNameChanges = {}
		apex.latestNameChanges[client] = latestNameChanges
	end

	local started = latestNameChanges.started
	local duration = latestNameChanges.duration or 60
	if ( started and started + duration > CurTime() ) then
		return false, "You can only change your RP name once every " .. string.NiceTime(duration) .. "."
	end

	if ( !GAMEMODE.Config.allowrpnames ) then
		return false, "RP names are disabled on this server."
	end

	local canChangeName, reason = self:IsValidName(name)
	if ( !canChangeName ) then
		return false, reason
	end

	for k, v in ipairs(notAllowed) do
		if ( string.find(string.lower(name), string.lower(v)) ) then
			return false, "You cannot use the name '" .. v .. "' in your RP name."
		end
	end

	return true
end

function GM:CanDemote(client, target, reason)
	if client:Team() == TEAM_ADMINISTRATOR then
		return true
	else
		return false
	end
end

function GM:CanVote(client, vote)

end

function GM:PlayerWalletChanged(client, amount)

end

function GM:PlayerGetSalary(client, amount)

end

function GM:DarkRPVarChanged(client, var, oldvar, newvalue)

end

function GM:PlayerBoughtVehicle(client, ent, cost)

end

function GM:PlayerBoughtDoor(client, ent, cost)

end

function GM:CanDropWeapon(client, weapon)
	local class = string.lower(weapon:GetClass())
	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity != class then continue end

		return true
	end

	return false
end

function GM:DatabaseInitialized()
	FPP.Init()
	apex.initDatabase()
end

function GM:CanSeeLogMessage(client, message, colour)
	return client:IsAdmin()
end

function GM:UpdatePlayerSpeed(client)
	if client:IsArrested() then
		GAMEMODE:SetPlayerSpeed(client, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	elseif client:IsCombine() then
		GAMEMODE:SetPlayerSpeed(client, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp)
	else
		GAMEMODE:SetPlayerSpeed(client, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	end
end

/*---------------------------------------------------------
Gamemode functions
---------------------------------------------------------*/

function GM:PlayerSpawnProp(client, model)

	client:SetPData("playerdead", "0")
	client:SetNWInt( "FoodTimeout", 0 )

	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GAMEMODE.Config.propspawning or (FAdmin and FAdmin.Access.PlayerHasPrivilege(client, "apex_prop")) or client:IsAdmin()) and true) or false

	if client:IsArrested() then return false end
	model = string.gsub(tostring(model), "\\", "/")
	model = string.gsub(tostring(model), "//", "/")

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerSpawnProp then
		RPExtraTeams[client:Team()].PlayerSpawnProp(client, model)
	end

	if not allowed then return false end

	return self.BaseClass:PlayerSpawnProp(client, model)
end

function GM:PlayerSpawnSENT(client, model)
	if self.BaseClass:PlayerSpawnSENT(client, model) and client:IsAdmin() then
		return true
	end

	GAMEMODE:Notify(client, 1, 2, apex.language.GetPhrase("need_admin", "gm_spawnsent"))

	return false
end

local function canSpawnWeapon(client, class)
	if (not GAMEMODE.Config.adminweapons == 0 and client:IsAdmin()) or
	(GAMEMODE.Config.adminweapons == 1 and client:IsSuperAdmin()) then
		return true
	end
	GAMEMODE:Notify(client, 1, 4, "You can't spawn weapons")

	return false
end

function GM:PlayerSpawnSWEP(client, class, model)
	return canSpawnWeapon(client, class) and self.BaseClass:PlayerSpawnSWEP(client, class, model) and not client:IsArrested()
end

function GM:PlayerGiveSWEP(client, class, model)
	return canSpawnWeapon(client, class) and self.BaseClass:PlayerGiveSWEP(client, class, model) and not client:IsArrested()
end

function GM:PlayerSpawnEffect(client, model)
	return self.BaseClass:PlayerSpawnEffect(client, model) and not client:IsArrested()
end

function GM:PlayerSpawnVehicle(client, model)
if string.match( model, "apc" ) then
return client:IsSuperAdmin()
end

if string.match( model, "chair" ) or string.match( model, "seat" ) or string.match( model, "pod" ) then
return client:IsAdmin() or client:GetNWString("usergroup") == "vip"
end
	--return self.BaseClass:PlayerSpawnVehicle(client, model) and not client:IsArrested()
end

function GM:PlayerSpawnNPC(client, model)
	if GAMEMODE.Config.adminnpcs and not client:IsAdmin() then return false end

	return self.BaseClass:PlayerSpawnNPC(client, model) and not client:IsArrested()
end

function GM:PlayerSpawnRagdoll(client, model)
	return self.BaseClass:PlayerSpawnRagdoll(client, model) and not client:IsArrested()
end

function inShellBeach(player)
if not string.find(game.GetMap(),"industrial17") then return false end
for v,k in pairs(ents.FindInBox(Vector(-3378.683838, 7561.415039, 2142.586914),Vector(16132.918945, 16122.794922, -829.896362))) do
if k == player then
return true
end
end
return false
end

function GM:PlayerSpawnedProp(client, model, ent)
	self.BaseClass:PlayerSpawnedProp(client, model, ent)
	ent.SID = client.SID
	ent:CPPISetOwner(client)

	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		ent.RPOriginalMass = phys:GetMass()
	end

	if GAMEMODE.Config.proppaying and not client:IsAdmin() then

		if inShellBeach(client) then
		if client:CanAfford(2) then
			GAMEMODE:Notify(client, 0, 4, "Deducted " .. GAMEMODE.Config.currency .. "2 (lowered due to cheap Shell Beach imports)")
			client:AddMoney(-2)
		else
			GAMEMODE:Notify(client, 1, 4, "Need " .. GAMEMODE.Config.currency .. "2")
			SafeRemoveEntity(ent)
			return false
		end
else
		if client:CanAfford(GAMEMODE.Config.propcost) then
			GAMEMODE:Notify(client, 0, 4, "Deducted " .. GAMEMODE.Config.currency .. GAMEMODE.Config.propcost)
			client:AddMoney(-GAMEMODE.Config.propcost)
		else
			GAMEMODE:Notify(client, 1, 4, "Need " .. GAMEMODE.Config.currency .. GAMEMODE.Config.propcost)
			SafeRemoveEntity(ent)
			return false
		end

		end
	end
end

function GM:PlayerSpawnedRagdoll(client, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(client, model, ent)
	ent.SID = client.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent)
	if ent:IsVehicle() then
		local found = ent:CPPIGetOwner()
		if IsValid(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end

	for k,v in pairs(DarkRPEntities or {}) do
		if ent:IsValid() and ent:GetClass() == v.ent and ent.dt and IsValid(ent.dt.owning_ent) and not ent.IsRemoved then
			local client = ent.dt.owning_ent
			local cmdname = string.gsub(v.ent, " ", "_")
			if not client["max"..cmdname] then
				client["max"..cmdname] = 1
			end
			client["max"..cmdname] = client["max"..cmdname] - 1
			ent.IsRemoved = true
		end
	end
end

function GM:ShowSpare1(client)
	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].ShowSpare1 then
		return RPExtraTeams[client:Team()].ShowSpare1(client)
	end
end

function GM:ShowSpare2(client)
	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].ShowSpare2 then
		return RPExtraTeams[client:Team()].ShowSpare2(client)
	end
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- If it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = Player(tonumber(ent.SID) or 0)
		end

		-- If we know by now who killed the NPC, pay them.
		if IsValid(ent) and GAMEMODE.Config.npckillpay > 0 then
			ent:AddMoney(GAMEMODE.Config.npckillpay)
			GAMEMODE:Notify(ent, 0, 4, apex.language.GetPhrase("npc_killpay", GAMEMODE.Config.currency .. GAMEMODE.Config.npckillpay))
		end
	end
end

function GM:KeyPress(client, code)
	self.BaseClass:KeyPress(client, code)
end

local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine(tracedata)

	return not trace.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
-- proxy function to take load from PlayerCanHearPlayersVoice, which is called a quadratic amount of times per tick,
-- causing a lagfest when there are many players
local function calcPlyCanHearPlayerVoice(listener)
	if not IsValid(listener) and listener.DrpCanHear then
		return false
	end
	listener.DrpCanHear = listener.DrpCanHear or {}
	for _, talker in player.Iterator() do
		listener.DrpCanHear[talker] = not vrad or -- Voiceradius is off, everyone can hear everyone
			(listener:GetShootPos():Distance(talker:GetShootPos()) < 550 and -- voiceradius is on and the two are within hearing distance
				(not dynv or IsInRoom(listener, talker))) -- Dynamic voice is on and players are in the same room
	end
end
hook.Add("PlayerInitialSpawn", "DarkRPCanHearVoice", function(client)
	timer.Create(client:UserID() .. "DarkRPCanHearPlayersVoice", 0.5, 0, fn.Curry(calcPlyCanHearPlayerVoice, 2)(client))
				// client:SetDarkRPVar( "ration", "yes" )

end)
hook.Add("PlayerDisconnected", "DarkRPCanHearVoice", function(client)
	if v and not v.DrpCanHear then return end
	for k,v in player.Iterator() do
		v.DrpCanHear[client] = nil
	end
	timer.Destroy(client:UserID() .. "DarkRPCanHearPlayersVoice")
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
	local canHear = listener.DrpCanHear and listener.DrpCanHear[talker]
	return canHear, threed
end

function GM:CanTool(client, trace, mode)
--	if not FPP.Protect.CanTool(client, trace, tool) then
--		return false
--	end
	--print(mode)
	if (mode == "duplicator" or mode == "dynamite" or mode == "wire_explosive" or mode == "wire_simple_explosive") and not client:IsAdmin() then return false end
	if mode == "wire_turret" then return false end
	if not client:IsAdmin() and mode == "paint" then
		return false
	end
	if client:GetNWString("usergroup") != "vip" and (not client:IsAdmin()) then
		if (mode == "wire_expression2" or mode == "wire_spu" or mode == "wire_egp") then
			GAMEMODE:Notify(client, 1, 4, mode.." is VIP only.")
			return false
		end
	end
	--if not self.BaseClass:CanTool(client, trace, mode) then return false end


	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (client:IsAdmin() or client:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and not GAMEMODE.Config.allowvnocollide then
			return false
		end
		if mode == "duplicator" then return false end
	end
	return true
end

function GM:CanPlayerSuicide(client)
	if (true) then return false end

	if client.IsSleeping then
		GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("unable", "suicide", ""))
		return false
	end
	if client:IsArrested() then
		GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("unable", "suicide", ""))
		return false
	end
	if GAMEMODE.Config.wantedsuicide and client:GetDarkRPVar("wanted") then
		GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("unable", "suicide", ""))
		return false
	end

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].CanPlayerSuicide then
		return RPExtraTeams[client:Team()].CanPlayerSuicide(client)
	end
	return false
end

function GM:CanDrive(client, ent)
	GAMEMODE:Notify(client, 1, 4, "Drive disabled for now.")
	return false -- Disabled until people can't minge with it anymore
end

local allowedProperty = {
	remover = true,
	ignite = false,
	extinguish = true,
	keepupright = true,
	gravity = true,
	collision = true,
	skin = true,
	bodygroups = true
}
function GM:CanProperty(client, property, ent)

	if client:IsAdmin() then return true end
	if allowedProperty[property] and ent:CPPICanTool(client, "remover") then
		return true
	end

	if property == "persist" and client:IsSuperAdmin() then
		return true
	end
	GAMEMODE:Notify(client, 1, 4, "Property disabled for now.")
	return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(client, actid)
	return false
end

function GM:PlayerShouldTakeDamage(client, attacker)
	if string.match( attacker:GetClass(), "prop" ) then return false end
--	if attacker:GetClass() == "prop_physics" then return false end
	return true
end

function GM:DoPlayerDeath(client, attacker, dmginfo, ...)
	local weapon = client:GetActiveWeapon()
	local canDrop = hook.Call("CanDropWeapon", self, client, weapon)

	if GAMEMODE.Config.dropweapondeath and IsValid(weapon) and canDrop then
				if weapon == "riot_shield" then
print "riot shield drop blocked"

else
		client:DropDRPWeapon(weapon)
				end
	end
	self.BaseClass:DoPlayerDeath(client, attacker, dmginfo, ...)
end

function GM:PlayerDeath(client, weapon, killer)
	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerDeath then
		RPExtraTeams[client:Team()].PlayerDeath(client, weapon, killer)
	end

	if GAMEMODE.Config.deathblack then
		SendUserMessage("blackScreen", client, true)
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end

	if GAMEMODE.Config.showdeaths then
		self.BaseClass:PlayerDeath(client, weapon, killer)
	end

	client:Extinguish()

	if client:InVehicle() then client:ExitVehicle() end

	if client:IsArrested() and not GAMEMODE.Config.respawninjail  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		client.NextSpawnTime = CurTime() + math.ceil(GAMEMODE.Config.jailtimer - (CurTime() - client.LastJailed)) + 1
		for a, b in player.Iterator() do
			b:PrintMessage(HUD_PRINTCENTER, apex.language.GetPhrase("died_in_jail", client:Nick()))
		end
		GAMEMODE:Notify(client, 4, 4, apex.language.GetPhrase("dead_in_jail"))
	else
		-- Normal death, respawning.
		if not client:IsAdmin() and not client:IsVIP() then
			client.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 30)
		elseif client:IsVIP() then
			client.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 10)
		end
	end
	client.DeathPos = client:GetPos()

	if GAMEMODE.Config.dropmoneyondeath then
		local amount = GAMEMODE.Config.deathfee
		if not client:CanAfford(GAMEMODE.Config.deathfee) then
			amount = client:GetDarkRPVar("money")
		end

		if amount > 0 then
			client:AddMoney(-amount)
			DarkRPCreateMoneyBag(client:GetPos(), amount)
		end
	end

	if IsValid(client) and (client != killer or client.Slayed) and not client:IsArrested() then
		client:SetDarkRPVar("wanted", false)
		client.DeathPos = nil
		client.Slayed = false
	end

	client:GetTable().ConfiscatedWeapons = nil

	local KillerName = (killer:IsPlayer() and killer:Nick()) or tostring(killer)

	local WeaponName = IsValid(weapon) and ((weapon:IsPlayer() and IsValid(weapon:GetActiveWeapon()) and weapon:GetActiveWeapon():GetClass()) or weapon:GetClass()) or "unknown"
	if IsValid(weapon) and weapon:GetClass() == "prop_physics" then
		WeaponName = weapon:GetClass() .. " (" .. (weapon:GetModel() or "unknown") .. ")"
	end

	if killer == client then
		KillerName = "Himself"
		WeaponName = "suicide trick"
	end

	apex.db.Log(client:Nick() .. " was killed by " .. KillerName .. " with a " .. WeaponName, nil, Color(255, 190, 0))
	timer.Simple( 1, function()
		client:ChangeTeam(GAMEMODE.DefaultTeam, true)
	end)
end

function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )
	if npc:GetClass() == "npc_gman" then
		dmginfo:ScaleDamage( 0 )
	end
end

function GM:PlayerCanPickupWeapon(client, weapon)
	if client:IsArrested() then return false end
	if weapon.PlayerUse == false then return false end
	if client:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons then return true end

	if GAMEMODE.Config.license and not client:GetDarkRPVar("HasGunlicense") and not client:GetTable().RPLicenseSpawn then
		if GAMEMODE.NoLicense[string.lower(weapon:GetClass())] or not weapon:IsWeapon() then
			return true
		end
		return false
	end

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerCanPickupWeapon then
		RPExtraTeams[client:Team()].PlayerCanPickupWeapon(client, weapon)
	end
	return true
end

local function removelicense(client)
	if not IsValid(client) then return end
	client:GetTable().RPLicenseSpawn = false
end

local function SetPlayerModel(client, cmd, args)
	if not args[1] then return end
	client.rpChosenModel = args[1]
end
concommand.Add("_rp_ChosenModel", SetPlayerModel)

function GM:PlayerSetModel(client)
	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerSetModel then
		return RPExtraTeams[client:Team()].PlayerSetModel(client)
	end

	local EndModel = ""
	if GAMEMODE.Config.enforceplayermodel then
		local TEAM = RPExtraTeams[client:Team()]
		if not TEAM then return end

		if type(TEAM.model) == "table" then
			local ChosenModel = client.rpChosenModel or client:GetInfo("apex_playermodel")
			ChosenModel = string.lower(ChosenModel)

			local found
			for _,Models in pairs(TEAM.model) do
				if ChosenModel == string.lower(Models) then
					EndModel = Models
					found = true
					break
				end
			end

			if not found then
				EndModel = TEAM.model[math.random(#TEAM.model)]
			end
		else
			EndModel = TEAM.model
		end

		client:SetModel(EndModel)
	else
		local cl_playermodel = client:GetInfo("cl_playermodel")
		local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
		client:SetModel( modelname )
	end
end

function GM:PlayerInitialSpawn(client)
	self.BaseClass:PlayerInitialSpawn(client)
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") has joined the game", nil, Color(0, 130, 255))
	client.bannedfrom = {}
	client.DarkRPVars = client.DarkRPVars or {}
	client:NewData()
	client.SID = client:UserID()
				client:SetDarkRPVar( "ration", "no" )
				timer.Simple(780, function() if client:IsValid() then client:SetDarkRPVar( "ration", "yes" ) client:Notify "You can now collect your hourly ration." client:ConCommand( "play buttons/blip1.wav" ) end end )

	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and v.deleteSteamID == client:SteamID64() and v.dt then
			v.SID = client.SID
			if v.Setowning_ent then
				v:Setowning_ent(client)
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex())
			client["max"..v:GetClass()] = (client["max"..v:GetClass()] or 0) + 1
			if v.dt and v.Setowning_ent then v:Setowning_ent(client) end
		end
	end
end

local function formatDarkRPValue(value)
	if value == nil then return "nil" end

	if isentity(value) and not IsValid(value) then return "NULL" end
	if isentity(value) and value:IsPlayer() then return string.format("Entity [%s][Player]", value:EntIndex()) end

	return tostring(value)
end

local meta = FindMetaTable("Player")
function meta:SetDarkRPVar(var, value, target)
	if not IsValid(self) then return end
	target = target or RecipientFilter():AddAllPlayers()

	hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value

	value = formatDarkRPValue(value)

	umsg.Start("DarkRP_PlayerVar", target)
		-- The index because the player handle might not exist clientside yet
		umsg.Short(self:EntIndex())
		umsg.String(var)
		umsg.String(value)
	umsg.End()
end

function meta:SetSelfDarkRPVar(var, value)
	self.privateDRPVars = self.privateDRPVars or {}
	self.privateDRPVars[var] = true

	self:SetDarkRPVar(var, value, self)
end

function meta:GetDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

local function SendDarkRPVars(client)
	if client.DarkRPVarsSent and client.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	client.DarkRPVarsSent = CurTime()

	local sendtable = {}
	for k,v in player.Iterator() do
		sendtable[v] = {}
		for a,b in pairs(v.DarkRPVars or {}) do
			if not (v.privateDRPVars or {})[a] or client == v then
				sendtable[v][a] = b
			end
		end
	end
	net.Start("DarkRP_InitializeVars")
		net.WriteTable(sendtable)
	net.Send(client)
end
concommand.Add("_sendDarkRPvars", SendDarkRPVars)

local function refreshDoorData(client, _, args)
	if client.DoorDataSent and client.DoorDataSent > (CurTime() - 0.5) then return end
	client.DoorDataSent = CurTime()

	local ent = Entity(tonumber(args[1]) or -1)
	if not IsValid(ent) or not ent.DoorData then return end

	net.Start("DarkRP_DoorData")
		net.WriteEntity(ent)
		net.WriteTable(ent.DoorData)
	net.Send(client)
	client.DRP_DoorMemory = client.DRP_DoorMemory or {}
	client.DRP_DoorMemory[ent] = table.Copy(ent.DoorData)
end
concommand.Add("_RefreshDoorData", refreshDoorData)

function GM:PlayerSelectSpawn(client)
	local spawn = self.BaseClass:PlayerSelectSpawn(client)

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerSelectSpawn then
		RPExtraTeams[client:Team()].PlayerSelectSpawn(client, spawn)
	end

	local POS
	if spawn and spawn.GetPos then
		POS = spawn:GetPos()
	else
		POS = client:GetPos()
	end

	local CustomSpawnPos = apex.db.RetrieveTeamSpawnPos(client)
	if GAMEMODE.Config.customspawns and not client:IsArrested() and CustomSpawnPos then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end

	-- Spawn where died in certain cases
	if GAMEMODE.Config.strictsuicide and client:GetTable().DeathPos then
		POS = client:GetTable().DeathPos
	end

	if client:IsArrested() then
		POS = apex.db.RetrieveJailPos() or client:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end

	-- Make sure the player doesn't get stuck in something
	POS = GAMEMODE:FindEmptyPos(POS, {client}, 600, 30, Vector(16, 16, 64))

	return spawn, POS
end

function GM:PlayerSpawn(client)
	self.BaseClass:PlayerSpawn(client)

	player_manager.SetPlayerClass(client, "player_DarkRP")

	client:SetNoCollideWithTeammates(false)
	client:CrosshairEnable()
	client:UnSpectate()
	client:SetHealth(tonumber(GAMEMODE.Config.startinghealth) or 100)

	if not GAMEMODE.Config.showcrosshairs then
		client:CrosshairDisable()
	end

	-- Kill any colormod
	SendUserMessage("blackScreen", client, false)
	client:SetPos(Vector(-4208.889160, 3195.598145, 547.843750))
	--if GAMEMODE.Config.babygod and not client.IsSleeping and not client.Babygod then
	-- Cheecky way to to get players not to die while being inside train.
	if not client.Babygod then
		timer.Destroy(client:EntIndex() .. "babygod")

		client.Babygod = true
		client:GodEnable()
		local c = client:GetColor()
		client:SetRenderMode(RENDERMODE_TRANSALPHA)
		client:SetColor(Color(c.r, c.g, c.b, 100))
		client:SetCollisionGroup(COLLISION_GROUP_WORLD)
		timer.Create(client:EntIndex() .. "babygod", 2, 0, function()
			if not IsValid(client) or not client.Babygod then return end
			if client:GetPos():Distance(Vector(-4215.968750, 3197.494873, 528.031250)) < 180 then return end
			timer.Destroy(client:EntIndex() .. "babygod")
			client.Babygod = nil
			client:SetColor(Color(c.r, c.g, c.b, c.a))
			client:GodDisable()
			client:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end)
	end
	client.IsSleeping = false

	hook.Call("UpdatePlayerSpeed", GAMEMODE, client)

	client:Extinguish()
	if client:GetActiveWeapon() and IsValid(client:GetActiveWeapon()) then
		client:GetActiveWeapon():Extinguish()
	end

	for k,v in ipairs(ents.FindByClass("predicted_viewmodel")) do -- Money printer ignite fix
		v:Extinguish()
	end

	if client.firedWhileDead then
		client.firedWhileDead = nil
		client:ChangeTeam(GAMEMODE.DefaultTeam)
	end

	client:GetTable().StartHealth = client:Health()
	gamemode.Call("PlayerSetModel", client)
	gamemode.Call("PlayerLoadout", client)

	local _, pos = self:PlayerSelectSpawn(client)
	client:SetPos(pos)

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerSpawn then
		RPExtraTeams[client:Team()].PlayerSpawn(client)
	end

	local oldname = client:GetPData("oldname", "")
	if oldname != "" and oldname != client:Nick() then
		client:SetPData("oldname", "")
		apex.db.StoreRPName(client, oldname)
		apex.db.Log("Player changed their name from " .. oldname .. " to " .. client:Nick(), nil, Color(0, 130, 255))
	end

	client:AllowFlashlight(true)
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") spawned")
end

local function selectDefaultWeapon(client)
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = client:GetInfo("cl_defaultweapon")

	if client:HasWeapon(cl_defaultweapon) then
		client:SelectWeapon(cl_defaultweapon)
	end
end

function GM:OnPlayerChangedTeam(client, oldTeam, newTeam)
end

function GM:PlayerLoadout(client)
	if client:IsArrested() then return end

	player_manager.RunClass(client, "Spawn")

	client:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function() removelicense(client) end)

	local Team = client:Team() or 1

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].weapons or {}) do
		client:Give(v)
	end

	if RPExtraTeams[client:Team()].PlayerLoadout then
		local val = RPExtraTeams[client:Team()].PlayerLoadout(client)
		if val == true then
			selectDefaultWeapon(client)
			return
		end
	end

	for k, v in pairs(self.Config.DefaultWeapons) do
		client:Give(v)
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(client, "apex_tool")) or client:IsAdmin()  then
		client:Give("gmod_tool")
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(client, "apex_tool")) or client:IsAdmin() then
		client:Give("weapon_keypadchecker")
	end

	if client:HasPriv("apex_commands") and GAMEMODE.Config.AdminsCopWeapons then
		client:Give("door_ram")
		client:Give("arrest_stick")
		client:Give("unarrest_stick")
		client:Give("stunstick")
		client:Give("weaponchecker")
	end

	selectDefaultWeapon(client)
end

local function removeDelayed(ent, client)
	local removedelay = GAMEMODE.Config.entremovedelay

	ent.deleteSteamID = client:SteamID64()
	timer.Create("Remove"..ent:EntIndex(), removedelay, 1, function()
		for _, pl in player.Iterator() do
			if IsValid(pl) and IsValid(ent) and pl:SteamID64() == ent.deleteSteamID then
				ent.SID = pl.SID
				ent.deleteSteamID = nil
				return
			end
		end

		SafeRemoveEntity(ent)
	end)
end

function GM:PlayerDisconnected(client)
	self.BaseClass:PlayerDisconnected(client)
	timer.Destroy(client:SteamID64() .. "jobtimer")
	timer.Destroy(client:SteamID64() .. "propertytax")
	timer.Destroy(client:SteamID64() .. "XPTimer")

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass()
		for _, customEnt in pairs(DarkRPEntities) do
			if class == customEnt.ent and v.SID == client.SID then
				removeDelayed(v, client)
				break
			end
		end
		if v:IsVehicle() and v.SID == client.SID then
			removeDelayed(v, client)
		end
	end

	local isMayor = RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].mayor
	if isMayor then
		for _, ent in pairs(client.lawboards or {}) do
			if IsValid(ent) then
				removeDelayed(ent, client)
			end
		end
	end

	GAMEMODE.vote.DestroyVotesWithEnt(client)

	if isMayor and tobool(GetConVarNumber("DarkRP_LockDown")) then -- Stop the lockdown
		GAMEMODE:UnLockdown(client)
	end

	if IsValid(client.SleepRagdoll) then
		client.SleepRagdoll:Remove()
	end

	client:UnownAll()
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") disconnected", nil, Color(0, 130, 255))

	if RPExtraTeams[client:Team()] and RPExtraTeams[client:Team()].PlayerDisconnected then
		RPExtraTeams[client:Team()].PlayerDisconnected(client)
	end
end

local function PlayerDoorCheck()
	for k, client in player.Iterator() do
		local trace = client:GetEyeTrace()
		if IsValid(trace.Entity) and (trace.Entity:IsDoor() or trace.Entity:IsVehicle()) and client.LookingAtDoor != trace.Entity and trace.HitPos:Distance(client:GetShootPos()) < 410 then
			client.LookingAtDoor = trace.Entity -- Variable that prevents streaming to clients every frame

			trace.Entity.DoorData = trace.Entity.DoorData or {}

			local DoorString = "Data:\
"
			for key, v in pairs(trace.Entity.DoorData) do
				DoorString = DoorString .. key.."\t\t".. tostring(v) .. "\
"
			end

			if not client.DRP_DoorMemory or not client.DRP_DoorMemory[trace.Entity] then
				net.Start("DarkRP_DoorData")
					net.WriteEntity(trace.Entity)
					net.WriteTable(trace.Entity.DoorData)
				net.Send(client)
				client.DRP_DoorMemory = client.DRP_DoorMemory or {}
				client.DRP_DoorMemory[trace.Entity] = table.Copy(trace.Entity.DoorData)
			else
				for key, v in pairs(trace.Entity.DoorData) do
					if not client.DRP_DoorMemory[trace.Entity][key] or client.DRP_DoorMemory[trace.Entity][key] != v then
						client.DRP_DoorMemory[trace.Entity][key] = v
						umsg.Start("DRP_UpdateDoorData", client)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String(tostring(v))
						umsg.End()
					end
				end

				for key, v in pairs(client.DRP_DoorMemory[trace.Entity]) do
					if not trace.Entity.DoorData[key] then
						client.DRP_DoorMemory[trace.Entity][key] = nil
						umsg.Start("DRP_UpdateDoorData", client)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String("nil")
						umsg.End()
					end
				end
			end
		elseif client.LookingAtDoor != trace.Entity then
			client.LookingAtDoor = nil
		end
	end
end
timer.Create("RP_DoorCheck", 0.1, 0, PlayerDoorCheck)

function GM:GetFallDamage( client, flFallSpeed )
		return flFallSpeed / 15
end

local InitPostEntityCalled = false
function GM:InitPostEntity()
	InitPostEntityCalled = true

	local physData = physenv.GetPerformanceSettings()
	physData.MaxVelocity = 2000
	physData.MaxAngularVelocity	= 3636

	physenv.SetPerformanceSettings(physData)

	game.ConsoleCommand("sv_allowcslua 0")
	game.ConsoleCommand("physgun_DampingFactor 0.9")
	game.ConsoleCommand("sv_sticktoground 0")
	game.ConsoleCommand("sv_airaccelerate 100")

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass()
		if GAMEMODE.Config.unlockdoorsonstart and v:IsDoor() then
			v:Fire("unlock", "", 0)
		end
	end

	self:ReplaceChatHooks()
end

function GM:PlayerLeaveVehicle(client, vehicle)
	if GAMEMODE.Config.autovehiclelock and vehicle:OwnedBy(client) then
		vehicle:KeysLock()
	end
	self.BaseClass:PlayerLeaveVehicle(client, vehicle)
end

local function ClearDecals()
	if GAMEMODE.Config.decalcleaner then
		for _, p in pairs( player.GetAll() ) do
			p:ConCommand("r_cleardecals")
		end
	end
end
timer.Create("RP_DecalCleaner", GM.Config.decaltimer, 0, ClearDecals)

function GM:PlayerSpray()

	return not GAMEMODE.Config.allowsprays
end

function GM:PlayerNoClip(client)
	-- Default action for noclip is to disallow it
	return false
end

function GM:PlayerSpawnRagdoll( client, model )
	if ( not client:IsAdmin() ) then
		GAMEMODE:Notify(client, 1, 4, "Disabled until futher notice.")
		return false
	else
		return true
	end
end





hook.Add("PlayerDeath", "Player Dies", function(client, weapon, killer)
	if client:GetDarkRPVar("money") and client:GetDarkRPVar("money") != 0 then

	local money = client:GetDarkRPVar("money")
	DarkRPCreateMoneyBag(client:GetPos() + Vector(0,0,16), money)
	client:AddMoney(-money)
	client:ChangeTeam( TEAM_CITIZEN, true )

	end

			if client:IsArrested() then
				client:unArrest()
			end

	client:SendLua("surface.PlaySound('death03.mp3')")



	if killer:IsPlayer() then
	killedby = killer:Nick()
	end

	if not killer:IsPlayer() or killer == client then
	killedby = tostring(killer)
		if string.find(string.lower(killedby), "trigger_hurt") then
		killedby = "the world"
		end

		if string.find(string.lower(killedby), "worldspawn") then
		killedby = "the world"
		end

		if string.find(string.lower(killedby), "npc") then
		killedby = "an NPC"
		end

		if string.find(string.lower(killedby), "vehicle") then
		killedby = "a vehicle"
		end

	end

	if killer == client then
		killedby = "yourself"
	end

	umsg.Start( "KilledBy", client )
		umsg.String( killedby )
	umsg.End()

	client:ConCommand("SpawnTimer")

	if ( client:IsVIP() ) then
		client:SendLua("spawntime = 10")
	end
end)

util.AddNetworkString("apex.time")

local nextSend = 0
hook.Add("Think", "Send Server Time", function()
	if ( nextSend > CurTime() ) then return end
	nextSend = CurTime() + 0.5

	local shour = tonumber(os.date("%H"));
	local sminute = tonumber(os.date("%M"));

	if sminute < 10 then
		sminute = "0" .. sminute
	end

	if shour < 10 then
		shour = "0" .. shour
	end

	stime = shour .. ":" .. sminute

	net.Start("apex.time")
		net.WriteString(stime)
	net.Broadcast()
end)

hook.Add("PlayerSpray", "DisablePlayerSpray", function(client )
	return true
end)

hook.Add( "PlayerSay", "Donate Page Command", function(client, text)
	if ( text == "!rules" ) then
		client:SendLua([[gui.OpenURL("http://www.apex-roleplay.com/index.php?threads/half-life-2-rp-server-rules.2/")]])
	end
end)