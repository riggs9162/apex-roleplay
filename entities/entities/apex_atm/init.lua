
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/props_combine/combine_intwallunit.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
--	self:DropToFloor()
end

function ENT:OnTakeDamage( dmg ) 
	return false
end

function ENT:AcceptInput( name, activator, caller )
	if ( name == "Use" and IsValid( activator ) and activator:IsPlayer() ) then
		if ( activator:GetPData( "pin" ) == "100500" ) then
			activator:ConCommand( "apex_atm_nopin" )
		else
			activator:ConCommand( "apex_atm_open" )
		end
	end
end

local function CommaTheCash( num )
	if ( !num ) then return end

	for i = string.len( num ) - 3, 1, -3 do 
		num = string.sub( num, 1, i ) .. "," .. string.sub( num, i + 1 )
	end 
	return num
end

local function AreWeNearATM( client )
	for id, ent in pairs( ents.FindInSphere( client:GetPos(), 84) ) do
		if ( ent:GetClass() == "apex_atm" ) then
			return true
		end
	end
	return false
end

hook.Add( "PlayerInitialSpawn", "apex_atm_PSMoney", function( client )
	if client:GetPData( "bankmoney2" ) == nil then client:SetPData( "bankmoney2", 0 ) end
	if client:GetPData( "pin" ) == nil then client:SetPData( "pin", 100500 ) end
end )

concommand.Add( "apex_atm_setpin", function( pl, cmd, args )
	if ( !AreWeNearATM( pl ) ) then pl:Notify( "You must be near an ATM to use it!" ) return end
	if ( isnumber( tonumber( args[1] ) ) and string.len( args[1] ) == 4 ) then
		pl:SetPData( "pin", tostring( args[1] ) )
		pl:Notify( "PIN Code set to: " .. tostring( args[1] )  )
		pl:ConCommand( "apex_atm_open" )
	else
		pl:Notify( "Entered incorrect PIN!" )
	end
end )

concommand.Add( "apex_atm_login", function( pl, cmd, args )

if pl.CMDCD and pl.CMDCD > CurTime() then return end
pl.CMDCD = CurTime() + 3
	if ( !AreWeNearATM( pl ) ) then pl:Notify( "You must be near an ATM to use it!" ) return end
	for k, v in pairs( player.GetAll() ) do
		if tostring( args[2] ) == tostring( v:UniqueID() ) or v:UniqueID() == "1" then /* In SP on Server, UniqueID is 1 */
			if args[1] == util.CRC( v:GetPData( "pin" ) ) and tostring( v:GetPData( "pin" ) ) != "100500" then 
				pl:ConCommand("apex_atm_account " .. args[1] .. " " .. args[2] .. " " .. v:GetPData( "bankmoney2" ) )
			else
				pl:Notify( "Entered incorrect PIN!" )
			end
		end
	end
end )

concommand.Add( "apex_atm_deposit", function( pl, cmd, args )

if pl.CMDCD and pl.CMDCD > CurTime() then return end
pl.CMDCD = CurTime() + 4
	if ( !AreWeNearATM( pl ) ) then pl:Notify( "You must be near an ATM to use it!" ) return end
	if ( !tonumber( args[3] ) ) then pl:Notify( "Entered incorrect amount!" ) return end

	local target = pl
	for k, v in pairs( player.GetAll() ) do
		if tostring( args[2] ) == tostring( v:UniqueID() ) or v:UniqueID() == "1" then target = v end
	end

	if ( IsValid( target ) and math.floor( args[3] ) >= 0 and target.DarkRPVars.money - math.floor( args[3] ) >= 0 and args[1] == util.CRC( target:GetPData( "pin" ) ) ) then
		pl:AddMoney( -args[3] )
		target:SetPData( "bankmoney2", target:GetPData( "bankmoney2" ) + math.floor( args[3] ) )
		pl:ConCommand( "apex_atm_account " .. args[1] .. " "  .. args[2] .. " " .. target:GetPData( "bankmoney2" ) )
	else
		pl:Notify( "Error occured!" )
	end
end )

