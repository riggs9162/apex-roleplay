local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

apex.net = apex.net or {}
apex.net.globals = apex.net.globals or {}

netstream.Hook("nVar", function(index, key, value)
	apex.net[index] = apex.net[index] or {}
	apex.net[index][key] = value
end)

netstream.Hook("nDel", function(index)
	apex.net[index] = nil
end)

netstream.Hook("nLcl", function(key, value)
	apex.net[LocalPlayer():EntIndex()] = apex.net[LocalPlayer():EntIndex()] or {}
	apex.net[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("gVar", function(key, value)
	apex.net.globals[key] = value
end)

function getNetVar(key, default)
	local value = apex.net.globals[key]

	return value != nil and value or default
end

function entityMeta:getNetVar(key, default)
	local index = self:EntIndex()

	if (apex.net[index] and apex.net[index][key] != nil) then
		return apex.net[index][key]
	end

	return default
end

playerMeta.getLocalVar = entityMeta.getNetVar