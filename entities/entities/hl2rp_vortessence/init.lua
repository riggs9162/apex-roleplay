AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")




function ENT:Initialize()


self:SetModel('models/spitball_medium.mdl') 

self:SetColor(Color(0, 96, 255, 255))
self:SetMaterial('models/prop_combine/prtl_sky_sheet')


	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType(SOLID_VPHYSICS)   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()

	phys:Wake()





end




function ENT:Use(a,client)

if client:Team()== TEAM_VORT then 


if client:GetModel()=='models/vortigaunt.mdl' then

client:SetColor(Color(186,129,251,255))
client:SendLua('StartVortessence()')
client:Notify('You have consumed the Larval Extract. 600 seconds until it expires.')

timer.Simple(600, function()
if IsValid(client) then
if client:Team()==TEAM_VORT then
client:Notify('The effects of the Larval Extract have expired.')
client:SetColor(Color(255,255,255,255))
end
end
end)


self:Remove()


else


client:Notify('You must unchained to use the Larval Extract.')
end
else


client:Notify('You must be a vortigaunt to use the Larval Extract.')
end

end
