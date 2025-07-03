AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_package.mdl")
	self:SetMaterial("phoenix_storms/pack2/chrome")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()
	if ( IsValid(physicsObject) ) then
		physicsObject:EnableMotion(true)
		physicsObject:Wake()
	end
end

function ENT:Think()
	if ( self:GetPos():Distance(Vector(3049.688232, 5610.471680, 384.133270)) > 400 ) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetRadius(6)
		effectdata:SetScale(3)
		util.Effect("TeslaZap", effectdata)

		sound.Play("ambient/energy/zap5.wav", self:GetPos())

		SafeRemoveEntity(self)
	end

	self:NextThink(CurTime())

	return true
end

function ENT:Use(client)
	if ( self:IsPlayerHolding() ) then
		client:DropObject(self)
	end

	client:PickupObject( self )
end

function ENT:OnRemove()
end