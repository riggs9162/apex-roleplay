/*---------------------------------------------------------
Flammable
---------------------------------------------------------*/
local FlammableProps = {drug = true,
drug_lab = true,
food = true,
gunlab = true,
letter = true,
microwave = true,
money_printer = true,
spawned_shipment = true,
spawned_weapon = true,
spawned_money = true}

local function IsFlammable(ent)
	return FlammableProps[ent:GetClass()] != nil
end

-- FireSpread from SeriousRP
local function FireSpread(e)
	if not e:IsOnFire() then return end

	if e:IsMoneyBag() then
		e:Remove()
	end

	local rand = math.random(0, 300)

	if rand > 1 then return end
	local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))

	for k, v in pairs(en) do
		if not IsFlammable(v) then continue end

		if not v.burned then
			v:Ignite(math.random(5,180), 0)
			v.burned = true
		else
			local color = v:GetColor()
			if (color.r - 51) >= 0 then color.r = color.r - 51 end
			if (color.g - 51) >= 0 then color.g = color.g - 51 end
			if (color.b - 51) >= 0 then color.b = color.b - 51 end
			v:SetColor(color)
			if (color.r + color.g + color.b) < 103 and math.random(1, 100) < 35 then
				v:Fire("enablemotion","",0)
				constraint.RemoveAll(v)
			end
		end
		break -- Don't ignite all entities in sphere at once, just one at a time
	end
end

local function FlammablePropThink()
	for k, v in pairs(FlammableProps) do
		local ens = ents.FindByClass(k)

		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
end
timer.Create("FlammableProps", 0.1, 0, FlammablePropThink)

/*---------------------------------------------------------
Shipments
---------------------------------------------------------*/

local function DropWeapon(client)
	local ent = client:GetActiveWeapon()
	if not IsValid(ent) then
		client:Notify( apex.language.GetPhrase("cannot_drop_weapon"))
		return ""
	end

	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, client, ent)
	if not canDrop then
		client:Notify( apex.language.GetPhrase("cannot_drop_weapon"))
		return ""
	end

	if client:Team() == TEAM_CP or client:Team() == TEAM_OVERWATCH or client:Team() == TEAM_OVERWATCHELITE then
		client:Notify( apex.language.GetPhrase("cannot_drop_weapon"))
		return ""
	end

	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(client)
	umsg.End()
	client.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(client) and IsValid(ent) and ent:GetModel() then
			client:DropDRPWeapon(ent)
		end
	end)
	return ""
end
apex.commands.Register("/drop", DropWeapon)
apex.commands.Register("/dropweapon", DropWeapon)
apex.commands.Register("/weapondrop", DropWeapon)

/*---------------------------------------------------------
Spawning
---------------------------------------------------------*/


function GM:ShowTeam(client)
end

function GM:ShowHelp(client)
end

