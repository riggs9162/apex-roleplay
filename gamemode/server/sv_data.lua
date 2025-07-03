/*---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------*/
local teamSpawns = {}
local jailPos = {}
local createSpawnPos,
	setUpNonOwnableDoors,
	setUpTeamOwnableDoors,
	setUpGroupDoors,
	createJailPos

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function apex.initDatabase()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.begin()
		-- Gotta love the difference between SQLite and MySQL
		local AUTOINCREMENT = MySQLite.CONNECTED_TO_MYSQL and "AUTO_INCREMENT" or "AUTOINCREMENT"

		-- Create the table for the convars used in DarkRP
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_cvar(
				var VARCHAR(25) NOT NULL PRIMARY KEY,
				value INTEGER NOT NULL
			);
		]])

		-- Table that holds all position data (jail, zombie spawns etc.)
		-- Queue these queries because other queries depend on the existence of the darkrp_position table
		-- Race conditions could occur if the queries are executed simultaneously
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_position(
				id INTEGER NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
				map VARCHAR(45) NOT NULL,
				type CHAR(1) NOT NULL,
				x INTEGER NOT NULL,
				y INTEGER NOT NULL,
				z INTEGER NOT NULL
			);
		]])

		-- team spawns require extra data
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_jobspawn(
				id INTEGER NOT NULL PRIMARY KEY,
				team INTEGER NOT NULL
			);
		]])

		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.queueQuery([[
				ALTER TABLE darkrp_jobspawn ADD FOREIGN KEY(id) REFERENCES darkrp_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE;
			]])
		end

		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS playerinformation(
				uid BIGINT NOT NULL,
				steamID VARCHAR(50) NOT NULL PRIMARY KEY
			)
		]])
		-- Player information
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_player(
				uid BIGINT NOT NULL PRIMARY KEY,
				rpname VARCHAR(45),
				salary INTEGER NOT NULL DEFAULT 45,
				wallet INTEGER NOT NULL,
				UNIQUE(rpname)
			);
		]])

		-- Door data
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_door(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				title VARCHAR(25),
				isLocked BOOLEAN,
				isDisabled BOOLEAN NOT NULL DEFAULT FALSE,
				PRIMARY KEY(idx, map)
			);
		]])

		-- Some doors are owned by certain teams
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_jobown(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				job INTEGER NOT NULL,

				PRIMARY KEY(idx, map, job)
			);
		]])

		-- Door groups
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_doorgroups(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				doorgroup VARCHAR(100) NOT NULL,

				PRIMARY KEY(idx, map)
			)
		]])

		-- SQlite doesn't really handle foreign keys strictly, neither does MySQL by default
		-- So to keep the DB clean, here's a manual partial foreign key enforcement
		-- For now it's deletion only, since updating of the common attribute doesn't happen.

		-- MySQL trigger
		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.query("show triggers", function(data)
				-- Check if the trigger exists first
				if data then
					for k,v in pairs(data) do
						if v.Trigger == "JobPositionFKDelete" then
							return
						end
					end
				end

				MySQLite.query("SHOW PRIVILEGES", function(data)
					if not data then return end

					local found;
					for k,v in pairs(data) do
						if v.Privilege == "Trigger" then
							found = true
							break;
						end
					end

					if not found then return end
					MySQLite.query([[
						CREATE TRIGGER JobPositionFKDelete
							AFTER DELETE ON darkrp_position
							FOR EACH ROW
								IF OLD.type = "T" THEN
									DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
								END IF
						;
					]])
				end)
			end)
		else -- SQLite triggers, quite a different syntax
			MySQLite.query([[
				CREATE TRIGGER IF NOT EXISTS JobPositionFKDelete
					AFTER DELETE ON darkrp_position
					FOR EACH ROW
					WHEN OLD.type = "T"
					BEGIN
						DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
					END;
			]])
		end
	MySQLite.commit(function() -- Initialize the data after all the tables have been created

		-- Update older version of database to the current database
		-- Only run when one of the older tables exist
		local updateQuery = [[SELECT name FROM sqlite_master WHERE type="table" AND name="darkrp_cvars";]]
		if MySQLite.CONNECTED_TO_MYSQL then
			updateQuery = [[show tables like "darkrp_cvars";]]
		end

		MySQLite.queryValue(updateQuery, function(data)
			if data == "darkrp_cvars" then
				print("UPGRADING DATABASE!")
				updateDatabase()
			end
		end)

		setUpNonOwnableDoors()
		setUpTeamOwnableDoors()
		setUpGroupDoors()

		MySQLite.query("SELECT * FROM darkrp_cvar;", function(settings)
			for k,v in pairs(settings or {}) do
				RunConsoleCommand(v.var, v.value)
			end
		end)

		jailPos = jailPos or {}
		MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
			for k,v in pairs(data or {}) do
				table.insert(jailPos, v)
			end

			if table.Count(jailPos) == 0 then
				createJailPos()
				return
			end

			jail_positions = nil
		end)

		MySQLite.query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = "..map..";", function(data)
			if not data or table.Count(data) == 0 then
				createSpawnPos()
				return
			end

			team_spawn_positions = nil

			teamSpawns = data
		end)

		if MySQLite.CONNECTED_TO_MYSQL then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
									--so he walks around with the settings from the SQLite database
			for k,v in player.Iterator() do
				local UniqueID = MySQLite.SQLStr(v:UniqueID())
				MySQLite.query([[SELECT * FROM darkrp_player WHERE uid = ]].. UniqueID ..[[;]], function(data)
					if not data or not data[1] then return end

					local Data = data[1]
					v:SetDarkRPVar("rpname", Data.rpname)
					v:SetSelfDarkRPVar("salary", Data.salary)
					v:SetDarkRPVar("money", Data.wallet)
				end)
			end
		end

		hook.Call("DarkRPDBInitialized")
	end)
