AddCSLuaFile( "cl_init.lua" ) -- This means the client will download these files
AddCSLuaFile( "shared.lua" )

include('shared.lua') -- At this point the contents of shared.lua are ran on the server only.


function ENT:Initialize( ) --This function is run when the entity is created so it's a good place to setup our entity.

	self:SetModel( "models/props_c17/Lockers001a.mdl" ) -- Sets the model of the NPC.
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
end

function ENT:OnTakeDamage()
	return false
end

function ENT:AcceptInput( Name, Activator, Caller )
	if Name == "Use" and Caller:IsPlayer() then
		if Caller:Team() == TEAM_CWU then
			umsg.Start("ChangeOutfitCWU", Caller) -- Prepare the usermessage to that same player to open the menu on his side.
			umsg.End() -- We don't need any content in the usermessage so we're sending it empty now.
		end
	end
end

concommand.Add( "apex_cwusuitup", function( client, cmd, args )
	if client:Team() == TEAM_CWU then
		if client:GetDarkRPVar("citopt") == 3 then
			for id, ent in pairs( ents.FindInSphere( client:GetPos(), 100 ) ) do
				if ( ent:GetClass() == "uniform" ) then
					if string.match( client:GetModel(), "industrial" ) and client.oldmodel1 then
						client:Notify("You are no longer wearing factory garments.")
						client:SetModel( client.oldmodel1 )
						return
					else
						client.oldmodel1 = client:GetModel()
						suitedModel = "models/industrial_uniforms/industrial_uniform2.mdl"
						client:SetModel(suitedModel)
						client:Notify("You are now wearing factory garments.")
						return
					end
				end
			end

			client:Notify("You are not close enough to a locker.")
		else
			client:Notify("You sneaky bastard.")
		end
	end
end)
