/*---------------------------------------------------------------------------
Doors
---------------------------------------------------------------------------*/
local function ccDoorOwn(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_own"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(client)
	apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-owned a door with rp_own", nil, Color(30, 30, 30))
end
concommand.Add("apex_own", ccDoorOwn)

local function ccDoorUnOwn(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unown"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-unowned a door with rp_unown", nil, Color(30, 30, 30))
end
concommand.Add("apex_unown", ccDoorUnOwn)

local function unownAll(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unown"))
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if not IsValid(target) then
		client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: " .. tostring(args)))
		return
	end
	target:UnownAll()
	apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-unowned all doors owned by " .. target:Nick(), nil, Color(30, 30, 30))
end
concommand.Add("apex_unownall", unownAll)

local function ccAddOwner(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_add_owner"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				client:PrintMessage(2, apex.language.GetPhrase("apex_add_owner_already_owns_door", target))
			end
		else
			trace.Entity:Own(target)
		end
	else
	client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: " .. tostring(args)))
	end
apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-added a door owner with rp_addowner", nil, Color(30, 30, 30))
end
concommand.Add("apex_add_owner", ccAddOwner)

local function ccRemoveOwner(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2,  apex.language.GetPhrase("need_admin", "apex_remove_owner"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:removeDoorOwner(target)
		end
	else
	client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: " .. tostring(args)))
	end
apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-removed a door owner with rp_removeowner", nil, Color(30, 30, 30))
end
concommand.Add("apex_remove_owner", ccRemoveOwner)

local function ccLock(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2,  apex.language.GetPhrase("need_admin", "apex_lock"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	client:PrintMessage(2, "Locked.")

	trace.Entity:KeysLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 1, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-locked a door with rp_lock (locked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("apex_lock", ccLock)

local function ccUnLock(client, cmd, args)
	if client:EntIndex() == 0 then
		return
	end

	if not client:HasPriv("apex_commands") then
		client:PrintMessage(2,  apex.language.GetPhrase("need_admin", "apex_unlock"))
		return
	end

	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	client:PrintMessage(2, "Unlocked.")
	trace.Entity:KeysUnLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 0, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-unlocked a door with rp_unlock (ulocked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("apex_unlock", ccUnLock)

/*---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------*/
local function ccTell(client, cmd, args)
	if not args[1] then return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2,  apex.language.GetPhrase("need_admin", "apex_tell"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()

		if client:EntIndex() == 0 then
			apex.db.Log("Console did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("apex_tell", ccTell)

util.AddNetworkString("apex.admin.tell.all")
concommand.Add("apex_tell_all", function(client, cmd, args, argsStr)
	if ( !args[1] ) then return end
	if ( client:EntIndex() != 0 and !client:HasPriv("apex_commands") ) then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_tell_all"))
		return
	end

	net.Start("apex.admin.tell.all")
		net.WriteString(argsStr)
	net.Broadcast()

	if ( client:EntIndex() == 0 ) then
		apex.db.Log("Console did apex_tell_all \"" .. argsStr .. "\"", nil, Color(30, 30, 30))
	else
		apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") did apex_tell_all \"" .. argsStr .. "\"", nil, Color(30, 30, 30))
	end
end)

/*---------------------------------------------------------------------------
Misc
---------------------------------------------------------------------------*/
local function ccRemoveLetters(client, cmd, args)
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands")then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_remove_letters"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		for k, v in ipairs(ents.FindByClass("letter")) do
			if v.SID == target.SID then v:Remove() end
		end
	else
		-- Remove ALL letters
		for k, v in ipairs(ents.FindByClass("letter")) do
			v:Remove()
		end
	end

	if client:EntIndex() == 0 then
		apex.db.Log("Console force-removed all letters", nil, Color(30, 30, 30))
	else
apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-removed all letters", nil, Color(30, 30, 30))
	end
end
concommand.Add("apex_remove_letters", ccRemoveLetters)

local function ccArrest(client, cmd, args)
	if not args[1] then return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_arrest"))
		return
	end

	if apex.db.CountJailPos() == 0 then
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("no_jail_pos"))
		else
			client:PrintMessage(2, apex.language.GetPhrase("no_jail_pos"))
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])
	if target then
		local length = tonumber(args[2])
		if length then
			target:arrest(length, client)
		else
			target:arrest(nil, client)
		end

		if client:EntIndex() == 0 then
			apex.db.Log("Console force-arrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
		apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-arrested " .. target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end

end
concommand.Add("apex_arrest", ccArrest)

local function ccUnarrest(client, cmd, args)
	if not args[1] then return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:unArrest(client)
		if not target:Alive() then target:Spawn() end

		if client:EntIndex() == 0 then
			apex.db.Log("Console force-unarrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
		apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") force-unarrested " .. target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end

end
concommand.Add("apex_unarrest", ccUnarrest)

local function SetXP(client, cmd, args)

	if not client:IsSuperAdmin() then return end
	if not args[2] then client:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then

		target:SetXP(args[2])
		if not target:Alive() then target:Spawn() end

		if client:EntIndex() == 0 then
			apex.db.Log("Console force-set the xp of "..target:SteamName() .." to "..args[2].."XP", nil, Color(0, 255, 255))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set the model of "..target:SteamName() .." to "..args[2].."XP", nil, Color(0, 255, 255))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("apex_set_xp", SetXP)

local function SetModel(client, cmd, args)

	if not client:IsAdmin() then return end
	
	if not args[2] then client:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:SetModel(args[2])
		if not target:Alive() then target:Spawn() end

		if client:EntIndex() == 0 then
			apex.db.Log("Console force-set the model of "..target:SteamName(), nil, Color(0, 255, 255))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set the model of "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("apex_set_model", SetModel)

local function SetArmor(client, cmd, args)

	if not client:IsAdmin() then return end
	
	if not args[2] then client:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then

		target:SetArmor(args[2])

		if not target:Alive() then target:Spawn() end

		if client:EntIndex() == 0 then
			apex.db.Log("Console force-set the armor of "..target:SteamName() .." to: "..args[2], nil, Color(0, 255, 255))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set the model of "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("apex_set_armor", SetArmor)

local function ccSetMoney(client, cmd, args)

	if not client:IsSuperAdmin() then return end

	if not tonumber(args[2]) then client:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if client:EntIndex() != 0 and not client:IsSuperAdmin() then
		client:PrintMessage(2, apex.language.GetPhrase("need_sadmin", "apex_set_money"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if args[3] then
		amount = args[3] == "-" and math.Max(0, client:GetDarkRPVar("money") - amount) or client:GetDarkRPVar("money") + amount
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		apex.db.StoreMoney(target, amount)
		target:SetDarkRPVar("money", amount)

		if client:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s money to: " .. GAMEMODE.Config.currency .. amount)
			nick = "Console"
		else
			client:PrintMessage(2, "Set " .. target:Nick() .. "'s money to: " .. GAMEMODE.Config.currency .. amount)
			nick = client:Nick()
		end
		target:PrintMessage(2, nick .. " set your money to: " .. GAMEMODE.Config.currency .. amount)
		if client:EntIndex() == 0 then
			apex.db.Log("Console set "..target:SteamName().."'s money to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set "..target:SteamName().."'s money to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		end
	else
		if client:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			client:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("apex_set_money", ccSetMoney, function() return {"apex_set_money   <client>   <amount>   [+/-]"} end)

local function ccSetSalary(client, cmd, args)
	if not tonumber(args[2]) then client:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if client:EntIndex() != 0 and not client:IsSuperAdmin() then
		client:PrintMessage(2, apex.language.GetPhrase("need_sadmin", "apex_set_salary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if amount < 0 then
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("invalid_x", "argument", args[2]))
		else
			client:PrintMessage(2, apex.language.GetPhrase("invalid_x", "argument", args[2]))
		end
		return
	end

	if amount > 150 then
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("invalid_x", "argument", args[2].." (<150)"))
		else
			client:PrintMessage(2, apex.language.GetPhrase("invalid_x", "argument", args[2].." (<150)"))
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		apex.db.StoreSalary(target, amount)
		target:SetSelfDarkRPVar("salary", amount)
		if client:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s Salary to: " .. GAMEMODE.Config.currency .. amount)
			nick = "Console"
		else
			client:PrintMessage(2, "Set " .. target:Nick() .. "'s Salary to: " .. GAMEMODE.Config.currency .. amount)
			nick = client:Nick()
		end
		target:PrintMessage(2, nick .. " set your Salary to: " .. GAMEMODE.Config.currency .. amount)
		if client:EntIndex() == 0 then
			apex.db.Log("Console set "..target:SteamName().."'s salary to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set "..target:SteamName().."'s salary to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("apex_set_salary", ccSetSalary)

local function ccSENTSPawn(client, cmd, args)
	if GAMEMODE.Config.adminsents then
		if client:EntIndex() != 0 and not client:IsAdmin() then
			GAMEMODE:Notify(client, 1, 2, apex.language.GetPhrase("need_admin", "gm_spawnsent"))
			return
		end
	end
	Spawn_SENT(client, args[1])
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") spawned SENT "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnsent", ccSENTSPawn)

local function ccVehicleSpawn(client, cmd, args)
	if GAMEMODE.Config.adminvehicles then
		if client:GetNWString("usergroup") == "vip" and (string.match( string.lower(args[1]), "seat" ) or string.match( string.lower(args[1]), "chair" )) then
		--	Spawn_Vehicle(client, args[1])
		--	apex.db.Log(client:Nick().." ("..client:SteamID64()..") spawned Vehicle "..args[1], nil, Color(255, 255, 0))
		elseif client:EntIndex() != 0 and not client:IsAdmin() then
			client:Notify("You are not allowed to spawn this vehicle.")
			return false
		end
	end
	Spawn_Vehicle(client, args[1])
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") spawned Vehicle "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnvehicle", ccVehicleSpawn)

local function ccNPCSpawn(client, cmd, args)
	if GAMEMODE.Config.adminnpcs then
		if client:EntIndex() != 0 and not client:IsAdmin() then
			GAMEMODE:Notify(client, 1, 2, apex.language.GetPhrase("need_admin", "gm_spawnnpc"))
			return
		end
	end
	Spawn_NPC(client, args[1])
	apex.db.Log(client:Nick().." ("..client:SteamID64()..") spawned NPC "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnnpc", ccNPCSpawn)

local function ccSetRPName(client, cmd, args)
	if not args[1] then return end
	if client:EntIndex() != 0 and not client:IsAdmin() then
		client:PrintMessage(2, apex.language.GetPhrase("need_sadmin", "apex_set_name"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("invalid_x", "argument", args[2]))
		else
			client:PrintMessage(2, apex.language.GetPhrase("invalid_x", "argument", args[2]))
		end
	end

	if target then
		local oldname = target:Nick()
		local nick = ""
		apex.db.StoreRPName(target, args[2])
		target:SetDarkRPVar("rpname", args[2])
		if client:EntIndex() == 0 then
			print("Set " .. oldname .. "'s name to: " .. args[2])
			nick = "Console"
		else
			client:PrintMessage(2, "Set " .. oldname .. "'s name to: " .. args[2])
			nick = client:Nick()
		end
		target:PrintMessage(2, nick .. " set your name to: " .. args[2])
		if client:EntIndex() == 0 then
			apex.db.Log("Console set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("apex_set_name", ccSetRPName)

local function ccSetJob(client, cmd, args)
	if not args[1] then return end
	if client:EntIndex() != 0 and not client:IsAdmin() then
		client:PrintMessage(2, apex.language.GetPhrase("need_sadmin", "apex_set_job"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("invalid_x", "argument", args[2]))
		else
			client:PrintMessage(2, apex.language.GetPhrase("invalid_x", "argument", args[2]))
		end
	end

	if target then
		local oldname = target:Nick()
		local nick = ""
		apex.db.StoreRPName(target, args[2])
		target:SetDarkRPVar("job", args[2])
		if client:EntIndex() == 0 then
			print("Set " .. oldname .. "'s job to: " .. args[2])
			nick = "Console"
		else
			client:PrintMessage(2, "Set " .. oldname .. "'s job to: " .. args[2])
			nick = client:Nick()
		end
		target:PrintMessage(2, nick .. " set your job to: " .. args[2])
		if client:EntIndex() == 0 then
			apex.db.Log("Console set "..target:SteamName().."'s job to " .. args[2], nil, Color(30, 30, 30))
		else
			apex.db.Log(client:Nick().." ("..client:SteamID64()..") set "..target:SteamName().."'s job to " .. args[2], nil, Color(30, 30, 30))
		end
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("apex_set_job", ccSetJob)

local function ccCancelVote(client, cmd, args)
	if client:EntIndex() != 0 and not client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_cancel_vote"))
		return
	end

	GAMEMODE.vote.DestroyLast()
	if client:EntIndex() == 0 then
		nick = "Console"
	else
		nick = client:Nick()
	end

	GAMEMODE:NotifyAll(0, 4, nick .. " canceled the last vote")
end
concommand.Add("apex_cancel_vote", ccCancelVote)