end

/*---------------------------------------------------------------------------
Updating the older database to work with the current version
(copy as much as possible over)
---------------------------------------------------------------------------*/
local function updateDatabase()
	print("CONVERTING DATABASE")
	-- Start transaction.
	MySQLite.begin()

	-- CVars
	MySQLite.query([[DELETE FROM darkrp_cvar;]])
	MySQLite.query([[INSERT INTO darkrp_cvar SELECT v.var, v.value FROM darkrp_cvars v;]])
	MySQLite.query([[DROP TABLE darkrp_cvars;]])

	-- Positions
	MySQLite.query([[DELETE FROM darkrp_position;]])

	-- Team spawns
	MySQLite.query([[INSERT INTO darkrp_position SELECT NULL, p.map, "T", p.x, p.y, p.z FROM darkrp_tspawns p;]])
	MySQLite.query([[
		INSERT INTO darkrp_jobspawn
			SELECT new.id, old.team FROM darkrp_position new JOIN darkrp_tspawns old ON
				new.map = old.map AND new.x = old.x AND new.y = old.y AND new.z = old.Z
			WHERE new.type = "T";
	]])
	MySQLite.query([[DROP TABLE darkrp_tspawns;]])

	-- Jail positions
	MySQLite.query([[INSERT INTO darkrp_position SELECT NULL, p.map, "J", p.x, p.y, p.z FROM darkrp_jailpositions p;]])
	MySQLite.query([[DROP TABLE darkrp_jailpositions;]])

	-- Doors
	MySQLite.query([[DELETE FROM darkrp_door;]])
	MySQLite.query([[INSERT INTO darkrp_door SELECT old.idx - ]] .. game.MaxPlayers() .. [[, old.map, old.title, old.locked, old.disabled FROM darkrp_doors old;]])

	MySQLite.query([[DROP TABLE darkrp_doors;]])
	MySQLite.query([[DROP TABLE darkrp_teamdoors;]])
	MySQLite.query([[DROP TABLE darkrp_groupdoors;]])

	MySQLite.commit()


	local count = MySQLite.queryValue("SELECT COUNT(*) FROM darkrp_wallets;") or 0
	for i = 0, count, 1000 do -- SQLite selecting limit
		MySQLite.query([[SELECT darkrp_wallets.steam, amount, salary, name FROM darkrp_wallets
			LEFT OUTER JOIN darkrp_salaries ON darkrp_salaries.steam = darkrp_wallets.steam
			LEFT OUTER JOIN darkrp_rpnames ON darkrp_rpnames.steam = darkrp_wallets.steam LIMIT 1000 OFFSET ]]..i..[[;]], function(data)

			-- Separate transaction for the player data
			MySQLite.begin()

			for k,v in pairs(data or {}) do
				local uniqueID = util.CRC("gm_" .. v.steam .. "_gm")

				MySQLite.query([[INSERT INTO darkrp_player VALUES(]]
					..uniqueID..[[,]]
					..((v.name == "NULL" or not v.name) and "NULL" or MySQLite.SQLStr(v.name))..[[,]]
					..((v.salary == "NULL" or not v.salary) and 0 or v.salary)..[[,]]
					..v.amount..[[);]])
			end

			if count - i < 1000 then -- the last iteration
				MySQLite.query([[DROP TABLE darkrp_wallets;]])
				MySQLite.query([[DROP TABLE darkrp_salaries;]])
				MySQLite.query([[DROP TABLE darkrp_rpnames;]])
			end

			MySQLite.commit()
		end)
	end
