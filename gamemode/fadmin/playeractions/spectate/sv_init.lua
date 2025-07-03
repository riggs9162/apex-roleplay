local OnPlayerSay

local function Spectate(client, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(client, "Spectate") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end

	local target = FAdmin.FindPlayer(args[1])
	target = target and target[1] or nil
	target = IsValid(target) and target != client and target or nil

	client.FAdminSpectatingEnt = target
	client.FAdminSpectating = true

	client:ExitVehicle()

	umsg.Start("FAdminSpectate", client)
		umsg.Bool(target == nil) -- Is the player roaming?
		umsg.Entity(client.FAdminSpectatingEnt)
	umsg.End()

	hook.Add("PlayerSay", client, OnPlayerSay)

	local targetText = IsValid(target) and (target:Nick() .. " ("..target:SteamID64()..")") or ""
	FAdmin.Messages.SendMessage(client, 4, "You are now spectating "..targetText)
end

local function SpectateVisibility(client, viewEnt)
	if not client.FAdminSpectating then return end

	if IsValid(client.FAdminSpectatingEnt) then
		AddOriginToPVS(client.FAdminSpectatingEnt:GetShootPos())
	end

	if client.FAdminSpectatePos then
		AddOriginToPVS(client.FAdminSpectatePos)
	end
end
hook.Add("SetupPlayerVisibility", "FAdminSpectate", SpectateVisibility)

local function setSpectatePos(client, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(client, "Spectate") then FAdmin.Messages.SendMessage(client, 5, "No access!") return end

	if not client.FAdminSpectating or not args[3] then return end
	local x, y, z = tonumber(args[1] or 0), tonumber(args[2] or 0), tonumber(args[3] or 0)

	client.FAdminSpectatePos = Vector(x, y, z)
end
concommand.Add("_FAdmin_SpectatePosUpdate", setSpectatePos)

local function endSpectate(client, cmd, args)
	client.FAdminSpectatingEnt = nil
	client.FAdminSpectating = nil
	client.FAdminSpectatePos = nil
	hook.Remove("PlayerSay", client)
end
concommand.Add("_FAdmin_StopSpectating", endSpectate)

local function playerVoice(listener, talker)
	if not IsValid(listener.FAdminSpectatingEnt) then return end

	-- You can hear someone if your spectate target can hear them
	canhear, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener.FAdminSpectatingEnt, talker)
	canHearLocal = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)

	-- you can always hear the person you're spectating
	return canhear or canHearLocal or listener.FAdminSpectatingEnt == talker, surround
end
hook.Add("PlayerCanHearPlayersVoice", "FAdminSpectate", playerVoice)

OnPlayerSay = function(spectator, sender, message, isTeam)
	-- the person is saying it close to where you are roaming
	if spectator.FAdminSpectatePos and sender:GetShootPos():Distance(spectator.FAdminSpectatePos) <= 400 and
		sender:GetShootPos():Distance(spectator:GetShootPos()) > 250 then-- Make sure you don't get it twice

		GAMEMODE:TalkToPerson(spectator, team.GetColor(sender:Team()), sender:Nick(), Color(255, 255, 255, 255), message, sender)
		return
	end

	-- The person you're spectating or someone near the person you're spectating is saying it
	if IsValid(spectator.FAdminSpectatingEnt) and
		sender:GetShootPos():Distance(spectator.FAdminSpectatingEnt:GetShootPos()) <= 300 and
		sender:GetShootPos():Distance(spectator:GetShootPos()) > 250 then
		GAMEMODE:TalkToPerson(spectator, team.GetColor(sender:Team()), sender:Nick(), Color(255, 255, 255, 255), message, sender)
	end
end

FAdmin.StartHooks["Spectate"] = function()
	FAdmin.Commands.AddCommand("Spectate", Spectate)

	FAdmin.Access.AddPrivilege("Spectate", 2)
end