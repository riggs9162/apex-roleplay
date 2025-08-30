local NVColors = {
	SPEAR = {255, 255, 0},
	GRID = {66, 158, 244},
	KING = {255, 0, 0},
	SENTINEL = {255, 0, 0},
	NOVA = {255, 255, 0},
	DEFAULT = {40, 40, 255}
}

function GM:ShowSpare1(client)
	if ( !client:IsCombine() ) then return false end
	if ( !client.CMDCDC ) then
		client.CMDCDC = CurTime()
	end

	if client.CMDCDC and client.CMDCDC > CurTime() then return end

	local nick = client:Nick()
	local team = client:Team()
	local color = NVColors.DEFAULT

	for key, nvColor in pairs(NVColors) do
		if string.match(nick, key) then
			color = nvColor
			break
		end
	end

	if team == TEAM_OVERWATCH and (string.match(nick, "KING") or string.match(nick, "SENTINEL")) then
		color = NVColors.KING
	end

	client:SendLua(string.format("LoadNV(%d,%d,%d)", color[1], color[2], color[3]))
	client:Notify("You have toggled nightvision!")
	client:EmitSound("buttons/blip1.wav")
	client:ConCommand("say /me toggles nightvision.")
	client.CMDCDC = CurTime() + 1
end

concommand.Add("apex_clear_ranks", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	for k, v in player.Iterator() do
		v:SetDarkRPVar("division", 0)
		v:SetDarkRPVar("rank", 0)
	end
end)

concommand.Add("apex_clear_ration", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	client:SetDarkRPVar("ration", "yes")
end)

hook.Add("OnPlayerChangedTeam", "OWSName", function(client, oldTeam, newTeam)
	if ( oldTeam == TEAM_OVERWATCH ) then
		client:SetHealth(100)
		client:SetArmor(0)
	end

	client:SetDarkRPVar("division", 0)
	client:SetDarkRPVar("rank", 0)

	if ( newTeam == TEAM_VORT ) then
		local id = math.random(100201, 990230)
		local name = "CMB-BIOTIC-" .. id
		client:SetDarkRPVar("rpname", name)
	end
end)

hook.Add("PlayerDisconnected", "PlayerLeave", function(client)
	client:SetDarkRPVar("division", 0)
	client:SetDarkRPVar("rank", 0)
end)

concommand.Add("event_citadel_start", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	local ent = ents.Create("prop_dynamic")
	ent:SetPos(Vector(-3392.845215, -3799.512207, -1206.489990))
	ent:SetModel("models/props_combine/combine_citadelcloudcenter.mdl")
	ent:Spawn()
	ent:Activate()

	ent = ents.Create("prop_dynamic")
	ent:SetPos(Vector(-3402.347412, -3784.249023, -2514.381836))
	ent:SetModel("models/props_combine/combine_citadelcloud001c.mdl")
	ent:Spawn()
	ent:Activate()

	util.ScreenShake(vector_origin, 200, 30, 10, 5000)

	for _, v in player.Iterator() do
		v:ConCommand("play wind_light02_loop.wav")
		v:ConCommand("play ol01_portalblast.wav")
		v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 3, 0)

		timer.Create("GroundShakeTime", 10, 0, function()
			util.ScreenShake(vector_origin, 5, 5, 10, 5000)
		end)

		timer.Simple(10, function()
			v:ConCommand("play ol01portal_loop_stage01.wav")
		end)
	end
end)

local colYellow = Color(246, 60, 3, 255)

local portalPos = {
	Vector(4731.023926, 2303.414795, 1900.036133),  -- Construction
	Vector(306.599792, 3515.020508, 1641.384521), -- Plaza
	Vector(10026.125000, 11622.543945, 3000.813721) -- Shell Beach
}

