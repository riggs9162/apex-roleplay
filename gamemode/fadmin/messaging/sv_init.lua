util.AddNetworkString("FAdmin_ConsoleMessage")

function FAdmin.Messages.SendMessage(client, MsgType, text)
	if client:EntIndex() == 0 then
		ServerLog("FAdmin: "..text .. "\n")
		print("FAdmin: "..text)
		return
	end

	client:Notify(text)
end

function FAdmin.Messages.SendMessageAll(text, MsgType)
	FAdmin.Log("FAdmin message to everyone: "..text)

	for _,client in player.Iterator() do
		client:Notify(text)
	end
end

function FAdmin.Messages.ConsoleNotify(client, message)
	for k, v in player.Iterator() do
		if v:IsAdmin() then
			net.Start("FAdmin_ConsoleMessage", client)
				net.WriteString(message)
			net.Send(client)
		end
	end
end

function FAdmin.Messages.ActionMessage(client, target, messageToPly, MessageToTarget, LogMSG)
	if not target then return end
	local Targets = (target.IsPlayer and target:IsPlayer() and target:Nick()) or ""

	local plyNick = IsValid(client) and client:IsPlayer() and client:Nick() or "Console"
	local steamID64 = IsValid(client) and client:IsPlayer() and client:SteamID64() or "Console"

	if client != target then
		if type(target) == "table" then
			for k,v in pairs(target) do
				local suffix = ((k == #target-1) and " and ") or (k != #target and ", ") or ""
				local Name = (v == client and "yourself") or v:Nick()

				if v != client then FAdmin.Messages.SendMessage(v, 2, string.format(MessageToTarget, plyNick)) end
				Targets = Targets..Name..suffix
				break
			end
		else
			FAdmin.Messages.SendMessage(target, 2, string.format(MessageToTarget, plyNick))
		end

		FAdmin.Messages.SendMessage(client, 4, string.format(messageToPly, Targets))

	else
		FAdmin.Messages.SendMessage(client, 4, string.format(messageToPly, "yourself"))
	end

	local action = plyNick.." (".. steamID64 .. ") ".. string.format(LogMSG, Targets:gsub("yourself", "themselves"))
	FAdmin.Log("FAdmin Action: " .. action)
	FAdmin.Messages.ConsoleNotify(player.GetAll(), action)
end