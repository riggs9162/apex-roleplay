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
	concommand.Add("debug_getid",function(p)
		p:ChatPrint(p:GetEyeTrace().Entity:MapCreationID())
		p:ChatPrint(p:GetEyeTrace().Entity:GetClass())
	end)
end

if ( CLIENT ) then
	local tbl = {}
	concommand.Add("debug_adddoor",function()
		local e = LocalPlayer():GetEyeTrace().Entity
		if e then
			table.insert(tbl,e:GetPos())
		end
		for v,k in pairs(tbl)do
			print("Vector("..k.x..","..k.y..","..k.z.."),")
		end
	end)
end

print("Map config module initialized for " .. game.GetMap())