concommand.Add("event_portal_start", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	local ent = ents.Create("prop_dynamic")
	ent:SetPos(table.Random(portalPos))
	ent:SetModel("models/props_combine/combine_citadelcloudcenter.mdl")
	ent:SetColor(colYellow)
	ent:Spawn()
	ent:Activate()

	for _, v in player.Iterator() do
		v:ConCommand( "play ol01_portalblast.wav" )
		v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 3, 0)

		timer.Simple(10, function()
			v:ConCommand("play ol01portal_loop_stage01.wav")
		end)

		timer.Create("GroundShakeTime2", 5, 0, function()
			util.ScreenShake(vector_origin, 2, 2, 5, 5000)
		end)
	end
end)

concommand.Add("event_advisor_start", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	local ent = ents.Create("prop_dynamic")
	ent:SetPos(Vector(-1492.901123, 4110.057617, 125.058563))
	ent:SetAngles(Angle(6.339, -8.979, -0.703))
	ent:SetModel("models/advisorpod_crash/advisor_pod_crash.mdl")
	ent:Spawn()
	ent:Activate()

	ent = ents.Create("prop_dynamic")
	ent:SetPos(Vector(-1515.022217, 3991.507568, 99.378838))
	ent:SetAngles(Angle(2.051, -124.238, -1.367))
	ent:SetModel("models/props_debris/concrete_debris256pile001a.mdl")
	ent:Spawn()
	ent:Activate()

	ent = ents.Create("prop_dynamic")
	ent:SetPos(Vector(-1485.877563, 4210.941895, 104.672493))
	ent:SetAngles(Angle(0.616, -104.282, -1.047))
	ent:SetModel("models/props_debris/concrete_debris256pile001a.mdl")
	ent:Spawn()
	ent:Activate()

	util.ScreenShake(vector_origin, 5, 5, 10, 5000)

	for _, v in player.Iterator() do
		v:ConCommand("play ambient/explosions/exp2.wav")
		timer.Simple(7, function()
			v:ConCommand("play over_barn.wav")
		end)

		timer.Simple(34.34, function()
			v:ConCommand("play ambient/alarms/city_siren_loop2.wav")
		end)

		timer.Create("PortalMovey", 4.34, 0, function()
			util.ScreenShake(vector_origin, 3, 3, 10, 5000)
		end)
	end
end)

concommand.Add("getspos", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	client:Notify(tostring(client:GetPos()))
end)

concommand.Add("event_citadel_stop", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	for k, v in ipairs(ents.FindByClass("prop_dynamic")) do
		if ( v:GetModel() == "models/props_combine/combine_citadelcloudcenter.mdl" or v:GetModel() == "models/props_combine/combine_citadelcloud001c.mdl" ) then
			SafeRemoveEntity(v)
		end
	end

	for _, v in player.Iterator() do
		v:ConCommand("play ol12a_portalclose.wav")
		v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 3, 0)
		timer.Remove("GroundShakeTime")
	end
end)

concommand.Add("event_portal_stop", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	for k, v in pairs(ents.FindByClass("prop_dynamic")) do
		if ( v:GetModel() == "models/props_combine/combine_citadelcloudcenter.mdl" ) then
			SafeRemoveEntity(v)
		end
	end

	for _, v in player.Iterator() do
		v:ConCommand("play ol12a_portalclose.wav")
		v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 3, 0)
		timer.Remove("GroundShakeTime2")
		timer.Remove("PortalMovey")
	end
end)

concommand.Add("event_advisor_stop", function(client)
	if ( !client:IsSuperAdmin() ) then return end

	for k, v in pairs(ents.FindByClass("prop_dynamic")) do
		if ( v:GetModel() == "models/advisorpod_crash/advisor_pod_crash.mdl" or v:GetModel() == "models/props_debris/concrete_debris256pile001a.mdl" ) then
			SafeRemoveEntity(v)
		end
	end

	for _, v in player.Iterator() do
		v:ConCommand("stopsound")
		timer.Remove("AlarmShakeTime")
	end
end)

