AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/items/ammocrate_ar2.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local physicsObject = self:GetPhysicsObject()
	if ( IsValid(physicsObject) ) then
		physicsObject:EnableMotion(false)
		physicsObject:Sleep()
	end
end

local AmmoSettings = {
	["Pistol"] = 94,
	["357"] = 50,
	["SMG1"] = 500,
	["slam"] = 3,
	["Grenade"] = 1,
	["AR2"] = 300,
	["Buckshot"] = 52,
	["XBowBolt"] = 45
}

function ENT:Use(client)
	if ( !IsValid(client) or !client:IsPlayer() ) then return end

	if ( self.NextUse and self.NextUse > CurTime() ) then
		client:Notify("You must wait a few seconds before using this again!")
		return
	end

	for ammoType, maxAmmo in pairs(AmmoSettings) do
		local currentAmmo = client:GetAmmoCount(ammoType)
		if ( currentAmmo < maxAmmo ) then
			local ammoToGive = maxAmmo - currentAmmo
			client:GiveAmmo(ammoToGive, ammoType, true)
		end
	end

	self:ResetSequence(self:LookupSequence("open"))
	self:EmitSound("items/ammocrate_open.wav", 70, 100, 1, CHAN_AUTO)

	timer.Simple(0.5, function()
		if ( IsValid(self) ) then
			self:EmitSound("items/ammo_pickup.wav", 70, 100, 1, CHAN_AUTO)
		end
	end)

	timer.Simple(1, function()
		if ( IsValid(self) ) then
			self:ResetSequence(self:LookupSequence("close"))
			self:EmitSound("items/ammocrate_close.wav", 70, 100, 1, CHAN_AUTO)
		end
	end)

	client:Notify("Your ammo has been restocked.")

	self.NextUse = CurTime() + 2
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end