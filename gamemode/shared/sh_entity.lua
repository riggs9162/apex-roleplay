/*---------------------------------------------------------
Shared part
---------------------------------------------------------*/

local playerMeta = FindMetaTable("Player")
ALWAYS_RAISED = {}
ALWAYS_RAISED["weapon_physcannon"] = true
ALWAYS_RAISED["weapon_physgun"] = true
ALWAYS_RAISED["gmod_tool"] = true
ALWAYS_RAISED["keys"] = true
ALWAYS_RAISED["pocket"] = true
ALWAYS_RAISED["weaponchecker"] = true
ALWAYS_RAISED["thc_adminstick"] = true
ALWAYS_RAISED["weapon_frag"] = true
ALWAYS_RAISED["breachingcharge"] = true
ALWAYS_RAISED["weaponchecker"] = true

function playerMeta:isWepRaised()
	local weapon = self.GetActiveWeapon(self)
	local override = hook.Run("ShouldWeaponBeRaised", self, weapon)

	-- Allow the hook to check first.
	if (override != nil) then
		return override
	end

	-- Some weapons may have their own properties.
	if (IsValid(weapon)) then
		-- If their weapon is always raised, return true.

		if (weapon.IsAlwaysRaised or ALWAYS_RAISED[weapon.GetClass(weapon)]) or string.match(weapon.GetClass(weapon), "pill") then
			return true
		-- Return false if always lowered.
		elseif (weapon.IsAlwaysLowered or weapon.NeverRaised) then
			return false
		end
	else
		return true
	end

	if (!self.GetNetVar) then
		return true
	end

	-- If the player has been forced to have their weapon lowered.
	if (self:GetNetVar("restricted")) then
		return false
	end

	-- Let the config decide before actual results.
	--if (nut.config.get("wepAlwaysRaised")) then
	--	return true
	--end

	-- Returns what the gamemode decides.
	return self:GetNetVar("raised", false)
end

local meta = FindMetaTable("Entity")

