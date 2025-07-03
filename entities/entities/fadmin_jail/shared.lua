ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fadmin_jail"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:CanTool()
	return false
end

function ENT:PhysgunPickup(client)
	return false
end