function PlayerFootstep(client, position, foot, soundName, volume)
	if ( client:IsSprinting() ) then
		if ( client:Team() == TEAM_CP ) then
			client:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav", volume * 90)

			return true
		elseif ( client:Team() == TEAM_OVERWATCH or client:Team() == TEAM_OVERWATCHELITE or client:Team() == TEAM_OVERWATCHPRISONGUARD ) then
			client:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", volume * 100)

			return true
		end
	end

	if ( apex.anim.getModelClass(client:GetModel()) == "vort" ) then
		client:EmitSound("npc/vort/vort_foot" .. math.random(1, 4) .. ".wav", volume * 120)
		return true
	end
end

hook.Add("PlayerFootstep", "OWFootstep", PlayerFootstep )

concommand.Add("apex_fcitopt", function(client, command, args)
	if ( !client:IsSuperAdmin() ) then return end

	client:SetOpt(client, args[1])
end)

-- Define all citizen options in one place
local CitOptions = {
	[1] = {
		name        = "Normal Citizen",
		teams       = { TEAM_CITIZEN },
		xpRequired  = 0,
		maxCount    = math.huge,
		modelMap    = {},  -- no special model
	},
	[2] = {
		name        = "Black Market Dealer",
		teams       = { TEAM_CITIZEN },
		xpRequired  = 80,
		maxCount    = 6,
		modelMap    = {},  -- no special model
	},
	[3] = {
		name        = "Standard Worker",
		teams       = { TEAM_CWU },
		xpRequired  = 0,
		maxCount    = math.huge,
		modelMap    = {
			patterns = {
				{"betacz/group03m", 			"betacz/group01"},
				{"betacz/group03", 				"betacz/group01"},
				{"humans/group01",        		"betacz/group01"},
				{"bmscientistcits", 			"betacz/group01"},
			},
			fallback = "models/humans/group01/male_09.mdl",
		}
	},
	[4] = {
		name        = "Cook",
		teams       = { TEAM_CWU },
		xpRequired  = 10,
		maxCount    = 4,
		modelMap    = {
			patterns = {
				{"betacz/group03m", 			"betacz/group03"},
				{"betacz/group01", 				"betacz/group03"},
				{"humans/group01", 				"betacz/group03"},
				{"bmscientistcits", 			"betacz/group03"},
			},
			fallback = "models/betacz/group03m/male_09.mdl",
		},
	},
	[5] = {
		name        = "Medic",
		teams       = { TEAM_CWU },
		xpRequired  = 35,
		maxCount    = 3,
		modelMap    = {
			patterns = {
				{"betacz/group03", 				"betacz/group03m"},
				{"betacz/group01", 				"betacz/group03m"},
				{"humans/group01",        		"betacz/group03m"},
				{"bmscientistcits/",     		"betacz/group03m"},
			},
			fallback = "models/betacz/group03m/male_09.mdl",
		},
	},
	[6] = {
		name         	= "Scientist",
		teams        	= { TEAM_CWU },
		xpRequired   	= 100,
		maxCount     	= 5,
		allowedGroups	= { "admin", "superadmin", "moderator", "vip", "developer" },
		modelMap     	= {
			patterns 	= {
				{"betacz/group03m", 			"bmscientistcits"},
				{"betacz/group03", 				"bmscientistcits"},
				{"betacz/group01", 				"bmscientistcits"},
				{"humans/group01",        		"bmscientistcits"},
			},
			fallback = "models/bmscientistcits/male_09.mdl",
		},
	},
}

-- Utility: check table membership
local function HasValue(tbl, val)
	for _,v in ipairs(tbl) do if v == val then return true end end
	return false
end

-- Get current player count for a given option
local function CountOption(num, team)
	local cnt = 0
	for _, ply in ipairs(player.GetAll()) do
		if ply:Team() == team
		and ply:GetDarkRPVar("citopt") == num then
		cnt = cnt + 1
		end
	end
	return cnt
