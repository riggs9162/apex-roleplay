apex.mapconfig = apex.mapconfig or {}
apex.mapconfig.stored = apex.mapconfig.stored or {}

function apex.mapconfig.Get()
	local map = game.GetMap()
	if ( !apex.mapconfig.stored[map] ) then
		print("No map config found for " .. map)
		return
	end

	return apex.mapconfig.stored[map]
end

function apex.mapconfig.Register(map, tbl)
	if ( !map or !tbl ) then
		print("Invalid map config registration")
		return
	end

	if ( map != game.GetMap() ) then
		print("Map config registration for " .. map .. " does not match current map " .. game.GetMap())
		return
	end

	if ( !apex.mapconfig.stored[map] ) then
		apex.mapconfig.stored[map] = {}
	end

	for k, v in pairs(tbl) do
		apex.mapconfig.stored[map][k] = v
	end

	print("Registered map config for " .. map)
end

if ( SERVER ) then
	concommand.Add("debug_getid",function(client, cmd, args)
		local trace = client:GetEyeTrace()
		local entity = trace.Entity
		if ( !IsValid(entity) ) then
			client:ChatPrint("No valid entity under your crosshair.")
			return
		end

		client:ChatPrint(entity:MapCreationID())
		client:ChatPrint(entity:GetClass())
	end)
end

if ( CLIENT ) then
	local tbl = {}
	concommand.Add("debug_add_door",function(client, cmd, args)
		if ( !IsValid(client) ) then return end
		local entity = client:GetEyeTrace().Entity
		if ( IsValid(entity) ) then
			table.insert(tbl, entity:GetPos())
		end

		for k, v in pairs(tbl) do
			print("Vector(" .. v.x .. "," .. v.y .. "," .. v.z .. "),")
		end
	end)

	concommand.Add("debug_clear_door",function(client, cmd, args)
		if ( !IsValid(client) ) then return end
		tbl = {}
		print("Cleared door positions.")
	end)
end

print("Map config module initialized for " .. game.GetMap())