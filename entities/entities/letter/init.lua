AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/paper01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	local phys = self:GetPhysicsObject()

	phys:Wake()
	hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected)
end

function ENT:OnRemove()
	local client = self:Getowning_ent()
	if not IsValid(client) then return end
	if not client.maxletters then
		client.maxletters = 0
	end
	client.maxletters = client.maxletters - 1
end

function ENT:Use(client)
	if not client:KeyDown(IN_ATTACK) then
		umsg.Start("ShowLetter", client)
			umsg.Entity(self)
			umsg.Short(self.type)
			umsg.Vector(self:GetPos())
			local numParts = self.numPts
			umsg.Short(numParts)
			for a,b in pairs(self.Parts) do umsg.String(b) end
		umsg.End()
	else
		umsg.Start("KillLetter", client)
		umsg.End()
	end
end

function ENT:SignLetter(client)
	self:Setsigned(client)
end

function ENT:onPlayerDisconnected(client)
	if self.dt.owning_ent == client then
		self:Remove()
	end
end

concommand.Add("_DarkRP_SignLetter", function(client, cmd, args)
	if not args[1] then return end
	local letter = ents.GetByIndex(tonumber(args[1]))

	letter:SignLetter(client)
end)