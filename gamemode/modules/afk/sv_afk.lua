-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autofired and their salary is set to $0 (you can still be killed/vote fired though!).
-- If a player does not use /afk, and they don't do anything for the fire time specified, they will be automatically fired to hobo.

local function AFKDemote(client)
	local rpname = client:Nick()

		GAMEMODE:NotifyAll(0, 5, rpname .. " is now AFK.")
end

local function SetAFK(client)
ServerPlayers = 0
	client:SetDarkRPVar("AFK", not client:GetDarkRPVar("AFK"))

	if client:GetDarkRPVar("AFK") then

for k, v in player.Iterator() do
   ServerPlayers = ServerPlayers + 1
end
		apex.db.RetrieveSalary(client, function(amount) client.OldSalary = amount end)
	--	client.OldJob = client:GetDarkRPVar("job")
		client:ChatPrint("Seems like you are AFK, you will not get any salary/XP before you are back." )
		GAMEMODE:NotifyAll(0, 5, client:Nick() .. " is now AFK.")
		client:SetDarkRPVar("salary", 0)
if ServerPlayers > 60 then
client:Kick("AFK on full server.")
elseif client:IsCombine() then
client:ChangeTeam( TEAM_CITIZEN, true )
client:ConCommand("say /adminhelp AUTOMATED MESSAGE: I was demoted for being AFK as CP.")


end
	else
		GAMEMODE:NotifyAll(1, 5, client:Nick() .. " is no longer AFK.")
		client:ChatPrint("You are not AFK anymore, you should be starting to get salary/XP again." )
		client:SetDarkRPVar("salary", client.OldSalary or 0)
		GAMEMODE:Notify(client, 0, 5, "Welcome back, your salary has now been restored.")
	end
	--client:SetDarkRPVar("job", client:GetDarkRPVar("AFK") and "AFK" or client.OldJob)
	--client:SetDarkRPVar("salary", client:GetDarkRPVar("AFK") and 0 or client.OldSalary or 0)
end
apex.commands.Register("/afk", SetAFK)

local function StartAFKOnPlayer(client)
	client.AFKDemote = CurTime() + GAMEMODE.Config.afkfiretime


end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)






local function AFKTimer(client, key)
	if client:GetDarkRPVar("AFK") then
		client:SetDarkRPVar("AFK", false)
		client:SetDarkRPVar("salary", client.OldSalary or 0)
		client:ChatPrint("You are not AFK anymore, you should be starting to get salary/XP again." )
		GAMEMODE:NotifyAll(1, 5, client:Nick() .. " is no longer AFK.")
	end
	client.AFKDemote = CurTime() + GAMEMODE.Config.afkfiretime
end
hook.Add("KeyPress", "DarkRPKeyReleasedCheck", AFKTimer)

local function KillAFKTimer()
	for id, client in player.Iterator() do
		if client.AFKDemote and CurTime() > client.AFKDemote and not client:GetDarkRPVar("AFK") then
			SetAFK(client)
			AFKDemote(client)
			client.AFKDemote = math.huge
		end
	end
end
hook.Add("Think", "DarkRPKeyPressedCheck", KillAFKTimer)