function meta:IsOwnable()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if ((class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") or
			(GAMEMODE.Config.allowvehicleowning and self:IsVehicle() and (not IsValid(self:GetParent()) or not self:GetParent():IsVehicle()))) then
			return true
		end
	return false
end

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:DoorIndex()
	return self:EntIndex() - game.MaxPlayers()
end

function GM:DoorToEntIndex(num)
	return num + game.MaxPlayers()
end

function meta:IsOwned()
	self.DoorData = self.DoorData or {}

	if IsValid(self.DoorData.Owner) then return true end

	return false
end

function meta:GetDoorOwner()
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	return self.DoorData.Owner
end

function meta:IsMasterOwner(client)
	if client == self:GetDoorOwner() then
		return true
	end

	return false
end

function meta:OwnedBy(client)
	if client == self:GetDoorOwner() then return true end
	self.DoorData = self.DoorData or {}

	if self.DoorData.ExtraOwners then
		local People = string.Explode(";", self.DoorData.ExtraOwners)
		for k,v in pairs(People) do
			if tonumber(v) == client:UserID() then return true end
		end
	end

	return false
end

function meta:AllowedToOwn(client)
	self.DoorData = self.DoorData or {}
	if not self.DoorData then return false end
	if self.DoorData.AllowedToOwn and string.find(self.DoorData.AllowedToOwn, client:UserID()) then
		return true
	end
	return false
end

local playerMeta = FindMetaTable("Player")
function playerMeta:IsCombine()
	if not IsValid(self) then return false end
	local Team = self:Team()
	return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[Team]
end

function playerMeta:CanAfford(amount)
	if not amount or self.DarkRPUnInitialized then return false end
	return math.floor(amount) >= 0 and (self:GetDarkRPVar("money") or 0) - math.floor(amount) >= 0
end

/*---------------------------------------------------------
 Clientside part
 ---------------------------------------------------------*/
local lastDataRequested = 0 -- Last time doordata was requested
if CLIENT then
	function meta:DrawOwnableInfo()
		if LocalPlayer():InVehicle() then return end

		local pos = {x = ScrW()/2, y = ScrH() / 2}

		local ownerstr = ""

		if self.DoorData == nil and lastDataRequested < (CurTime() - 0.7) then
			RunConsoleCommand("_RefreshDoorData", self:EntIndex())
			lastDataRequested = CurTime()

			return
		end

		for k,v in player.Iterator() do
			if self:OwnedBy(v) then
				ownerstr = ownerstr .. v:Nick() .. "\n"
			end
		end

		if type(self.DoorData.AllowedToOwn) == "string" and self.DoorData.AllowedToOwn != "" and self.DoorData.AllowedToOwn != ";" then
			local names = {}
			for a,b in pairs(string.Explode(";", self.DoorData.AllowedToOwn)) do
				if b != "" and IsValid(Player(tonumber(b))) then
					table.insert(names, Player(tonumber(b)):Nick())
				end
			end
			ownerstr = ownerstr .. apex.language.GetPhrase("keys_other_allowed", table.concat(names, "\n"))
		elseif type(self.DoorData.AllowedToOwn) == "number" and IsValid(Player(self.DoorData.AllowedToOwn)) then
			ownerstr = ownerstr .. apex.language.GetPhrase("keys_other_allowed", Player(self.DoorData.AllowedToOwn):Nick())
		end

		self.DoorData.title = self.DoorData.title or ""

		local blocked = self.DoorData.NonOwnable
		local st = self.DoorData.title .. "\n"
		local superadmin = LocalPlayer():IsSuperAdmin()
		local whiteText = true -- false for red, true for white text

		if superadmin and blocked then
			st = st .. apex.language.GetPhrase("keys_allow_ownership") .. "\n"
		end

		if self.DoorData.TeamOwn then
			st = st .. apex.language.GetPhrase("keys_owned_by") .."\n"

			for k, v in pairs(self.DoorData.TeamOwn) do
				if v then
					st = st .. RPExtraTeams[k].name .. "\n"
				end
			end
		elseif self.DoorData.GroupOwn then
			st = st .. apex.language.GetPhrase("keys_owned_by") .."\n"
			st = st .. self.DoorData.GroupOwn .. "\n"
		end

		if self:IsOwned() then
			if superAdmin then
				if ownerstr != "" then
					st = st .. apex.language.GetPhrase("keys_owned_by") .."\n" .. ownerstr
				end
				st = st ..apex.language.GetPhrase("keys_disallow_ownership") .. "\n"
			elseif not blocked and ownerstr != "" then
				st = st .. apex.language.GetPhrase("keys_owned_by") .. "\n" .. ownerstr
			end
		elseif not blocked then
			if superAdmin then
				st = apex.language.GetPhrase("keys_unowned") .."\n".. apex.language.GetPhrase("keys_disallow_ownership")
				if not self:IsVehicle() then
					st = st .. "\n"..apex.language.GetPhrase("keys_cops")
				end
			elseif not self.DoorData.GroupOwn and not self.DoorData.TeamOwn then
				whiteText = false
				st = apex.language.GetPhrase("keys_unowned")
			end
		end

		if self:IsVehicle() then
			for k,v in player.Iterator() do
				if v:GetVehicle() == self then
					whiteText = true
					st = st .. "\n" .. "Driver: " .. v:Nick()
				end
			end
		end

			draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
			draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)

	end

	return
end

/*---------------------------------------------------------
 Serverside part
 ---------------------------------------------------------*/

function meta:KeysLock()
	self:Fire("lock", "", 0)

	if isfunction(self.Lock) then self:Lock(true) end -- SCars

	hook.Call("onKeysLocked", nil, self)
end

function meta:KeysUnLock()
	self:Fire("unlock", "", 0)
	if self:GetClass()=="func_door" then
			self:Fire("Open", "", 0)
	end


	if isfunction(self.UnLock) then self:UnLock(true) end -- SCars

	hook.Call("onKeysUnlocked", nil, self)
end

local time = false
local function SetDoorOwnable(client)
	if time then
		client:Notify( apex.language.GetPhrase("have_to_wait", "0.1", "/toggleownable"))
		return ""
	end
	time = true
	timer.Simple(0.1, function() time = false end)

	if not client:IsSuperAdmin() then
		client:Notify( "You need the apex_doorManipulation privilege")
		return ""
	end

	local trace = client:GetEyeTrace()
	local ent = trace.Entity
	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or client:GetPos():Distance(ent:GetPos()) > 115 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return
	end

	if IsValid( ent:GetDoorOwner() ) then
		ent:UnOwn(ent:GetDoorOwner())
	end
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.NonOwnable = not ent.DoorData.NonOwnable
	-- Save it for future map loads
	apex.db.StoreDoorOwnability(ent)
	client.LookingAtDoor = nil -- Send the new data to the client who is looking at the door :D
	return ""
