local function Ignite(client, cmd, args)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	local time = tonumber(args[2] or 10)

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(client, "Ignite", target) then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if IsValid(target) then
			target:Ignite(time, 0)
			target:FAdmin_SetGlobal("FAdmin_ignited", true)

			timer.Simple(time, function()
				if IsValid(target) then target:FAdmin_SetGlobal("FAdmin_ignited", false) end
			end)
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "Ignited %s", "You were ignited by %s", "Ignited %s")
end

local function UnIgnite(client, cmd, args)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(client, "Ignite") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if IsValid(target) then
			target:Extinguish()

			target:FAdmin_SetGlobal("FAdmin_ignited", false)
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "Ignited %s", "You were extinguished by %s", "Extinguished %s")
end


FAdmin.StartHooks["Ignite"] = function()
	FAdmin.Commands.AddCommand("Ignite", Ignite)
	FAdmin.Commands.AddCommand("Unignite", UnIgnite)

	FAdmin.Access.AddPrivilege("Ignite", 2)
end