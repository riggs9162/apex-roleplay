

local function Createatmmachine( pos, ang )
	local atm = ents.Create( "apex_atm" )
	atm:SetPos( pos )
	atm:SetAngles( ang )
	atm:Spawn()
	atm:Activate()
end 

local function Loadatms()
	if ( file.Exists( "atm/"..string.lower( game.GetMap() )..".txt", "DATA" ) ) then
		local atms = util.JSONToTable( file.Read( "atm/" .. string.lower( game.GetMap() ) .. ".txt" ) )
		for id, tab in pairs( atms ) do
			Createatmmachine( tab.pos, tab.ang )
		end
	else
		MsgN("atm Spawn file is missing for map " .. string.lower( game.GetMap() ) )
	end
end

concommand.Add( "apex_atm_removespawns", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	file.Delete( "atm/"..string.lower( game.GetMap() )..".txt" )
end )

concommand.Add( "apex_atm_savespawns", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	local tableOfatms = {}
	for k, v in pairs( ents.FindByClass( "apex_atm" ) ) do
		table.insert( tableOfatms, { ang = v:GetAngles(), pos = v:GetPos() } )
	end
	if ( !file.IsDir( "atm", "DATA" ) ) then file.CreateDir( "atm" ) end
	file.Write( "atm/"..string.lower( game.GetMap() ) .. ".txt", util.TableToJSON( tableOfatms ) )
end )

concommand.Add( "apex_atm_respawnall", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	for k, v in pairs( ents.FindByClass( "apex_atm" ) ) do v:Remove() end
	Loadatms()
end )

concommand.Add( "apex_atm_removeall", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	for k, v in pairs( ents.FindByClass( "apex_atm" ) ) do v:Remove() end
end )

timer.Simple( 2, function()
	for k, v in pairs( ents.FindByClass( "apex_atm" ) ) do v:Remove() end
	Loadatms()
end )