end
apex.commands.Register("/toggleownable", SetDoorOwnable)

local time3 = false
local function SetDoorGroupOwnable(client, arg)
	if time3 then
		client:Notify( apex.language.GetPhrase("have_to_wait", "0.1", "/togglegroupownable"))
		return ""
	end
	time3 = true
	timer.Simple(0.1, function() time3 = false end)

	local trace = client:GetEyeTrace()

	if not client:IsSuperAdmin() then
		client:Notify( "You need the apex_doorManipulation privilege")
		return ""
	end

	local ent = trace.Entity

	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or client:GetPos():Distance(ent:GetPos()) > 115 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return
	end

	if not RPExtraTeamDoors[arg] and arg != "" then client:Notify( "Door group does not exist!") return "" end

	ent:UnOwn()


	ent.DoorData = ent.DoorData or {}
	ent.DoorData.TeamOwn = nil
	ent.DoorData.GroupOwn = arg
--	print(arg)

	if arg == "" then
		ent.DoorData.GroupOwn = nil
		ent.DoorData.TeamOwn = nil
	end

	-- Save it for future map loads
	apex.db.SetDoorGroup(ent, arg)
	apex.db.StoreTeamDoorOwnability(ent)

	client.LookingAtDoor = nil

	client:Notify( "Door group set successfully")
	return ""
end
apex.commands.Register("/togglegroupownable", SetDoorGroupOwnable)

