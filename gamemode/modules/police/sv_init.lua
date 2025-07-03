local plyMeta = FindMetaTable("Player")
local finishWarrantRequest
local arrestedPlayers = {}

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:warrant(warranter, reason)	if self.warranted then return end

end

function plyMeta:unWarrant(unwarranter)

end

function plyMeta:requestWarrant(suspect, actor, reason)

end

function plyMeta:wanted(actor, reason)

end

function plyMeta:unWanted(actor)

end

function plyMeta:arrest(time, arrester)
	time = time or GAMEMODE.Config.jailtimer or 120

	self:SetDarkRPVar("Arrested", true)
	hook.Run("playerArrested", self, time, arrester)
	arrestedPlayers[self:SteamID64()] = true

	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if ( GAMEMODE.Config.teletojail and apex.db.CountJailPos() != 0 ) then
		self:Spawn()
	end
end

function plyMeta:unArrest(unarrester)
	if ( !self:IsArrested() ) then return end

	self:SetDarkRPVar("Arrested", false)
	arrestedPlayers[self:SteamID64()] = nil

	self:CleanUpRHC(true)
	hook.Run("playerUnArrested", self)
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
local function CombineRequest(client, args)
	if args == "" then
		GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local t = client:Team()

	local DoSay = function(text)
		if text == "" then
			GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end
		for k, v in player.Iterator() do
			if v:IsCombine() or v == client then
				GAMEMODE:TalkToPerson(v, team.GetColor(client:Team()), apex.language.GetPhrase("request") ..client:Nick(), Color(255,0,0,255), text, client)
			end
		end
	end
	return args, DoSay
end
apex.commands.Register("/ccp", CombineRequest, 1.5)


/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
hook.Add("playerArrested", "Arrested", function(client, time, arrester)
	if client:isWanted() then client:unWanted(arrester) end
	client:unWarrant(arrester)
	client:SetSelfDarkRPVar("HasGunlicense", false)

	client:StripWeapons()
	hook.Call("UpdatePlayerSpeed", GAMEMODE, client)

	if client:IsArrested() then return end -- hasn't been arrested before

/*	client:PrintMessage(HUD_PRINTCENTER, apex.language.GetPhrase("youre_arrested", time))
	for k, v in player.Iterator() do
		if v == client then continue end
		v:PrintMessage(HUD_PRINTCENTER, apex.language.GetPhrase("hes_arrested", client:Name(), time))
	end

	local steamID = client:SteamID64()
	timer.Create(client:UniqueID() .. "jailtimer", time, 1, function()
		if IsValid(client) then client:unArrest() end
		arrestedPlayers[steamID] = nil
	end)
	umsg.Start("GotArrested", client)
		umsg.Float(time)
	umsg.End() */
	client:Notify("You have been arrested!")
end)

hook.Add("playerUnArrested", "Arrested", function(client)
	if client.Sleeping and GAMEMODE.KnockoutToggle then
		GAMEMODE:KnockoutToggle(client, "force")
	end

	-- "Arrested" DarkRPVar is set to false BEFORE this hook however, so it is safe here.
	hook.Call("UpdatePlayerSpeed", GAMEMODE, client)
	GAMEMODE:PlayerLoadout(client)
	if GAMEMODE.Config.telefromjail and (!FAdmin or !client:FAdmin_GetGlobal("fadmin_jailed")) then
		local _, pos = GAMEMODE:PlayerSelectSpawn(client)
		client:SetPos(pos)
	elseif FAdmin and client:FAdmin_GetGlobal("fadmin_jailed") then
		client:SetPos(client.FAdminJailPos)
	end

	timer.Destroy(client:SteamID64() .. "jailtimer")
	client:Notify("You have been unarrested!")
end)

hook.Add("PlayerInitialSpawn", "Arrested", function(client)
	if !arrestedPlayers[client:SteamID64()] then return end
	local time = GAMEMODE.Config.jailtimer
	client:arrest(time)
	GAMEMODE:Notify(client, 0, 5, apex.language.GetPhrase("jail_punishment", time))
end)
