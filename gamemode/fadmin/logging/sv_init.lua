FAdmin.StartHooks["Logging"] = function()
	FAdmin.Access.AddPrivilege("Logging", 3)
	FAdmin.Commands.AddCommand("Logging", function(client, cmd, args)
		if not FAdmin.Access.PlayerHasPrivilege(client, "Logging") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if not tonumber(args[1]) then return end

		local OnOff = (tobool(tonumber(args[1])) and "on") or "off"
		FAdmin.Messages.ActionMessage(client, player.GetAll(), client:Nick().." turned logging "..OnOff, "Logging has been turned "..OnOff, "Turned logging "..OnOff)

		RunConsoleCommand("FAdmin_logging", args[1])
	end)
end

local LogFile
function FAdmin.Log(text, preventServerLog)
	if not text or text == "" then return end
	if not tobool(GetConVarNumber("FAdmin_logging")) then return end
	if not preventServerLog then ServerLog(text .. "\n") end
	if not LogFile then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("fadmin_logs", "DATA") then
			file.CreateDir("fadmin_logs")
		end
		LogFile = "fadmin_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(LogFile, os.date().. "\t".. text)
		return
	end
	file.Append(LogFile, "\n"..os.date().. "\t"..text)
end

hook.Add("PlayerGiveSWEP", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Gave himself a "..class) end)
hook.Add("PlayerSpawnSENT", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("PlayerSpawnSWEP", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("PlayerSpawnProp", "FAdmin_Log", function(client, class)
	if not IsValid(client) then return end
	for k,v in player.Iterator() do
		if v:IsAdmin() then
			v:PrintMessage(HUD_PRINTCONSOLE, client:Nick().." ("..client:SteamID64()..") Spawned a "..class)
		end
	end
	FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)
end)
hook.Add("PlayerSpawnNPC", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("PlayerSpawnVehicle", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("PlayerSpawnEffect", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("PlayerSpawnRagdoll", "FAdmin_Log", function(client, class) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned a "..class)  end)
hook.Add("CanTool", "FAdmin_Log", function(client, tr, toolclass) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Attempted to use tool "..toolclass)
	FAdmin.Log(client:Nick().." ("..client:SteamID64()..") used the tool: "..toolclass, nil, Color(0, 255, 255))
	end)


hook.Add("PlayerLeaveVehicle", "FAdmin_Log", function(client, vehicle) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") exited a "..vehicle:GetClass())  end)
hook.Add("OnNPCKilled", "FAdmin_Log", function(NPC, Killer, Weapon) FAdmin.Log(NPC:GetClass().. " was killed by ".. ((Killer:IsPlayer() and Killer:Nick()) or Killer:GetClass()).. " with a ".. Weapon:GetClass())  end)
hook.Add("OnPlayerChangedTeam", "FAdmin_Log", function(client, oldteam, newteam) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") changed from "..team.GetName(oldteam).. " to ".. team.GetName(newteam)) end)
hook.Add("WeaponEquip", "FAdmin_Log", function(weapon)
		timer.Simple(0, function()
			if not IsValid(weapon) then return end
			local client = weapon:GetOwner()
			if not IsValid(client) or not client:IsPlayer() then return end
			FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Attempted to pick up a "..weapon:GetClass())
		end)
end)

hook.Add("PlayerDeath", "FAdmin_Log", function(client, inflictor, Killer)
	local Nick, SteamID, KillerName, InflictorName = (IsValid(client) and client:Nick() or "N/A"), (IsValid(client) and client:SteamID64() or "N/A"),
		(IsValid(Killer) and (Killer:IsPlayer() and Killer:Nick() or Killer:GetClass()) or "N/A"),
		(IsValid(inflictor) and inflictor:GetClass() or "N/A")
	FAdmin.Log(Nick.." ("..client:SteamID64()..") Got killed by "..KillerName.." with a "..InflictorName)
end)
hook.Add("PlayerSilentDeath", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Got killed silently") end)
hook.Add("PlayerDisconnected", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Disconnected") end)
hook.Add("PlayerInitialSpawn", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned for the first time") end)
hook.Add("PlayerSay", "FAdmin_Log", function(client, text, teamonly, dead) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") [".. ((dead and "dead, ") or "")..(( not teamonly and "team only") or "all") .."] "..text, true) end)
hook.Add("PlayerSpawn", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Spawned") end)
hook.Add("PlayerSpray", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Sprayed his spray") end)
hook.Add("PlayerEnteredVehicle", "FAdmin_Log", function(client, vehicle) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Entered ".. vehicle:GetClass()) end)
hook.Add("EntityRemoved", "FAdmin_Log", function(ent) if IsValid(ent) and ent:GetClass() == "prop_physics" then FAdmin.Log(ent:GetClass().. "(" .. (ent:GetModel() or "<no model>") .. ") Got removed") end end)
hook.Add("PlayerAuthed", "FAdmin_Log", function(client, SteamID, UniqueID) FAdmin.Log(client:Nick().." ("..SteamID..") is Authed") end)
hook.Add("PlayerNoClip", "FAdmin_Log", function(client) FAdmin.Log(client:Nick().." ("..client:SteamID64()..") Attempted to switch noclip") end)
hook.Add("ShutDown", "FAdmin_Log", function() FAdmin.Log("Server succesfully shut down.") end)