local time4 = false
local function SetDoorTeamOwnable(client, arg)
	if time4 then
		client:Notify( apex.language.GetPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time4 = true
	timer.Simple( 0.1, function() time4 = false end )
	local trace = client:GetEyeTrace()

	local ent = trace.Entity
	if not client:IsSuperAdmin() then
		client:Notify( "You need the apex_doorManipulation privilege")
		return ""
	end

	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or client:GetPos():Distance(ent:GetPos()) > 115 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return ""
	end

	arg = tonumber(arg)
	if not RPExtraTeams[arg] and arg != nil then client:Notify( "Job does not exist!") return "" end
	if IsValid(ent:GetDoorOwner()) then
		ent:UnOwn(ent:GetDoorOwner())
	end

	ent.DoorData = ent.DoorData or {}
	ent.DoorData.GroupOwn = nil
	local decoded = {}
	if ent.DoorData.TeamOwn then
		for k, v in pairs(string.Explode("\n", ent.DoorData.TeamOwn)) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
	end
	if arg then
		decoded[arg] = not decoded[arg]
		if decoded[arg] == false then
			decoded[arg] = nil
		end
		if table.Count(decoded) == 0 then
			ent.DoorData.TeamOwn = nil
		else
			local encoded = ""
			for k, v in pairs(decoded) do
				if v then
					encoded = encoded .. k .. "\n"
				end
			end
			ent.DoorData.TeamOwn = encoded -- So we can send it to the client, and store it easily
		end
	else
		ent.DoorData.TeamOwn = nil
	end
	client:Notify( "Door group set successfully")
	apex.db.StoreTeamDoorOwnability(ent)

	ent:UnOwn()
	client.LookingAtDoor = nil
	return ""
end
apex.commands.Register("/toggleteamownable", SetDoorTeamOwnable)

local time2 = false
local function OwnDoor(client)
	if time2 then
		client:Notify( apex.language.GetPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time2 = true
	timer.Simple(0.1, function() time2 = false end)
	local team = client:Team()
	local trace = client:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and client:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		local Owner = trace.Entity:CPPIGetOwner()

		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if client:IsArrested() then
			client:Notify( apex.language.GetPhrase("door_unown_arrested"))
			return ""
		end

		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			client:Notify( apex.language.GetPhrase("door_unownable"))
			return ""
		end

		if trace.Entity:OwnedBy(client) then
			if trace.Entity:IsMasterOwner(client) then
				trace.Entity.DoorData.AllowedToOwn = nil
				trace.Entity.DoorData.ExtraOwners = nil
				trace.Entity:Fire("unlock", "", 0)
			end

			trace.Entity:UnOwn(client)
			client:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			client:GetTable().OwnedNumz = math.abs(client:GetTable().OwnedNumz - 1)
			local GiveMoneyBack = math.floor((((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5)
			hook.Call("PlayerSoldDoor", GAMEMODE, client, trace.Entity, GiveMoneyBack );
			client:AddMoney(GiveMoneyBack)
			local bSuppress = hook.Call("HideSellDoorMessage", GAMEMODE, client, trace.Entity );
			if( !bSuppress ) then
				GAMEMODE:Notify(client, 0, 4, apex.language.GetPhrase("door_sold",  GAMEMODE.Config.currency..(GiveMoneyBack)))
			end

			client.LookingAtDoor = nil
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(client) then
				client:Notify( apex.language.GetPhrase("door_already_owned"))
				return ""
			end

			local iCost = hook.Call("Get".. (trace.Entity:IsVehicle() and "Vehicle" or "Door").."Cost", GAMEMODE, client, trace.Entity );
			if( !client:CanAfford( iCost ) ) then
				client:Notify( trace.Entity:IsVehicle() and apex.language.GetPhrase("vehicle_cannot_afford") or apex.language.GetPhrase("door_cannot_afford") );
				return "";
			end

			local bAllowed, strReason, bSuppress = hook.Call("PlayerBuy"..( trace.Entity:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, client, trace.Entity );
			if( bAllowed == false ) then
				if( strReason and strReason != "") then
					client:Notify( strReason );
				end
				return "";
			end

			local bVehicle = trace.Entity:IsVehicle();

			if bVehicle and (client.Vehicles or 0) >= GAMEMODE.Config.maxvehicles and Owner != client then
				client:Notify( apex.language.GetPhrase("limit", "vehicle"))
				return ""
			end

			if not bVehicle and (client.OwnedNumz or 0) >= GAMEMODE.Config.maxdoors then
				client:Notify( apex.language.GetPhrase("limit", "door"))
				return ""
			end

			client:AddMoney(-iCost)
			if( !bSuppress ) then
				GAMEMODE:Notify( client, 0, 4, bVehicle and apex.language.GetPhrase("vehicle_bought", GAMEMODE.Config.currency, iCost) or apex.language.GetPhrase("door_bought", GAMEMODE.Config.currency, iCost))
			end

			trace.Entity:Own(client)
			hook.Call("PlayerBought"..(bVehicle and "Vehicle" or "Door"), GAMEMODE, client, trace.Entity, iCost);

			if client:GetTable().OwnedNumz == 0 then
				timer.Create(client:UniqueID() .. "propertytax", 270, 0, function() client.DoPropertyTax(client) end)
			end

			client:GetTable().OwnedNumz = client:GetTable().OwnedNumz + 1

			client:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		client.LookingAtDoor = nil
		return ""
	end
	client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
	return ""
end
apex.commands.Register("/toggleown", OwnDoor)

local function UnOwnAll(client, cmd, args)
	local amount = 0
	for k,v in pairs(ents.GetAll()) do
		if v:OwnedBy(client) then
			amount = amount + 1
			v:Fire("unlock", "", 0)
			v:UnOwn(client)
			client:AddMoney(math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)))
			client:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end
	client:GetTable().OwnedNumz = 0
	client:Notify(string.format("You have sold "..amount.." doors for " .. GAMEMODE.Config.currency .. amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)) .. "!"))
	return ""
end
apex.commands.Register("/unownalldoors", UnOwnAll)

function meta:AddAllowed(client)
	self.DoorData = self.DoorData or {}
	self.DoorData.AllowedToOwn = self.DoorData.AllowedToOwn and self.DoorData.AllowedToOwn .. ";" .. tostring(client:UserID()) or tostring(client:UserID())
end

function meta:RemoveAllowed(client)
	self.DoorData = self.DoorData or {}
	if self.DoorData.AllowedToOwn then self.DoorData.AllowedToOwn = string.gsub(self.DoorData.AllowedToOwn, tostring(client:UserID())..".?", "") end
	if string.sub(self.DoorData.AllowedToOwn or "", -1) == ";" then self.DoorData.AllowedToOwn = string.sub(self.DoorData.AllowedToOwn, 1, -2) end
end

function meta:addDoorOwner(client)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	self.DoorData.ExtraOwners = self.DoorData.ExtraOwners and self.DoorData.ExtraOwners .. ";" .. tostring(client:UserID()) or tostring(client:UserID())
	self:RemoveAllowed(client)
end

function meta:removeDoorOwner(client)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	if self.DoorData.ExtraOwners then self.DoorData.ExtraOwners = string.gsub(self.DoorData.ExtraOwners, tostring(client:UserID())..".?", "") end
	if string.sub(self.DoorData.ExtraOwners or "", -1) == ";" then self.DoorData.ExtraOwners = string.sub(self.DoorData.ExtraOwners, 1, -2) end
end

function meta:Own(client)
	self.DoorData = self.DoorData or {}
	if self:AllowedToOwn(client) then
		self:addDoorOwner(client)
		return
	end

	local Owner = self:CPPIGetOwner()

 	-- Increase vehicle count
	if self:IsVehicle() then
		if IsValid(client) then
			client.Vehicles = client.Vehicles or 0
			client.Vehicles = client.Vehicles + 1
		end

		-- Decrease vehicle count of the original owner
		if IsValid(Owner) and Owner != client then
			Owner.Vehicles = Owner.Vehicles or 1
			Owner.Vehicles = Owner.Vehicles - 1
		end
	end

	if self:IsVehicle() then
		self:CPPISetOwner(client)
	end

	if not self:IsOwned() and not self:OwnedBy(client) then
		self.DoorData.Owner = client
	end
end

function meta:UnOwn(client)
	self.DoorData = self.DoorData or {}
	if not client then
		client = self:GetDoorOwner()

		if not IsValid(client) then return end
	end

	if self:IsMasterOwner(client) then
		self.DoorData.Owner = nil
	else
		self:removeDoorOwner(client)
	end

	self:removeDoorOwner(client)
	client.LookingAtDoor = nil
end

local function SetDoorTitle(client, args)
	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	if client:IsSuperAdmin() then
		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			apex.db.StoreDoorTitle(trace.Entity, args)
			client.LookingAtDoor = nil
			return ""
		end
	elseif trace.Entity.DoorData.NonOwnable then
		GAMEMODE:Notify(client, 1, 6, apex.language.GetPhrase("need_admin", "/title"))
	end

	if not trace.Entity:OwnedBy(client) then
		GAMEMODE:Notify(client, 1, 6, apex.language.GetPhrase("door_need_to_own", "/title"))
		return ""
	end
	trace.Entity.DoorData.title = args

	client.LookingAtDoor = nil
	return ""
end
apex.commands.Register("/title", SetDoorTitle)

local function RemoveDoorOwner(client, args)
	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = GAMEMODE:FindPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
		client:Notify( apex.language.GetPhrase("door_rem_owners_unownable"))
		return ""
	end

	if not target then
		client:Notify( apex.language.GetPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end

	if not trace.Entity:OwnedBy(client) then
		client:Notify( apex.language.GetPhrase("do_not_own_ent"))
		return ""
	end

	if trace.Entity:AllowedToOwn(target) then
		trace.Entity:RemoveAllowed(target)
	end

	if trace.Entity:OwnedBy(target) then
		trace.Entity:removeDoorOwner(target)
	end

	client.LookingAtDoor = nil
	return ""
end
apex.commands.Register("/removeowner", RemoveDoorOwner)
apex.commands.Register("/ro", RemoveDoorOwner)

local function AddDoorOwner(client, args)
	local trace = client:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or client:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "vehicle/door"))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = GAMEMODE:FindPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
		client:Notify( apex.language.GetPhrase("door_add_owners_unownable"))
		return ""
	end

	if not target then
		client:Notify( apex.language.GetPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end

	if not trace.Entity:OwnedBy(client) then
		client:Notify( apex.language.GetPhrase("do_not_own_ent"))
		return ""
	end

	if trace.Entity:OwnedBy(target) or trace.Entity:AllowedToOwn(target) then
		client:Notify( apex.language.GetPhrase("apex_add_owner_already_owns_door", client:Nick()))
		return ""
	end

	trace.Entity:AddAllowed(target)

	client.LookingAtDoor = nil

	return ""
end
apex.commands.Register("/addowner", AddDoorOwner)
apex.commands.Register("/ao", AddDoorOwner)