end

/*---------------------------------------------------------
 positions
 ---------------------------------------------------------*/
function createSpawnPos()
	local map = string.lower(game.GetMap())
	if not team_spawn_positions then return end

	for k, v in pairs(team_spawn_positions) do
		if v[1] == map then
			table.insert(teamSpawns, {id = k, map = v[1], x = v[3], y = v[4], z = v[5], team = v[2]})
		end
	end
	team_spawn_positions = nil -- We're done with this now.
end

function createJailPos()
	if not jail_positions then return end
	local map = string.lower(game.GetMap())

	MySQLite.begin()
		MySQLite.query([[DELETE FROM darkrp_position WHERE type = "J" AND map = ]].. MySQLite.SQLStr(map)..[[;]])
		for k, v in pairs(jail_positions) do
			if map == string.lower(v[1]) then
				MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
				table.insert(jailPos, {map = map, x = v[2], y = v[3], z = v[4]})
			end
		end
	MySQLite.commit()
end

local JailIndex = 1 -- Used to circulate through the jailpos table
function apex.db.StoreJailPos(client, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(client:GetPos()))
	MySQLite.queryValue("SELECT COUNT(*) FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
			GAMEMODE:Notify(client, 0, 4,  apex.language.GetPhrase("created_first_jailpos"))

			return
		end

		if addingPos then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")

			table.insert(jailPos, {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"})
			GAMEMODE:Notify(client, 0, 4,  apex.language.GetPhrase("added_jailpos"))
		else
			MySQLite.query("DELETE FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function()
				MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")


				jailPos = {[1] = {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"}}
				GAMEMODE:Notify(client, 0, 5,  apex.language.GetPhrase("reset_add_jailpos"))
			end)
		end
	end)

	JailIndex = 1
end

function apex.db.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	if not jailPos then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local oldestPos = jailPos[JailIndex]
	JailIndex = JailIndex % #jailPos + 1

	return oldestPos and Vector(oldestPos.x, oldestPos.y, oldestPos.z)
end

function apex.db.SaveSetting(setting, value)
	MySQLite.query("REPLACE INTO darkrp_cvar VALUES("..MySQLite.SQLStr(setting)..", "..MySQLite.SQLStr(value)..");")
end

function apex.db.CountJailPos()
	return table.Count(jailPos or {})
end

function apex.db.StoreTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[DELETE FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND id IN (SELECT id FROM darkrp_jobspawn WHERE team = ]] .. t .. [[)]])

	MySQLite.query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if not id then return end
			MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)

	print(apex.language.GetPhrase("created_spawnpos", team.GetName(t)))
end

function apex.db.AddTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if type(id) == "boolean" then return end
			MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)
end

