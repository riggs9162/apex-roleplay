local function DoMessage(client, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(client, "Message") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end
	if not args[2] then return end

	client.FAdmin_LastMessageTime = client.FAdmin_LastMessageTime or CurTime() - 2
	if client.FAdmin_LastMessageTime > (CurTime() - 2) then
		FAdmin.Messages.SendMessage(client, 5, "Wait before sending a new message")
		return
	end

	client.FAdmin_LastMessageTime = CurTime()

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) or not args[3] then
		FAdmin.Messages.SendMessage(client, 1, "Player not found")
		return
	end
	local MsgType = tonumber(args[2]) or 2
	for _, target in pairs(targets) do
		if IsValid(target) then
			FAdmin.Messages.SendMessage(target, MsgType, client:Nick()..": ".. args[3])
		end
	end
	if client != targets[1] then FAdmin.Messages.SendMessage(client, MsgType, client:Nick()..": ".. args[3]) end
end


FAdmin.StartHooks["DoMessage"] = function()
	FAdmin.Commands.AddCommand("Message", DoMessage)

	FAdmin.Access.AddPrivilege("Message", 1)-- Anyone can send messages. Why not?
end