concommand.Add( "apex_atm_withdraw", function( pl, cmd, args )

if pl.CMDCD and pl.CMDCD > CurTime() then return end
pl.CMDCD = CurTime() + 4
	if ( !AreWeNearATM( pl ) ) then pl:Notify( "You must be near an ATM to use it!" ) return end
	if ( !tonumber( args[3] ) ) then pl:Notify( "Entered incorrect amount!" ) return end

	local target = pl
	for k, v in pairs( player.GetAll() ) do
		if tostring( args[2] ) == tostring( v:UniqueID() ) or v:UniqueID() == "1" then target = v end
	end

	if ( IsValid( target ) and tonumber( target:GetPData( "bankmoney2" ) ) >= tonumber( args[3] ) and tonumber( args[3] ) > 0 and args[1] == util.CRC( target:GetPData( "pin" ) ) ) then
		pl:AddMoney( args[3] )
		target:SetPData( "bankmoney2", target:GetPData( "bankmoney2" ) - math.floor( args[3] ) )
		pl:ConCommand( "apex_atm_account " .. args[1] .. " "  .. args[2] .. " " .. target:GetPData( "bankmoney2" ) )
	else
		pl:Notify( "Error occured!" )
	end
end )

concommand.Add( "apex_atm_money_send", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	client:Notify( "---ATM Banked Money---" )
	for k, v in pairs( player.GetAll() ) do
		print( v:Nick() .. "'s account has $" .. CommaTheCash( tonumber( v:GetPData( "bankmoney2" ) ) ) .. "." )
		client:Notify( v:Nick() .. "'s account has $" .. CommaTheCash( tonumber( v:GetPData( "bankmoney2" ) ) ) .. "." )
	end
end )

concommand.Add( "apex_atm_pincodes_send", function( client )
	if ( !client:IsSuperAdmin() ) then return end
	client:Notify( "---ATM PIN Codes---" )
	for k, v in pairs( player.GetAll() ) do
		if tostring( v:GetPData( "pin" ) ) == "100500" then
			print( v:Nick() .. " has the PIN Code: -NONE-." )
			client:Notify( v:Nick() .. " has the PIN Code: -NONE-." )
		else
			print( v:Nick() .. " has the PIN Code: " .. v:GetPData( "pin" ) .. "." )
			client:Notify( v:Nick() .. " has the PIN Code: " .. v:GetPData( "pin" ) .. "." )
		end
	end
end )

concommand.Add( "apex_atm_admin_account", function( client, cmd, args )
	if ( !AreWeNearATM( client ) ) then client:Notify( "You must be near an ATM to use it!" ) return end
	if ( !client:IsSuperAdmin() ) then return end
	for k, v in pairs( player.GetAll() ) do
		if ( tostring( v:UniqueID() ) == tostring( args[1] ) or v:UniqueID() == "1" ) then
			client:ConCommand("apex_atm_account " .. util.CRC( v:GetPData( "pin" ) ) .. " " .. args[1] .. " " .. v:GetPData( "bankmoney2" ) )
		end
	end
end )

concommand.Add( "apex_atm_admin_resetmoney", function( client, cmd, args )
	if ( !client:IsSuperAdmin() ) then return end
	for k, v in pairs( player.GetAll() ) do
		if ( tostring( v:UniqueID() ) == tostring( args[1] ) or v:UniqueID() == "1" ) then
			v:SetPData( "bankmoney2", 0 )
			client:Notify( v:Nick() .. "'s bank has been set to: " .. v:GetPData( "bankmoney2" ) )
		end
	end
end )

concommand.Add( "apex_atm_admin_resetpin", function( client, cmd, args )
	if ( !client:IsSuperAdmin() ) then return end
	for k, v in pairs( player.GetAll() ) do
		if ( tostring( v:UniqueID() ) == tostring( args[1] ) or v:UniqueID() == "1" ) then
			v:SetPData( "pin", "100500" )
			client:Notify( v:Nick() .. "'s PIN has been reset." )
		end
	end
end )

concommand.Add( "apex_atm_admin_setpin", function( pl, cmd, args )
	if ( !pl:IsSuperAdmin() ) then return end
	if ( !isnumber( tonumber( args[2] ) ) or string.len( args[2] ) != 4 ) then pl:Notify( "Entered incorrect PIN!" ) return end

	for k, v in pairs( player.GetAll() ) do
		if ( tostring( v:UniqueID() ) == tostring( args[1] ) or v:UniqueID() == "1" ) then
			v:SetPData( "pin", tostring( args[ 2 ] ) )
			pl:Notify( v:Nick() .. "'s PIN has been set to: " .. v:GetPData( "pin" ) )
		end
	end
end )

concommand.Add( "apex_atm_resetallaccounts", function( pl )
	if ( !pl:IsSuperAdmin() ) then return end

	for k, v in pairs( player.GetAll() ) do
		v:SetPData( "pin", 100500 )
		v:SetPData( "bankmoney2", 0 )
	end
end )
