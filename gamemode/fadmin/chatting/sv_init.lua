local function ToAdmins(client, cmd, args)
	if not args[1] then return end

	local text = table.concat(args, " ")
	local RP = RecipientFilter()

	RP:AddPlayer(client)
	for k,v in player.Iterator() do
		if v:IsAdmin() then
			RP:AddPlayer(v)
		end
	end



	umsg.Start("FAdmin_ReceiveAdminMessage", RP)
		umsg.Entity(client)
		umsg.String(text)
	umsg.End()


end

FAdmin.StartHooks["Chatting"] = function()
	FAdmin.Commands.AddCommand("adminhelp", ToAdmins)
	FAdmin.Commands.AddCommand("//", ToAdmins)
end
