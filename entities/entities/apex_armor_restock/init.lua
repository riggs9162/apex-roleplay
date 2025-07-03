AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local ArmorSettings = {
    {
        canUse = function(client) return client:Team() == TEAM_OVERWATCH end,
        options = {
            {
                check = function(client)
                    return client:GetSkin() == 1
                end,
                armor = 200,
                message = "Your armor has been restocked because you are an Overwatch unit (+MACE armor)."
            },
            {
                check = function(client)
                    return client:GetModel():lower():find("models/combine_super_soldier.mdl")
                end,
                armor = 180,
                message = "Your armor has been restocked because you are an Overwatch unit (+KING armor)."
            },
            {
                check = function(client)
                    return true
                end,
                armor = 150,
                message = "Your armor has been restocked because you are an Overwatch unit."
            }
        }
    },
    {
        canUse = function(client)
            return client:Team() == TEAM_CP
        end,
        options = {
            {
                check = function(client)
                    return true
                end,
                armor = 40,
                message = "Your armor has been restocked because you are a Civil Protection unit."
            }
        }
    }
}

function ENT:Initialize()
    self:SetModel("models/props_combine/suit_charger001.mdl")
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

    for _, teamSettings in ipairs(ArmorSettings) do
        if ( teamSettings.canUse(client) ) then
            for _, opt in ipairs(teamSettings.options) do
                if ( opt.check(client) ) then
                    client:SetArmor(opt.armor)
                    client:Notify(opt.message)
                    self:EmitSound("items/suitchargeok1.wav", 70, 100, 1, CHAN_AUTO)
                    break
                end
            end
        end
    end

    self.NextUse = CurTime() + 5
end