AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent. 
include('shared.lua')
 

function ENT:Initialize()
 
	self:SetModel( "models/weapons/w_packatp.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType(SOLID_VPHYSICS)   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetUseType( SIMPLE_USE )
timer.Simple( 120, function() if self:IsValid() then
self:Remove() end end )
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		timer.Simple(1.4,function() phys:Wake() end)
	end
end

function ENT:Use(client)

if client:Team() == TEAM_CITIZEN then
		client:SetSelfDarkRPVar("Energy", math.Clamp((client:GetDarkRPVar("Energy") or 100) + (100), 0, 100))
                                client:AddMoney(500)
                                client:Notify("Because you are have been awared loyalty points you have recived a bonus ration.")


	umsg.Start("AteFoodIcon", client)
	umsg.End()

	client:EmitSound("Eat.mp3", 100, 100)
	self:Remove()

elseif client:Team() == TEAM_CWU then
		client:SetSelfDarkRPVar("Energy", math.Clamp((client:GetDarkRPVar("Energy") or 100) + (100), 0, 100))
                                client:AddMoney(1000)
                                client:Notify("Because you are have been awared loyalty points you have recived a bonus ration.")


	umsg.Start("AteFoodIcon", client)
	umsg.End()

	client:EmitSound("Eat.mp3", 100, 100)
	self:Remove()

end

end