end

-- Check if client has enough XP
local function HasXP(client, amount)
	return client:GetXP() >= amount
end

-- Compute a model path based on map rules
local function ComputeModel(baseModel, mapConfig)
	if ( !mapConfig or !mapConfig.patterns ) then
		return mapConfig and mapConfig.fallback or nil
	end

	for _, rule in ipairs(mapConfig.patterns) do
		local pat, repl = rule[1], rule[2]
		if string.match(baseModel, pat) then
			return string.Replace(baseModel, pat, repl)
		end
	end
	return mapConfig.fallback
end

-- Apply the chosen option: notify, set DarkRP vars, set model
local function ApplyOption(client, num)
	local opt = CitOptions[num]
	client:Notify("You have changed your citizen type to " .. opt.name .. ".")
	client:SetDarkRPVar("citopt", num)
	client:SetDarkRPVar("LastCOSet", CurTime())

	-- custom setter?
	if opt.setModel then
		return opt.setModel(client)
	end

	-- otherwise build model from mapping rules
	local base = client:GetModel()
	local modelPath = ComputeModel(base, opt.modelMap)
	if modelPath then
		client:SetModel(modelPath)
	end
end

-- The console command handler
concommand.Add("apex_citopt", function(client, command, args)
	-- must be in spawn
	if !client:GetDarkRPVar("inSpawn") then
		return client:Notify("You are not in spawn.")
	end

	-- cooldown for non-admins
	local last = client:GetDarkRPVar("LastCOSet") or 0
	local wait  = 120 - (CurTime() - last)
	if !client:IsAdmin() and wait > 0 then
		return client:Notify(
		"Wait " .. math.ceil(wait) .. " seconds before changing again."
		)
	end

	-- parse and validate choice
	local num = tonumber(args[1])
	local opt = CitOptions[num]
	if !opt then return end
	if client:GetDarkRPVar("citopt") == num then
		return client:Notify("You are already a " .. opt.name .. ".")
	end

	-- team check
	if !HasValue(opt.teams, client:Team()) then return end

	-- XP check
	if opt.xpRequired > 0 and !HasXP(client, opt.xpRequired) then
		return client:Notify("You need at least " .. opt.xpRequired .. " XP.")
	end

	-- group check (for Scientist)
	if opt.allowedGroups and !HasValue(opt.allowedGroups, client:GetNWString("usergroup")) then
		return client:Notify("Only donors can become a " .. opt.name .. ".")
	end

	-- max count check
	local cnt = CountOption(num, client:Team())
	if cnt >= opt.maxCount then
		return client:Notify("Max limit for " .. opt.name .. " reached.")
	end

	-- all good: apply!
	ApplyOption(client, num)
end)


function plazaElevator(client)
	if client:IsCombine() then
		for k, v in pairs (ents.FindInBox( Vector(1667.460205, 3390.747559, 151.531937), Vector(2058.854492, 3793.437988, 320.091736) ) ) do
			if ( IsValid(v) and v:IsPlayer() and v:SteamID64() == client:SteamID64() and v:Alive() ) then
			for k2, v2 in pairs(ents.FindByName("nexus_tunnel_elevator1")) do
				v2:Fire("Open","",0)
			end
				client:Notify("The elevator has been called up.")
				apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") called the plaza elevator.", nil, Color(0, 255, 255))
				return
			end
		end
		client:Notify("You need to be near the elevator to call it.")
	else
		client:Notify("Only Civil Protection can call that elevator up.")
	end

end

apex.commands.Register("/plazaelevator", plazaElevator, 20)