function apex.db.RemoveTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	MySQLite.query([[SELECT darkrp_position.id FROM darkrp_position
		NATURAL JOIN darkrp_jobspawn
		WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
		AND team = ]].. t ..[[;]], function(data)

		MySQLite.begin()
		for k,v in pairs(data or {}) do
			-- The trigger will make sure the values get deleted from the jobspawn as well
			MySQLite.query([[DELETE FROM darkrp_position WHERE id = ]]..v.id..[[;]])
		end
		MySQLite.commit()
	end)

	for k,v in pairs(teamSpawns) do
		if tonumber(v.team) == t then
			teamSpawns[k] = nil
		end
	end

	if callback then callback() end
end

function apex.db.RetrieveTeamSpawnPos(client)
	local map = string.lower(game.GetMap())
	local t = client:Team()

	local returnal = {}

	if teamSpawns then
		for k,v in pairs(teamSpawns) do
			if v.map == map and tonumber(v.team) == t then
				table.insert(returnal, Vector(v.x, v.y, v.z))
			end
		end
		return (table.Count(returnal) > 0 and returnal) or nil
	end
end

/*---------------------------------------------------------
Players
 ---------------------------------------------------------*/
function apex.db.StoreRPName(client, name)
	if not name or string.len(name) < 2 then return end
	client:SetDarkRPVar("rpname", name)

	MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. client:UniqueID() .. ";")
end

function apex.db.RetrieveRPNames(client, name, callback)
	MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = "..MySQLite.SQLStr(name)..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function apex.db.RetrievePlayerData(client, callback, failed, attempts)
	attempts = attempts or 0

	if attempts > 3 then return failed() end

	MySQLite.query("SELECT rpname, wallet, salary FROM darkrp_player WHERE uid = " .. client:UniqueID() .. ";", callback, function()
		apex.db.RetrievePlayerData(client, callback, failed, attempts + 1)
	end)
end

function apex.db.CreatePlayerData(client, name, wallet, salary)
	MySQLite.query(string.format([[REPLACE INTO playerinformation VALUES(%s, %s);]], MySQLite.SQLStr(client:UniqueID()), MySQLite.SQLStr(client:SteamID64())))
	MySQLite.query([[REPLACE INTO darkrp_player VALUES(]] ..
			client:UniqueID() .. [[, ]] ..
			MySQLite.SQLStr(name)  .. [[, ]] ..
			salary  .. [[, ]] ..
			wallet .. ");")
end

function apex.db.StoreMoney(client, amount)
	if not IsValid(client) then return end
	if amount < 0  then return end

	MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. client:UniqueID())
end

function apex.db.ResetAllMoney(client,cmd,args)
	if client:EntIndex() != 0 and not client:IsSuperAdmin() then return end
	MySQLite.query("UPDATE darkrp_player SET wallet = "..GAMEMODE.Config.startingmoney.." ;")
	for k,v in player.Iterator() do
		v:SetDarkRPVar("money", GAMEMODE.Config.startingmoney)
	end
	if client:IsPlayer() then
		GAMEMODE:NotifyAll(0,4, apex.language.GetPhrase("reset_money", client:Nick()))
	else
		GAMEMODE:NotifyAll(0,4, apex.language.GetPhrase("reset_money", "Console"))
	end
end
concommand.Add("apex_resetallmoney", apex.db.ResetAllMoney)

function apex.db.PayPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:AddMoney(-amount)
	ply2:AddMoney(amount)
end

function apex.db.StoreSalary(client, amount)
	client:SetSelfDarkRPVar("salary", math.floor(amount))

	MySQLite.query([[UPDATE darkrp_player SET salary = ]] .. amount .. [[ WHERE uid = ]] .. client:UniqueID())

	return amount
end