local function LookPersonUp(client, cmd, args)
	if not args[1] then
		client:PrintMessage(2, apex.language.GetPhrase("invalid_x", "argument", ""))
		return
	end
	local P = GAMEMODE:FindPlayer(args[1])
	if not IsValid(P) then
		if client:EntIndex() != 0 then
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			print(apex.language.GetPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
	if client:EntIndex() != 0 then
		client:PrintMessage(2, "Nick: ".. P:Nick())
		client:PrintMessage(2, "Steam name: "..P:SteamName())
		client:PrintMessage(2, "Steam ID: "..P:SteamID64())
		client:PrintMessage(2, "Job: ".. team.GetName(P:Team()))
		client:PrintMessage(2, "Kills: ".. P:Frags())
		client:PrintMessage(2, "Deaths: ".. P:Deaths())
		if client:IsAdmin() then
			client:PrintMessage(2, "Money: ".. P:GetDarkRPVar("money"))
		end
	else
		print("Nick: ".. P:Nick())
		print("Steam name: "..P:SteamName())
		print("Steam ID: "..P:SteamID64())
		print("Job: ".. team.GetName(P:Team()))
		print("Kills: ".. P:Frags())
		print("Deaths: ".. P:Deaths())

		print("Money: " .. GAMEMODE.Config.currency .. P:GetDarkRPVar("money"))
	end
end
concommand.Add("apex_lookup", LookPersonUp)

/*---------------------------------------------------------
Items
---------------------------------------------------------*/
local function MakeLetter(client, args, type)
	if not GAMEMODE.Config.letters then
		client:Notify(apex.language.GetPhrase("disabled", "/write / /type", ""))
		return ""
	end

	if not client:Alive() then
		client:Notify("You're dead you cannot use /write")
		return ""
	end

	if client.maxletters and client.maxletters >= GAMEMODE.Config.maxletters then
		client:Notify( apex.language.GetPhrase("limit", "letter"))
		return ""
	end

	if CurTime() - client:GetTable().LastLetterMade < 3 then
		client:Notify(apex.language.GetPhrase("have_to_wait", math.ceil(3 - (CurTime() - client:GetTable().LastLetterMade)), "/write / /type"))
		return ""
	end

	client:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\nYours,\n"..client:Nick()
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = client:EyePos()
	tr.endpos = client:EyePos() + 95 * client:GetAimVector()
	tr.filter = client
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter:Setowning_ent(client)
	letter.ShareGravgun = true
	letter:SetPos(trace.HitPos)
	letter.nodupe = true
	letter:Spawn()

	letter:GetTable().Letter = true
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = client.SID

	GAMEMODE:PrintMessageAll(2, apex.language.GetPhrase("created_x", client:Nick(), "mail"))
	if not client.maxletters then
		client.maxletters = 0
	end
	client.maxletters = client.maxletters + 1
	timer.Simple(600, function() if IsValid(letter) then letter:Remove() end end)
end

local function WriteLetter(client, args)
	if args == "" then
		client:Notify(apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	MakeLetter(client, args, 1)
	return ""
end
apex.commands.Register("/write", WriteLetter)

local function TypeLetter(client, args)
	if args == "" then
		client:Notify(apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	MakeLetter(client, args, 2)
	return ""
end
apex.commands.Register("/type", TypeLetter)

local function RemoveLetters(client)
	for k, v in ipairs(ents.FindByClass("letter")) do
		if v.SID == client.SID then v:Remove() end
	end
	client:Notify(apex.language.GetPhrase("cleaned_up", "mails"))
	return ""
end
apex.commands.Register("/removeletters", RemoveLetters)

local function SetPrice(client, args)
	if args == "" then
		client:Notify(apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	local a = tonumber(args)
	if not a then
		client:Notify(apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local b = math.Clamp(math.floor(a), GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap != 0 and GAMEMODE.Config.pricecap) or 500)
	local trace = {}

	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	if not IsValid(tr.Entity) then client:Notify(apex.language.GetPhrase("must_be_looking_at", "gunlab / druglab / microwave")) return "" end

	local class = tr.Entity:GetClass()
	if IsValid(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == client.SID then
		tr.Entity:Setprice(b)
	else
		client:Notify(client, 1, 4, apex.language.GetPhrase("must_be_looking_at", "gunlab / druglab / microwave"))
	end
	return ""
end
apex.commands.Register("/price", SetPrice)
apex.commands.Register("/setprice", SetPrice)

local function BuyPistol(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	if client:IsArrested() then
		client:Notify( apex.language.GetPhrase("unable", "/buy", ""))
		return ""
	end

	if not GAMEMODE.Config.enablebuypistol then
		client:Notify( apex.language.GetPhrase("disabled", "/buy", ""))
		return ""
	end
	if GAMEMODE.Config.noguns then
		client:Notify( apex.language.GetPhrase("disabled", "/buy", ""))
		return ""
	end

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	local class = nil
	local model = nil

	local shipment
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) and GAMEMODE:CustomObjFitsMap(v) then
			shipment = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false

			if not GAMEMODE.Config.restrictbuypistol or
			(GAMEMODE.Config.restrictbuypistol and (not v.allowed[1] or table.HasValue(v.allowed, client:Team()))) then
				canbuy = true
			end

			if v.customCheck and not v.customCheck(client) then
				client:Notify( v.CustomCheckFailMsg or "You're not allowed to purchase this item")
				return ""
			end

			if not canbuy then
				client:Notify( apex.language.GetPhrase("incorrect_job", "/buy"))
				return ""
			end
		end
	end

	if not class then
		client:Notify( apex.language.GetPhrase("unavailable", "weapon"))
		return ""
	end

	if not client:CanAfford(price) then
		client:Notify( apex.language.GetPhrase("cant_afford", "/buy"))
		return ""
	end
	if string.match( class, "hl2rp" ) then cclass = class else cclass = "spawned_weapon" end
	print(cclass)
	local weapon = ents.Create(cclass)
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon.SID = client:SteamID64()
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if shipment.onBought then
		shipment.onBought(client, shipment, weapon)
	end
	hook.Call("playerBoughtPistol", nil, client, shipment, weapon)

	if IsValid( weapon ) then
		client:AddMoney(-price)
		client:Notify( apex.language.GetPhrase("you_bought_x", args, tostring(price)).." tokens.")
	else
		client:Notify( apex.language.GetPhrase("unable", "/buy", args))
	end

	return ""
end
apex.commands.Register("/buy", BuyPistol, 0.2)

local function BuyShipment(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if client.LastShipmentSpawn and client.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
		client:Notify( "Please wait before spawning another shipment.")
		return ""
	end
	client.LastShipmentSpawn = CurTime()

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	if client:IsArrested() then
		client:Notify( apex.language.GetPhrase("unable", "/buyshipment", ""))
		return ""
	end

	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship and GAMEMODE:CustomObjFitsMap(v) then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if client:Team() == b then
					canbecome = true
				end
			end

			if v.customCheck and not v.customCheck(client) then
				client:Notify( v.CustomCheckFailMsg or "You're not allowed to purchase this item")
				return ""
			end

			if not canbecome then
				client:Notify( apex.language.GetPhrase("incorrect_job", "/buyshipment"))
				return ""
			end
		end
	end

	if not found then
		client:Notify( apex.language.GetPhrase("unavailable", "shipment"))
		return ""
	end

	local cost = found.price

	if not client:CanAfford(cost) then
		client:Notify( apex.language.GetPhrase("cant_afford", "shipment"))
		return ""
	end
	print(found.shipmentClass)
	local crate = ents.Create(found.entity or "spawned_shipment")
	crate.SID = client.SID
	crate:Setowning_ent(client)
	--crate:SetContents(foundKey, found.amount)

	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	crate:SetPlayer(client)
	if found.shipmodel then
		crate:SetModel(found.shipmodel)
		crate:PhysicsInit(SOLID_VPHYSICS)
		crate:SetMoveType(MOVETYPE_VPHYSICS)
		crate:SetSolid(SOLID_VPHYSICS)
	end

	local phys = crate:GetPhysicsObject()
	phys:Wake()

	if CustomShipments[foundKey].onBought then
		CustomShipments[foundKey].onBought(client, CustomShipments[foundKey], weapon)
	end
	hook.Call("playerBoughtShipment", nil, client, CustomShipments[foundKey], weapon)

	if IsValid( crate ) then
		client:AddMoney(-cost)
		client:Notify( apex.language.GetPhrase("you_bought_x", args, GAMEMODE.Config.currency .. tostring(cost)))
	else
		client:Notify( apex.language.GetPhrase("unable", "/buyshipment", arg))
	end

	return ""
end
apex.commands.Register("/buyshipment", BuyShipment)

local function BuyVehicle(client, args)
	if client:IsArrested() then
		client:Notify( apex.language.GetPhrase("unable", "/buyvehicle", ""))
		return ""
	end
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local found = false
	for k,v in pairs(CustomVehicles) do
		if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
	end
	if not found then
		client:Notify( apex.language.GetPhrase("unavailable", "vehicle"))
		return ""
	end
	if found.allowed and not table.HasValue(found.allowed, client:Team()) then client:Notify( apex.language.GetPhrase("incorrect_job", "/buyvehicle")) return "" end

	if found.customCheck and not found.customCheck(client) then
		client:Notify( v.CustomCheckFailMsg or "You're not allowed to purchase this item")
		return ""
	end

	if not client.Vehicles then client.Vehicles = 0 end
	if GAMEMODE.Config.maxvehicles and client.Vehicles >= GAMEMODE.Config.maxvehicles then
		client:Notify( apex.language.GetPhrase("limit", "vehicle"))
		return ""
	end

	if not client:CanAfford(found.price) then client:Notify( apex.language.GetPhrase("cant_afford", "vehicle")) return "" end

	local Vehicle = apex.getAvailableVehicles()[found.name]
	if not Vehicle then client:Notify( apex.language.GetPhrase("invalid_x", "argument", "")) return "" end

	client:AddMoney(-found.price)
	client:Notify( apex.language.GetPhrase("you_bought_x", found.name, GAMEMODE.Config.currency .. found.price))

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client
	local tr = util.TraceLine(trace)

	local ent = ents.Create(Vehicle.Class)
	if not ent then
		client:Notify( apex.language.GetPhrase("unable", "/buyvehicle", ""))
		return ""
	end
	ent:SetModel(Vehicle.Model)
	if Vehicle.KeyValues then
		for k, v in pairs(Vehicle.KeyValues) do
			ent:SetKeyValue(k, v)
		end
	end

	local Angles = client:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180
	ent:SetAngles(Angles)
	ent:SetPos(tr.HitPos)
	ent.VehicleName = found.name
	ent.VehicleTable = Vehicle
	ent:Spawn()
	ent:Activate()
	ent.SID = client.SID
	ent.ClassOverride = Vehicle.Class
	if Vehicle.Members then
		table.Merge(ent, Vehicle.Members)
	end
	ent:CPPISetOwner(client)
	ent:Own(client)
	hook.Call("PlayerSpawnedVehicle", GAMEMODE, client, ent) -- VUMod compatability
	hook.Call("playerBoughtVehicle", nil, client, found, ent)
	if found.onBought then
		found.onBought(client, found, ent)
	end

	return ""
end
--apex.commands.Register("/buyvehicle", BuyVehicle)

local function BuyAmmo(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if client:IsArrested() then
		client:Notify( apex.language.GetPhrase("unable", "/buyammo", ""))
		return ""
	end

	if GAMEMODE.Config.noguns then
		client:Notify( apex.language.GetPhrase("disabled", "ammo", ""))
		return ""
	end

	local found
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found or (found.customCheck and not found.customCheck(client)) then
		client:Notify( found and found.CustomCheckFailMsg or apex.language.GetPhrase("unavailable", "ammo"))
		return ""
	end

	if not client:CanAfford(found.price) then
		client:Notify( apex.language.GetPhrase("cant_afford", "ammo"))
		return ""
	end

	client:Notify( apex.language.GetPhrase("you_bought_x", found.name, GAMEMODE.Config.currency..tostring(found.price)))
	client:AddMoney(-found.price)

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	local ammo = ents.Create("spawned_weapon")
	ammo:SetModel(found.model)
	ammo.ShareGravgun = true
	ammo:SetPos(tr.HitPos)
	ammo.nodupe = true
	function ammo:PlayerUse(user, ...)
		user:GiveAmmo(found.amountGiven, found.ammoType)
		self:Remove()
		return true
	end
	ammo:Spawn()

	return ""
end
apex.commands.Register("/buyammo", BuyAmmo, 1)


/*---------------------------------------------------------
Jobs
---------------------------------------------------------*/
local function CreateAgenda(client, args)
	if DarkRPAgendas[client:Team()] then
		client:SetDarkRPVar("agenda", args)

		client:Notify( apex.language.GetPhrase("agenda_updated"))
		for k,v in pairs(DarkRPAgendas[client:Team()].Listeners) do
			for a,b in pairs(team.GetPlayers(v)) do
				GAMEMODE:Notify(b, 2, 4, apex.language.GetPhrase("agenda_updated"))
			end
		end
	else
		client:Notify( apex.language.GetPhrase("unable", "agenda", "Incorrect team"))
	end
	return ""
end
--apex.commands.Register("/agenda", CreateAgenda, 0.1)

local function ChangeJob(client, args)
	if args == "" then
		client:Notify(apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if client:IsArrested() then
		client:Notify(apex.language.GetPhrase("unable", "/job", ""))
		return ""
	end

	if client:GetNWString("usergroup") != "vip" and !client:IsAdmin() then
		client:Notify("/job is a VIP only feature.")
		return ""
	end


	if client.LastJob and 4 - (CurTime() - client.LastJob) >= 0 then
	--	client:Notify( apex.language.GetPhrase("have_to_wait", math.ceil(4 - (CurTime() - client.LastJob)), "/job"))
	--	return ""
	end
	--client.LastJob = CurTime()

	if not client:Alive() then
		client:Notify(apex.language.GetPhrase("unable", "/job", ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		client:Notify(apex.language.GetPhrase("disabled", "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		client:Notify(apex.language.GetPhrase("unable", "/job", ">2"))
		return ""
	end

	if len > 25 then
		client:Notify(apex.language.GetPhrase("unable", "/job", "<26"))
		return ""
	end

	local canChangeJob, message, replace = hook.Call("canChangeJob", nil, client, args)
	if canChangeJob == false then
		client:Notify(message or apex.language.GetPhrase("unable", "/job", ""))
		return ""
	end

	local job = replace or args
	client:UpdateJob(job)
	return ""
end
apex.commands.Register("/job", ChangeJob)

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(GAMEMODE.DefaultTeam, true)
			if target:IsArrested() then
				target:arrest()
			end
		else
			target.firedWhileDead = true
		end

		GAMEMODE:NotifyAll(0, 4, apex.language.GetPhrase("fired", target:Nick()))
	else
		GAMEMODE:NotifyAll(1, 4, apex.language.GetPhrase("fired_not", target:Nick()))
	end
end

local function Demote(client, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		client:Notify(apex.language.GetPhrase("vote_specify_reason"))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		client:Notify(apex.language.GetPhrase("unable", "/fire", "<100"))
		return ""
	end
	local p = GAMEMODE:FindPlayer(tableargs[1])
	if p == client then
		client:Notify("Can't fire yourself.")
		return ""
	end

	local canDemote, message = hook.Call("CanDemote", GAMEMODE, client, p, reason)
	if canDemote == false then
		client:Notify(message or apex.language.GetPhrase("unable", "fire", ""))
		return ""
	end

	if p then
		if CurTime() - client.LastVoteCop < 20 then
			client:Notify(apex.language.GetPhrase("have_to_wait", math.ceil(20 - (CurTime() - client:GetTable().LastVoteCop)), "/fire"))
			return ""
		end
		if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].canfire == false then
			client:Notify(apex.language.GetPhrase("unable", "/fire", ""))
		else
			GAMEMODE:TalkToPerson(p, team.GetColor(client:Team()), "(FIRE) "..client:Nick(),Color(255,0,0,255), "Was fired, Reason: "..reason, p)
			apex.db.Log(apex.language.GetPhrase("fire_vote_started", client:Nick(), p:Nick()) .. " (" .. reason .. ")",
				false, Color(255, 128, 255, 255))
			client:ChangeTeam( TEAM_CITIZEN, true )


			client:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		GAMEMODE:Notify(apex.language.GetPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end
end
apex.commands.Register("/fire", Demote)
/*
local function ExecSwitchJob(answer, ent, client, target)
	client.RequestedJobSwitch = nil
	if not tobool(answer) then return end
	local Pteam = client:Team()
	local Tteam = target:Team()

	if not client:ChangeTeam(Tteam) then return end
	if not target:ChangeTeam(Pteam) then
		client:ChangeTeam(Pteam, true) -- revert job change
		return
	end
	client:Notify( apex.language.GetPhrase("team_switch"))
	GAMEMODE:Notify(target, 2, 4, apex.language.GetPhrase("team_switch"))
end

local function SwitchJob(client) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end

	if client.RequestedJobSwitch then return end

	local eyetrace = client:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	client.RequestedJobSwitch = true
	GAMEMODE.ques:Create("Switch job with "..client:Nick().."?", "switchjob"..tostring(client:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, client, eyetrace.Entity)
	client:Notify( apex.language.GetPhrase("created_x", "You", "job switch request."))
	return ""
end
apex.commands.Register("/switchjob", SwitchJob)
apex.commands.Register("/switchjobs", SwitchJob)
apex.commands.Register("/jobswitch", SwitchJob)

*/
local function DoTeamBan(client, args, cmdargs)
	if not args or args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "arguments", ""))
		return ""
	end

	args = cmdargs or string.Explode(" ", args)
	local ent = args[1]
	local Team = args[2]
	if cmdargs and not cmdargs[1]  then
		client:PrintMessage(HUD_PRINTNOTIFY, "apex_teamban [player name/ID] [team name/id] Use this to ban a player from a certain team")
		return
	end

	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then
		client:Notify( apex.language.GetPhrase("could_not_find", "player!"))
		return ""
	end

	if (not FAdmin or not FAdmin.Access.PlayerHasPrivilege(client, "apex_commands", target)) and not client:IsAdmin() then
		client:Notify( apex.language.GetPhrase("need_admin", "/teamban"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) or k == tonumber(Team or -1) then
			Team = k
			found = true
			break
		end
	end

	if not found then
		client:Notify( apex.language.GetPhrase("could_not_find", "job!"))
		return ""
	end

	target:TeamBan(tonumber(Team), tonumber(args[3] or 0))
	GAMEMODE:NotifyAll(0, 5, client:Nick() .. " has banned " ..target:Nick() .. " from being a " .. team.GetName(tonumber(Team)))
	return ""
end
apex.commands.Register("/teamban", DoTeamBan)
concommand.Add("apex_teamban", DoTeamBan)

local function DoTeamUnBan(client, args, cmdargs)
	if not client:IsAdmin() then
		client:Notify( apex.language.GetPhrase("need_admin", "/teamunban"))
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			client:PrintMessage(HUD_PRINTNOTIFY, "apex_teamunban [player name/ID] [team name/id] Use this to unban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args, a + 1)
	end

	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then
		client:Notify( apex.language.GetPhrase("could_not_find", "player!"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or  string.lower(v.command) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == tonumber(Team or -1) then
			found = true
			break
		end
	end

	if not found then
		client:Notify( apex.language.GetPhrase("could_not_find", "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = nil
	GAMEMODE:NotifyAll(1, 5, client:Nick() .. " has unbanned " ..target:Nick() .. " from being a " .. team.GetName(tonumber(Team)))
	return ""
end
apex.commands.Register("/teamunban", DoTeamUnBan)
concommand.Add("apex_teamunban", DoTeamUnBan)

local function PlayerAdvertise(client, args)
	if args == "" then return "" end
	local DoSay = function(text)
		if text == "" then return end
		client:Notify( string.format("Your announcement has been sent and will be displayed shortly."))
		for k,v in player.Iterator() do
			local col = team.GetColor(client:Team())
			timer.Simple( 15, function()

			v:ApexChat([[Color(226,162,13), "[ADVERT] ", teamCOL, plyNAME, Color(255,255,255),": ", message]], client, text)
			end )
			--GAMEMODE:TalkToPerson(v, col, LANGUAGE.advert .." "..client:Nick(), Color(255,255,0,255), text, client)
		end
	end
	return args, DoSay
end
apex.commands.Register("/announce", PlayerAdvertise)
apex.commands.Register("/advert", PlayerAdvertise)

local function SetRadioChannel(client,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 100 then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", "0<channel<100"))
		return ""
	end
	client:Notify( "Channel set to "..args.."!")
	client.RadioChannel = tonumber(args)
	return ""
end
apex.commands.Register("/channel", SetRadioChannel)

local function MayorBroadcast(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local pos = client:GetPos();
	local station = apex.mapconfig.Get().Broadcast
	if pos:Distance(station) > 100 then client:Notify( "You have to infront of the broadcast station.") return "" end
	local DoSay = function(text)
		if text == "" then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end
		for k,v in player.Iterator() do
			local col = Color(150, 20, 20, 255)
			GAMEMODE:TalkToPerson(v, col, "[Broadcast] " ..client:Nick(), Color(170, 0, 0,255), text, client)
		end
	end
	return args, DoSay
end
apex.commands.Register("/broadcast", MayorBroadcast)

local function SetRadioChannel(client,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 100 then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", "0<channel<100"))
		return ""
	end
	client:Notify( "Channel set to "..args.."!")
	client.RadioChannel = tonumber(args)
	return ""
end
apex.commands.Register("/channel", SetRadioChannel)

local function SayThroughRadio(client,args)
if client:IsCombine() then client:ConCommand("say_team "..args) return false end
	if not client.RadioChannel then client.RadioChannel = 1 end
	if not args or args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end
		for k,v in player.Iterator() do
			if v.RadioChannel == client.RadioChannel then
				GAMEMODE:TalkToPerson(v, Color(180,180,180,255), "Radio ".. tostring(client.RadioChannel), Color(180,180,180,255), text, client)
			end
		end
	end
	return args, DoSay
end
apex.commands.Register("/radio", SayThroughRadio)

local function GroupMsg(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not (client:IsCombine()) then
		client:Notify( "Only Civil Protection can use the radio.")
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end

		local t = client:Team()
		local col = team.GetColor(client:Team())

		local hasReceived = {}
		for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
			-- not the group of the player
			if not func(client) then continue end

			for _, target in player.Iterator() do
				if func(target) and not hasReceived[target] then
					hasReceived[target] = true
					target:ApexChat([[Color(55,146,21),"[RADIO] ", plyNAME, ": ", message ]], client, text)--GAMEMODE:TalkToPerson(target, col, "(Radio)" .. " " .. client:Nick(), Color(255,255,255,255), text, client)
				end
			end
		end
		if next(hasReceived) == nil then
			client:Notify( apex.language.GetPhrase("unable", "/g", ""))
		end
	end
	return args, DoSay
end
apex.commands.Register("/g", GroupMsg)


local function DispatchMsg(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not (client:IsDispatch()) then
		client:Notify( "Only Dispatch units can use the dispatch radio.")
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end

		local t = client:Team()
		local col = team.GetColor(client:Team())

		local hasReceived = {}
		for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
			-- not the group of the player
			if not func(client) then continue end

			for _, target in player.Iterator() do
				if not hasReceived[target] then
					hasReceived[target] = true
					text2 = hook.Call("DispatchTalk", nil, client, text)
					if text2 then text = text2 end

					GAMEMODE:TalkToPerson(target, col, "(Dispatch)" .. " " .. client:Nick(), Color(255,255,255,255), text, client)
				end
			end
		end
		if next(hasReceived) == nil then
			client:Notify( apex.language.GetPhrase("unable", "/g", ""))
		end
	end
	return args, DoSay
end
apex.commands.Register("/dispatch", DispatchMsg)

local function DispatchRadioMsg(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not (client:Team() == TEAM_DISPATCH) then
		client:Notify( "Only Dispatch units can use the dispatch radio.")
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
			return
		end

		local t = client:Team()
		local col = team.GetColor(client:Team())

		local hasReceived = {}
		for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
			-- not the group of the player
			if not func(client) then continue end

			for _, target in player.Iterator() do
			if target:Team() == TEAM_CP or target:Team() == TEAM_OVERWATCH or target:Team() == TEAM_ADMINISTRATOR or target:Team() == TEAM_DISPATCH then 
				if not hasReceived[target] then
					hasReceived[target] = true
					text2 = hook.Call("DispatchRadioTalk", nil, client, text)
					if text2 then text = text2 end

					GAMEMODE:TalkToPerson(target, col, "(<Dispatch>)" .. " " .. client:Nick(), Color(255,0,0,255), text, client)
				end
				end
			end
		end
		if next(hasReceived) == nil then
			client:Notify( apex.language.GetPhrase("unable", "/g", ""))
		end
	end
	return args, DoSay
end
apex.commands.Register("/dispatchRadio", DispatchRadioMsg)

/*---------------------------------------------------------
Money
---------------------------------------------------------*/
local function GiveMoney(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local trace = client:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(client:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			client:Notify( apex.language.GetPhrase("invalid_x", "argument", ">=1"))
			return
		end

		if not client:CanAfford(amount) then
			client:Notify( apex.language.GetPhrase("cant_afford", ""))
			return ""
		end

		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("anim_giveitem", RP)
			umsg.Entity(client)
		umsg.End()
		client.anim_GivingItem = true

		timer.Simple(1.2, function()
			if IsValid(client) then
				local trace2 = client:GetEyeTrace()
				if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(client:GetPos()) < 150 then
					if not client:CanAfford(amount) then
						client:Notify( apex.language.GetPhrase("cant_afford", ""))
						return ""
					end
					apex.db.PayPlayer(client, trace2.Entity, amount)

					trace2.Entity:Notify( apex.language.GetPhrase("has_given", client:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					client:Notify( apex.language.GetPhrase("you_gave", trace2.Entity:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					apex.db.Log(client:Nick().. " (" .. client:SteamID64() .. ") has given "..GAMEMODE.Config.currency .. tostring(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID64() .. ")")
				end
			else
				client:Notify( apex.language.GetPhrase("unable", "/give", ""))
			end
		end)
	else
		client:Notify( apex.language.GetPhrase("must_be_looking_at", "player"))
	end
	return ""
end
apex.commands.Register("/give", GiveMoney)

local function DropMoney(client, args)
	if args == "" then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", ">1"))
		return ""
	end

	if not client:CanAfford(amount) then
		client:Notify( apex.language.GetPhrase("cant_afford", ""))
		return ""
	end

	client:AddMoney(-amount)
	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(client)
	umsg.End()
	client.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(client) then
			local trace = {}
			trace.start = client:EyePos()
			trace.endpos = trace.start + client:GetAimVector() * 85
			trace.filter = client

			local tr = util.TraceLine(trace)
			DarkRPCreateMoneyBag(tr.HitPos, amount)
			apex.db.Log(client:Nick().. " (" .. client:SteamID64() .. ") has dropped "..GAMEMODE.Config.currency .. tostring(amount))
		else
			client:Notify( apex.language.GetPhrase("unable", "/dropmoney", ""))
		end
	end)

	return ""
end
apex.commands.Register("/dropmoney", DropMoney)
apex.commands.Register("/droptoken", DropMoney)
apex.commands.Register("/droptokens", DropMoney)
apex.commands.Register("/moneydrop", DropMoney)
apex.commands.Register("/tokendrop", DropMoney)
apex.commands.Register("/tokensdrop", DropMoney)

local function CreateCheque(client, args)
	local argt = string.Explode(" ", args)
	local recipient = GAMEMODE:FindPlayer(argt[1])
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", "recipient (1)"))
		return ""
	end

	if amount <= 1 then
		client:Notify( apex.language.GetPhrase("invalid_x", "argument", "amount (2)"))
		return ""
	end

	if not client:CanAfford(amount) then
		client:Notify( apex.language.GetPhrase("cant_afford", ""))
		return ""
	end

	if IsValid(client) and IsValid(recipient) then
		client:AddMoney(-amount)
	end

	umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers())
		umsg.Entity(client)
	umsg.End()
	client.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(client) and IsValid(recipient) then
			local trace = {}
			trace.start = client:EyePos()
			trace.endpos = trace.start + client:GetAimVector() * 85
			trace.filter = client

			local tr = util.TraceLine(trace)
			local Cheque = ents.Create("darkrp_cheque")
			Cheque:SetPos(tr.HitPos)
			Cheque:Setowning_ent(client)
			Cheque:Setrecipient(recipient)

			Cheque:Setamount(math.Min(amount, 2147483647))
			Cheque:Spawn()
		else
			client:Notify( apex.language.GetPhrase("unable", "/cheque", ""))
		end
	end)

	return ""
end
apex.commands.Register("/cheque", CreateCheque)
apex.commands.Register("/check", CreateCheque)

local function DisableOOC(client)
	if ( !client:IsAdmin() ) then
		client:Notify("You must be an admin to disable OOC!")
		return ""
	end

	SetGlobalInt("OOCDisabled", 1)

	for k, v in player.Iterator() do
		v:Notify("Global OOC has been disabled by an admin!")
	end
end
apex.commands.Register("/disableooc", DisableOOC)

concommand.Add("apex_ooc_disable", function(client)
	DisableOOC(client)
end)

local function EnableOOC(client)
	if ( !client:IsAdmin() ) then
		client:Notify("You must be an admin to enable OOC!")
		return ""
	end

	SetGlobalInt("OOCDisabled", 0)

	for k, v in player.Iterator() do
		v:Notify("Global OOC has been enabled by an admin!")
	end
end

apex.commands.Register("/enableooc", EnableOOC)

concommand.Add("apex_ooc_enable", function(client)
	EnableOOC(client)
end)