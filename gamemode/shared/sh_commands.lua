CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!

-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------

function GM:AddTeamCommands(CTeam, max)
	if CLIENT then return end

	if not self:CustomObjFitsMap(CTeam) then return end
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote or CTeam.RequiresVote then
		apex.commands.Register("/vote"..CTeam.command, function(client)
			if CTeam.RequiresVote and not CTeam.RequiresVote(client, k) then
				GAMEMODE:Notify(client, 1,4, "This job does not require a vote at this moment!")
				return ""
			end
			if type(CTeam.NeedToChangeFrom) == "number" and client:Team() != CTeam.NeedToChangeFrom then
				GAMEMODE:Notify(client, 1,4, apex.language.GetPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, client:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				GAMEMODE:Notify(client, 1,4, apex.language.GetPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name))
				return ""
			end

			if CTeam.customCheck and not CTeam.customCheck(client) then
				GAMEMODE:Notify(client, 1, 4, CTeam.CustomCheckFailMsg or apex.language.GetPhrase("unable", team.GetName(t), ""))
				return ""
			end
			if #player.GetAll() == 1 then
				GAMEMODE:Notify(client, 0, 4, apex.language.GetPhrase("vote_alone"))
				client:ChangeTeam(k)
				return ""
			end
			if not client:ChangeAllowed(k) then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("unable", "/vote"..CTeam.command, "banned/demoted"))
				return ""
			end
			if CurTime() - client:GetTable().LastVoteCop < 80 then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("have_to_wait", math.ceil(80 - (CurTime() - client:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if client:Team() == k then
				GAMEMODE:Notify(client, 1, 4,  apex.language.GetPhrase("unable", CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max != 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 != 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				GAMEMODE:Notify(client, 1, 4,  apex.language.GetPhrase("team_limit_reached",CTeam.name))
				return ""
			end
			GAMEMODE.vote:create(apex.language.GetPhrase("wants_to_be", client:Nick(), CTeam.name), "job", client, 20, function(vote, choice)
				local client = vote.target

				if not IsValid(client) then return end
				if choice >= 0 then
					client:ChangeTeam(k)
				else
					GAMEMODE:NotifyAll(1, 4, apex.language.GetPhrase("has_not_been_made_team", client:Nick(), CTeam.name))
				end
			end)
			client:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		apex.commands.Register("/"..CTeam.command, function(client)
			if client:HasPriv("apex_"..CTeam.command) then
				client:ChangeTeam(k)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not client:IsAdmin()
			or a > 1 and not client:IsSuperAdmin()
			then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("need_admin", CTeam.name))
				return ""
			end

			if not CTeam.RequiresVote and
				(a == 0 and not client:IsAdmin()
				or a == 1 and not client:IsSuperAdmin()
				or a == 2)
			or CTeam.RequiresVote and CTeam.RequiresVote(client, k)
			then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("need_to_make_vote", CTeam.name))
				return ""
			end

			client:ChangeTeam(k)
			return ""
		end)
	else
		apex.commands.Register("/"..CTeam.command, function(client)
			if CTeam.admin == 1 and not client:IsAdmin() then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("need_admin", "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not client:IsSuperAdmin() then
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("need_sadmin", "/"..CTeam.command))
				return ""
			end
			client:ChangeTeam(k)
			return ""
		end)
	end

	concommand.Add("apex_"..CTeam.command, function(client, cmd, args)
		if client:EntIndex() != 0 and not client:IsAdmin() then
			client:PrintMessage(2, apex.language.GetPhrase("need_admin", cmd))
			return
        end

		if CTeam.admin > 1 and not client:IsSuperAdmin() then
			client:PrintMessage(2, apex.language.GetPhrase("need_sadmin", cmd))
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and client:EntIndex() != 0 and not client:IsSuperAdmin() then
				client:PrintMessage(2, apex.language.GetPhrase("need_admin", cmd))
				return
			elseif CTeam.admin > 1 and client:IsSuperAdmin() and client:EntIndex() != 0 then
				client:PrintMessage(2, apex.language.GetPhrase("need_to_make_vote", CTeam.name))
				return
			end
		end

		if not args[1] then return end
		local target = GAMEMODE:FindPlayer(args[1])

        if (target) then
			target:ChangeTeam(k, true)
			if (client:EntIndex() != 0) then
				nick = client:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, nick .. " has made you a " .. CTeam.name .. "!")
        else
			if (client:EntIndex() == 0) then
				print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
			else
				client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
			end
			return
        end
	end)
end

function GM:AddEntityCommands(tblEnt)
	if CLIENT then return end

	local function buythis(client, args)
		if client:IsArrested() then return "" end
		if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, client:Team()) then
			GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("incorrect_job", tblEnt.cmd))
			return ""
		end
		local cmdname = string.gsub(tblEnt.ent, " ", "_")

		if tblEnt.customCheck and not tblEnt.customCheck(client) then
			GAMEMODE:Notify(client, 1, 4, tblEnt.CustomCheckFailMsg or "You're not allowed to purchase this item")
			return ""
		end

		local max = tonumber(tblEnt.max or 3)

		if client["max"..cmdname] and tonumber(client["max"..cmdname]) >= tonumber(max) then
			GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("limit", tblEnt.cmd))
			return ""
		end

		if not client:CanAfford(tblEnt.price) then
			GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("cant_afford", tblEnt.cmd))
			return ""
		end
		client:AddMoney(-tblEnt.price)

		local trace = {}
		trace.start = client:EyePos()
		trace.endpos = trace.start + client:GetAimVector() * 85
		trace.filter = client

		local tr = util.TraceLine(trace)

		local item = ents.Create(tblEnt.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = client
		if item.Setowning_ent then item:Setowning_ent(client) end
		item:SetPos(tr.HitPos)
		item.SID = client.SID
		item.onlyremover = true
		item.allowed = tblEnt.allowed
		item:Spawn()
		local phys = item:GetPhysicsObject()
		if phys:IsValid() then phys:Wake() end

		GAMEMODE:Notify(client, 0, 4, apex.language.GetPhrase("you_bought_x", tblEnt.name, GAMEMODE.Config.currency..tblEnt.price))
		if not client["max"..cmdname] then
			client["max"..cmdname] = 0
		end
		client["max"..cmdname] = client["max"..cmdname] + 1
		return ""
	end
	apex.commands.Register(tblEnt.cmd, buythis)
end