function apex.db.RetrieveSalary(client, callback)
	if not IsValid(client) then return 0 end

	if client:GetDarkRPVar("salary") then return callback and callback(client:GetDarkRPVar("salary")) end -- First check the cache.

	MySQLite.queryValue("SELECT salary FROM darkrp_player WHERE uid = " .. client:UniqueID() .. ";", function(r)
		local normal = 0
		if not r then
			client:SetSelfDarkRPVar("salary", normal)
			callback(normal)
		else
			callback(r)
		end
	end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
function apex.db.StoreDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}
	local nonOwnable = ent.DoorData.NonOwnable

	MySQLite.query([[REPLACE INTO darkrp_door VALUES(]]..
		ent:DoorIndex() ..[[, ]] ..
		MySQLite.SQLStr(map) .. [[, ]] ..
		(ent.DoorData.title and MySQLite.SQLStr(ent.DoorData.title) or "NULL") .. [[, ]] ..
		"NULL" .. [[, ]] ..
		(ent.DoorData.NonOwnable and 1 or 0) .. [[);]])
end

function apex.db.StoreDoorTitle(ent, text)
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.title = text
	MySQLite.query("UPDATE darkrp_door SET title = " .. MySQLite.SQLStr(text) .. " WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:DoorIndex() .. ";")
end

function setUpNonOwnableDoors()
	MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.NonOwnable = tobool(row.isDisabled)
				if r.isLocked != nil then
					e:Fire((tobool(row.locked) and "" or "un").."lock", "", 0)
				end
				e.DoorData.title = row.title != "NULL" and row.title or nil
			end
		end
	end)
end

function apex.db.StoreTeamDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}

	MySQLite.query("DELETE FROM darkrp_jobown WHERE idx = " .. ent:DoorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
	for k,v in pairs(string.Explode("\n", ent.DoorData.TeamOwn or "")) do
		if v == "" then continue end

		MySQLite.query("INSERT INTO darkrp_jobown VALUES("..ent:DoorIndex() .. ", "..MySQLite.SQLStr(map) .. ", " .. v .. ");")
	end
end

function setUpTeamOwnableDoors()
	MySQLite.query("SELECT idx, job FROM darkrp_jobown WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.TeamOwn = e.DoorData.TeamOwn or ""
				e.DoorData.TeamOwn = (e.DoorData.TeamOwn == "" and row.job) or (e.DoorData.TeamOwn .. "\n" .. row.job)
			end
		end
	end)
end

function apex.db.SetDoorGroup(ent, group)
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local index = ent:DoorIndex()

	if group == "" then
		MySQLite.query("DELETE FROM darkrp_doorgroups WHERE map = " .. map .. " AND idx = " .. index .. ";")
		return
	end

	MySQLite.query("REPLACE INTO darkrp_doorgroups VALUES(" .. index .. ", " .. map .. ", " .. MySQLite.SQLStr(group) .. ");");
end

function setUpGroupDoors()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.query("SELECT idx, doorgroup FROM darkrp_doorgroups WHERE map = " .. map, function(data)
		if not data then return end

		for _, row in pairs(data) do
			local ent = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))

			if not IsValid(ent) then
				continue
			end

			ent.DoorData = ent.DoorData or {}
			ent.DoorData.GroupOwn = row.doorgroup
		end
	end)
end

/*---------------------------------------------------------
 Logging
 ---------------------------------------------------------*/

local function AdminLog(message, colour)
	local RF = RecipientFilter()
	for k,v in player.Iterator() do
		if not v:IsAdmin() then return end
		local canHear = hook.Call("CanSeeLogMessage", GAMEMODE, v, message, colour)

		if canHear then
			RF:AddPlayer(v)
		end
	end
	umsg.Start("DRPLogMsg", RF)
		umsg.Short(colour.r)
		umsg.Short(colour.g)
		umsg.Short(colour.b) -- Alpha is not needed
		umsg.String(message)
	umsg.End()
end

function apex.db.Log(text, force, colour)
	if colour then
		AdminLog(text, colour)
	end
	if (not GAMEMODE.Config.logging or not text) and not force then return end
	if not apex.db.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("DarkRP_logs", "DATA") then
			file.CreateDir("DarkRP_logs")
		end
		apex.db.File = "DarkRP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(apex.db.File, os.date().. "\t".. text)
		return
	end
	file.Append(apex.db.File, "\n"..os.date().. "\t"..(text or ""))
end
