local function Freeze(client, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	local time = tonumber(args[2] or 0)
	local timeText = time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(client, "Freeze", target) then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_frozen") then
			target:FAdmin_SetGlobal("FAdmin_frozen", true)
			target:Lock()

			if time == 0 then continue end

			timer.Simple(time, function()
				if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_frozen") then return end
				target:FAdmin_SetGlobal("FAdmin_frozen", false)
				target:UnLock()
			end)
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "You have frozen %s " .. timeText, "You were frozen by %s " .. timeText, "Froze %s " .. timeText)
end

local function Unfreeze(client, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(client, "Freeze", target) then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_frozen") then
			target:FAdmin_SetGlobal("FAdmin_frozen", false)
			target:UnLock()
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "You have unfrozen %s", "You were unfrozen by %s", "Unfroze %s")
end

FAdmin.StartHooks["Freeze"] = function()
	FAdmin.Commands.AddCommand("freeze", Freeze)
	FAdmin.Commands.AddCommand("unfreeze", Unfreeze)

	FAdmin.Access.AddPrivilege("Freeze", 2)
end

hook.Add("PlayerSpawnObject", "FAdmin_jail", function(client)
	if client:FAdmin_GetGlobal("FAdmin_frozen") then
		return false
	end
end)
