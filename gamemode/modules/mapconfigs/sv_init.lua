local ent
local no
local function checkAPC(pos, ang)
	local mapConfig = apex.mapconfig.Get()
	if ( !mapConfig ) then return end

	pos = pos or mapConfig.APCSpawnPos or Vector(0, 0, 0)
	ang = ang or mapConfig.APCSpawnAng or Angle(0, 0, 0)

	no = true
	for k, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
		no = false
	end

	if ( no ) then
		ent = ents.Create("prop_vehicle_zapc")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent:Activate()

		for k, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
			local arg = "Civil Protection"
			v:UnOwn()

			v.DoorData = v.DoorData or {}
			v.DoorData.TeamOwn = nil
			v.DoorData.GroupOwn = arg
			v:Fire("lock")

			if ( arg == "" ) then
				v.DoorData.GroupOwn = nil
				v.DoorData.TeamOwn = nil
			end

			apex.db.SetDoorGroup(v, arg)
			apex.db.StoreTeamDoorOwnability(v)
		end
	end
end

concommand.Add("apex_respawn_apc", function(client)
	if ( !client:IsAdmin() ) then return end

	checkAPC()
end)

hook.Add("InitPostEntity", "apex.mapconfig.InitPostEntity", function()
	local mapConfig = apex.mapconfig.Get()
	if ( !mapConfig ) then return end

	for k, v in ipairs(ents.FindByName("Diesel_timer")) do
		SafeRemoveEntity(v)
	end

	for k, v in ipairs(ents.FindByName("train_timer")) do
		SafeRemoveEntity(v)
	end

	if ( mapConfig.RemoveObjByPos ) then
		for _, pos in ipairs(mapConfig.RemoveObjByPos) do
			for _, ent in ipairs(ents.FindInSphere(pos, 10)) do
				if ( ent:GetPos() == pos ) then
					SafeRemoveEntity(ent)
				end
			end
		end
	end

	if ( mapConfig.RemoveArmor == true ) then
		for k, v in ipairs(ents.FindByClass("item_suitcharger")) do
			SafeRemoveEntity(v)
		end
	end

	if ( mapConfig.RemovePhysProps == true ) then
		for k, v in ipairs(ents.FindByClass("prop_physics")) do
			SafeRemoveEntity(v)
		end
	end

	if ( mapConfig.InitPostEntity ) then
		mapConfig.InitPostEntity()
	end

	local pos = mapConfig.APCSpawnPos or Vector(0, 0, 0)
	local ang = mapConfig.APCSpawnAng or Angle(0, 0, 0)
	checkAPC(pos, ang)
end)

hook.Add("PlayerUse", "apex.mapconfig.PlayerUse", function(client, entity)
	local config = apex.mapconfig.Get()
	if ( !config ) then
		return false
	end

	for k, v in pairs(config.ButtonTable) do
		if ( v.pos and v.pos == entity:GetPos() ) or ( v.id and v.id == entity:MapCreationID() ) then
			if ( !v.check ) then
				return true
			end

			if ( entity.NextUse and entity.NextUse > CurTime() ) then
				return false
			end

			entity.NextUse = CurTime() + 1

			if ( v.check(client, entity) == false ) then
				return false
			end
		end
	end
end)