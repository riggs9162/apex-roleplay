AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/health_charger001.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)

    local physicsObject = self:GetPhysicsObject()
    if ( IsValid(physicsObject) ) then
        physicsObject:EnableMotion(false)
        physicsObject:Sleep()
    end
end

function ENT:Use(_, client, _)
    if ( !IsValid(client) or !client:IsPlayer() ) then return end

    if ( self.NextUse and self.NextUse > CurTime() ) then
        client:Notify("You must wait a few seconds before using this again!")
        return
    end

    client:SetHealth(client:GetMaxHealth())
    client:Notify("You have been fully healed!")
    self:EmitSound("items/medshot4.wav", 70, 100, 1, CHAN_AUTO)

    self.NextUse = CurTime() + 5
end