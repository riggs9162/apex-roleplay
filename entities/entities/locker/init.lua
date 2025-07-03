AddCSLuaFile( "cl_init.lua" ) -- This means the client will download these files

AddCSLuaFile( "shared.lua" )

include('shared.lua') -- At this point the contents of shared.lua are ran on the server only.





function ENT:Initialize( ) --This function is run when the entity is created so it's a good place to setup our entity.

	

	self:SetModel( "models/props_wasteland/controlroom_storagecloset001a.mdl" ) -- Sets the model of the NPC.

	self:SetSolid( SOLID_VPHYSICS ) 

	self:SetUseType( SIMPLE_USE )

end

function ENT:OnTakeDamage()

	return false

end 



function ENT:AcceptInput( Name, Activator, Caller )	



	if Name == "Use" and Caller:IsPlayer() then

		if Caller:Team() == TEAM_CITIZEN or Caller:Team() == TEAM_VORT then

			umsg.Start("ChangeOutfit", Caller) -- Prepare the usermessage to that same player to open the menu on his side.

			umsg.End() -- We don't need any content in the usermessage so we're sending it empty now.

		end

	end

	

end



concommand.Add( "apex_citizensuitup", function( client, cmd, args )

if client:Team() == TEAM_VORT then

client:SetModel("models/vortigaunt.mdl")

end

	if client:Team() == TEAM_CITIZEN then
		for id, ent in pairs( ents.FindInSphere( client:GetPos(), 100 ) ) do
			if ( ent:GetClass() == "locker" ) then
				if string.match( client:GetModel(), "group03" ) and client.oldmodel then
					client:Notify("You are no longer wearing a rebel outfit.")
					client:SetModel( client.oldmodel )
					client:UpdateJob("Citizen")
					client:SetArmor(0)
                    apex.db.Log(client:Nick().." ("..client:SteamID64()..") is no longer a rebel.", nil, Color(0, 255, 255))
					return
				else 
					client.oldmodel = client:GetModel()
					suitedModel = string.Replace( client:GetModel(), "group01", "group03" )
					client:SetModel(suitedModel)
					client:UpdateJob("Rebel")
					client:SetArmor(30)
					client:Notify("You are now wearing a rebel outfit.")
					apex.db.Log(client:Nick().." ("..client:SteamID64()..") is now a rebel.", nil, Color(0, 255, 255))
					return
				end
			end
		end
		
		client:Notify("You are not close enough to a locker.")
	else
		client:Notify("You sneaky bastard.")
	end

end)