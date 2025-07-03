local function fname(client, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(client, "Force namechange", target) then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
		if IsValid(target) then
			if target:IsAdmin() then client:Notify("That player is a admin, silly.") return end
			target.ForcedNameChange = true
			umsg.Start("openRPNameMenu", target)
			umsg.End()
		end
	end
	FAdmin.Messages.ActionMessage(client, targets, "Forced named change %s", "You were forced to change your name by %s", "Forcenamed changed %s")
end

FAdmin.StartHooks["Force namechange"] = function()
	FAdmin.Commands.AddCommand("fname", fname)

	FAdmin.Access.AddPrivilege("Force namechange", 2)
end