function garageDoor(client)
	if client:IsCombine() then
		for k, v in pairs(ents.FindInBox(Vector(1750.827148, 3855.464844, 355.620728), Vector(1350.354980, 4536.534668, 150.099014))) do
			if ( IsValid(v) and v:IsPlayer() and v:SteamID64() == client:SteamID64() and v:Alive() ) then
			for k2, v2 in pairs(ents.FindByName("nexus_garagedoor1")) do
				v2:Fire("Open","",0)
			end
				client:Notify("The garage door has been opened.")
				apex.db.Log(client:Nick() .. " (" .. client:SteamID64() .. ") opened the garage door.", nil, Color(0, 255, 255))
				return
			end
		end
		client:Notify("You need to be near the garage door to open it")
	end
end

apex.commands.Register("/garagedoor", garageDoor, 20)

local function playerReward(client)
	if client.CMDCD and client.CMDCD > CurTime() then return end
	client.CMDCD = CurTime() + 300

	local rewardAllowedDivisions = {
		[DIVISION_CMD] = true, -- CmD
		[DIVISION_SEC] = true -- SeC
	}

	local rewardAllowedRanks = {
		[RANK_DVL] = true -- DvL
	}

	if ( client:IsCombine() ) then
		local rank = client:GetDarkRPVar("rank")
		local division = client:GetDarkRPVar("division")
		if ( rewardAllowedDivisions[division] or rewardAllowedRanks[rank] ) then
			local eyetrace = client:GetEyeTrace()
			if ( eyetrace.Entity:IsValid() and eyetrace.Entity:IsPlayer() ) then
				client:Notify("You have rewarded " .. eyetrace.Entity:Nick() .. " with one ration unit.")

				local target = eyetrace.Entity
				target:Notify("You have been rewarded with one ration unit by " .. client:Nick() .. ", return to the nearest ration dispenser to claim it.")
				target:SetDarkRPVar("ration", "reward")
			else
				client:Notify("You must look at a Citizen or a Civil Worker to reward them!")
			end
		else
			client:Notify("You must be a Division Leader or higher in the Civil Protection to reward citizens!")
		end
	else
		client:Notify("You must be a member of the Civil Protection to reward citizens!")
	end
end
apex.commands.Register("/reward", playerReward, 4000)

