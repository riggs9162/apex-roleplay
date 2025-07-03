ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fadmin MOTD"
ENT.Information = "Place this MOTD somewhere, freeze it and it will be saved automatically"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:CanTool(client, trace, tool)
	if client:IsAdmin() and tool == "remover" then
		self.CanRemove = true
		if SERVER then FAdmin.MOTD.RemoveMOTD(self, client) end
		return true
	end
	return false
end

function ENT:PhysgunPickup(client)
	local PickupPos = Vector(1.8079, -0.6743, -62.3193)
	if client:IsAdmin() and PickupPos:Distance(self:WorldToLocal(client:GetEyeTrace().HitPos)) < 7 then return true end
	return false
end