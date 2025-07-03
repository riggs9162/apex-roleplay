util.AddNetworkString( "DrunkVomit" )

local meta = FindMetaTable( "Player" )

function meta:addDrunkLevel(num)
	if self:GetDarkRPVar("DrunkLevel") then
		self:SetDarkRPVar("DrunkLevel", self:GetDrunkLevel()+num)
	else
		self:SetDarkRPVar("DrunkLevel", num)
	end
end

function meta:SetDrunkLevel(num)
	self:SetDarkRPVar("DrunkLevel", num)
end

function meta:GetDrunkLevel()
	return self:GetDarkRPVar("DrunkLevel")
end

function meta:SetLastVomit()
	self:SetDarkRPVar("LastVomit", CurTime())
end

function meta:GetLastVomit()
	if not self:GetDarkRPVar("LastVomit") then return 0 end
	return CurTime()-self:GetDarkRPVar("LastVomit");
end

function meta:vomit()
	net.Start( "DrunkVomit" )
	net.Send(self)

	local edata = EffectData()

	edata:SetOrigin( self:EyePos() )

	edata:SetEntity( self )



	util.Effect( "vomit", edata, true, true )
end

function meta:hasMaxBarrels()

	local numb = 0
	for k, v in pairs( ents.FindByClass( "hl2rp_beerbrewer" ) ) do
			if self:SteamID64() == v.SID then
				numb = numb +1
			end
		--PrintTable(v:GetTable())

	end
	if numb > 1 then
		return true
	end
		return false
end

timer.Create( "DrunkThink", 4, 0, function()
	for k, client in pairs( player.GetAll() ) do

		if client:GetDrunkLevel() and client:GetDrunkLevel() > 0 then
			--print(client:GetDrunkLevel()-0.1)-- Debug Only print
			client:SetDrunkLevel(client:GetDrunkLevel()-0.1)
		end

		if client:GetDrunkLevel() and client:GetDrunkLevel() > 28 then
			if client:GetLastVomit() == 0 then client:SetLastVomit() end
			if client:GetLastVomit() > 30 then
				client:vomit()
				
				client:SetLastVomit()
			end
		end		

		if client:GetDrunkLevel() and client:GetDrunkLevel() > 52 then
			client:Kill();
		end		

	end

end)

hook.Add("OnPlayerChangedTeam", "RemoveDrunkOnChange", function(client)
	client:SetDrunkLevel(0)
end)

hook.Add("PlayerDeath", "RemoveDrunkOnDeath", function(client)
	client:SetDrunkLevel(0)
end)


concommand.Add("apex_vomit", function(client)

	if not client:IsAdmin() then return end

	client:vomit()
end)

concommand.Add("apex_getdrunk", function(client)

	if not client:IsAdmin() then return end

	client:addDrunkLevel(10)
end)

concommand.Add("apex_getsober", function(client)

	if not client:IsAdmin() then return end

	client:SetDrunkLevel(0)
end)