concommand.Add("apex_vinard", function(client, cmd, args)

	if !client:IsAdmin() then return end

	if client:EntIndex() != 0 and !client:HasPriv("apex_commands") then
		client:PrintMessage(2, apex.language.GetPhrase("need_admin", "apex_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
								oldmdl = target:GetModel()
																				target:SetTeam( TEAM_CWU )
					target:Notify "You have set a player to vinard xd."
timer.Simple( 1, function()
					if string.match( client:GetModel(), "fem" ) then
					suitedModel2 = string.Replace( client:GetModel(), "group01/female_", "jackathan/beta/worker_" )
					elseif string.match( client:GetModel(), "male" ) then
					suitedModel2 = string.Replace( client:GetModel(), "group01/male_", "jackathan/beta/worker_" )
					end
					target:SetModel(suitedModel2)
					target:SetSkin(1)
					target:Give ( "remotecontroller" )
					target:Give ( "laserpointer" )
					target:Give ( "stunstick" )
					target:Notify "An admin has set you to Vinard Industries."
					target:Notify "You must RP as a loyalist."
					target:Notify "You have been whitelisted to Vinard Industries."
								target:UpdateJob("Vinard Industries Employee")
																				-- doors
print "added owner to vinard door"
end)
	else
		if client:EntIndex() == 0 then
			print(apex.language.GetPhrase("could_not_find", "player: " .. tostring(args[1])))
		else
			client:PrintMessage(2, apex.language.GetPhrase("could_not_find", "player: " .. tostring(args[1])))
		end
		return
	end
end)

if ( timer.Exists("apex.spawn.check") ) then
	timer.Remove("apex.spawn.check")
end

timer.Create("apex.spawn.check", 1, 0, function()
	local config = apex.mapconfig.Get()
	if ( !config or !config.Spawn1 or !config.Spawn2 ) then
		timer.Remove("apex.spawn.check")
		return
	end

	for _, client in player.Iterator() do
		client:SetDarkRPVar("inSpawn", false)

		for _, v in pairs(ents.FindInBox(config.Spawn1,config.Spawn2 ) ) do
			if ( IsValid(v) and v:IsPlayer() and v:SteamID64() == client:SteamID64() and v:Alive() ) then
				client:SetDarkRPVar("inSpawn", true)
			end
		end
	end
end )


jw = false
aj = false

vortsnd = {
	[1] = "vo/outland_01/intro/ol01_vortcall01.wav",
	[2] = "vo/outland_01/intro/ol01_vortcall02c.wav",
	[3] = "vo/outland_01/intro/ol01_vortresp04.wav"
}


function playerVCh(client,args)
if client:Team() == TEAM_VORT then

if client:GetModel() == "models/vortigaunt.mdl" then


	if args == "" then return "" end


client:ConCommand("say /me calls vortigaunts.")
	local DoSay = function(text)
		if text == "" then return end
		for k,v in player.Iterator() do
			if v:Team() == TEAM_VORT and v:GetModel() == "models/vortigaunt.mdl" then
				v:ApexChat([[Color(172, 156, 11), "[VORT-CALL] ", Color(255,255,255), plyNAME, Color(255,0,255),": ", message]], client, text)
			end

			end
		end
		local ran = math.random(1,3)
		client:EmitSound(vortsnd[ran])
	return args, DoSay


else
client:Notify("You must be un-shackled todo this.")

end

else


client:Notify("You must be a vort todo this.")

end

end

apex.commands.Register("/vortcall", playerVCh,0.1)


hook.Add("OnPlayerChangedTeam","VORT-SETCOL", function(client)
client:SetColor(Color(255,255,255,255))
client:SetArmor(0)
client:SendLua([[hook.Remove("PreDrawHalos","Vortessence_Vision")]])

end)


local blockedGravGunEntities = {
	["npc_cscanner"] = true,
	["combine_mine"] = true,
	["pill_hopper"] = true,
	["npc_rollermine"] = true,
	["aw2_manhack"] = true,
	["npc_manhack"] = true,
	["npc_clawscanner"] = true
}

hook.Add("GravGunPickupAllowed", "apex.blockedGravGunEntities", function(entity, client)
	if ( blockedGravGunEntities[entity:GetClass()] ) then
		return false
	end
end)

hook.Add("PlayerSpawnEffect", "EffectCheck", function(client)
	return client:IsAdmin() and client:GetMoveType() == MOVETYPE_NOCLIP
end)


timer.Create("apex.disableCrosshair", 10, 0, function()
	for k, v in player.Iterator() do
		v:CrosshairDisable()
	end
end)

hook.Add("ZAPC_CheckAccess", "apex.ZAPC_CheckAccess", function(client, mode, apc)
	if ( mode == "personal" ) then
		if ( client:IsCombine() and client:GetDarkRPVar("division") == DIVISION_GRID ) then
			return true
		else
			if ( !client.NextAPCNotify or client.NextAPCNotify < CurTime() ) then
				client:Notify("Only GRID units may enter the driver and gunner seat of the APC.")
				client.NextAPCNotify = CurTime() + 1
			end

			return false
		end
	end
end)

local function PlayerAC(client, args)
	if ( !client:IsAdmin() ) then return "" end
	if ( args == "" ) then return "" end

	local DoSay = function(text)
		if ( text == "" ) then return end

		for k, v in player.Iterator() do
			if ( v:IsAdmin() ) then
				v:ApexChat([[Color(124,252,0), "[Admin Chat] ", prefixc, steamNAME, Color(124,252,0),": ", message]], client, text)
			end
		end
	end

	return args, DoSay
end
apex.commands.Register("/ac", PlayerAC)
apex.commands.Register("/adminchat", PlayerAC)