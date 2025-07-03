local plyMeta = FindMetaTable("Player")

function plyMeta:IsArrested()
	return self:GetDarkRPVar("Arrested")
end