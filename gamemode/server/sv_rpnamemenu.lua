// Made by Tomasas http://steamcommunity.com/id/tomasas/

local BlackList = {"nigga", "fag", "gayboy", "penis", "lol", "swag", "yolo", "420", "hack", "cock", "monkey", "dog", "admin", "poop", "nigger", "Gordon Freeman", "meme", "BBC"} //simply insert a name encased in quotes and seperate it with a comma

concommand.Add("c_rpname", function(client, cmd, args)

	if !client.ForcedNameChange and (!client.DarkRPVars or client.DarkRPVars and (client.DarkRPVars.rpname and client.DarkRPVars.rpname != client:SteamName() and client.DarkRPVars.rpname != "NULL")) then return end
	
	for i=1, #BlackList do
		if string.find(string.lower(args[1]), string.lower(BlackList[i])) then
			umsg.Start("_Notify", client)
				umsg.String("This name not allowed!")
				umsg.Short(1)
				umsg.Long(10)
			umsg.End()
			umsg.Start("openRPNameMenu", client)
			umsg.End()
			return
		end
	end
	
	apex.db.RetrieveRPNames(client, args[1], function(taken)
		if client:IsValid() then
			client.ForcedNameChange = nil
			apex.db.StoreRPName(client, args[1])
		end
	end)
end)


hook.Add("PlayerAuthed", "RPNameChecking", function(client)
	timer.Simple(9, function() //let apex load their name before checking
		if !client:IsValid() then return end
		if client.DarkRPVars and (!client.DarkRPVars.rpname or client.DarkRPVars.rpname == client:SteamName() or client.DarkRPVars.rpname == "NULL") then
			umsg.Start("openRPNameMenu", client)
			umsg.End()
		end
	end) 
end)
//�Tomasas 2013