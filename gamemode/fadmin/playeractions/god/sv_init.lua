local function God(client, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(client, "God") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_godded") then
			target:FAdmin_SetGlobal("FAdmin_godded", true)
			target:GodEnable()
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "Godded %s", "You were godded by %s", "Godded %s")
end

local function Ungod(client, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(client, "God") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_godded") then
			target:FAdmin_SetGlobal("FAdmin_godded", false)
			target:GodDisable()
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "Ungodded %s", "You were ungodded by %s", "Ungodded %s")
end

FAdmin.StartHooks["God"] = function()
	FAdmin.Commands.AddCommand("God", God)
	FAdmin.Commands.AddCommand("Ungod", Ungod)

	FAdmin.Access.AddPrivilege("God", 2)
end

hook.Add("PlayerSpawn", "FAdmin_God", function()
	for _, client in player.Iterator() do
		if client:FAdmin_GetGlobal("FAdmin_godded") then
			client:GodEnable()
		end
	end
end)