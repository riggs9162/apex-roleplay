apex.xp = apex.xp or {}

local meta = FindMetaTable("Player")

-- Adds XP to the player
function meta:AddXP(amount)
	self:SetXP(self:GetXP() + amount)
end

-- Sets the player's XP
function meta:SetXP(amount)
	amount = math.max(0, amount) -- Ensure XP is not negative

	self:SetNWInt("apex.xp", amount)
	self:SetDarkRPVar("xp", amount)
	self:SaveXP()
end

-- Saves the player's XP to PData
function meta:SaveXP()
	local experience = self:GetXP()
	self:SetPData("apex.xp", experience)
end

-- Removes XP from the player
function meta:TakeXP(amount)
	self:AddXP(-amount)
end

-- Saves the player's XP when they disconnect
hook.Add("PlayerDisconnected", "apex.xp.player.disconnected", function(client)
	local experience = client:GetPData("apex.xp")
	if ( experience == nil ) then
		client:SetPData("apex.xp", 0)
		client:SetXP(0)
	else
		client:SetXP(experience)
	end

	client:SaveXP()
end)

-- Timer interval for XP rewards (10 minutes)
local time = 60 * 10

-- XP amounts for regular and VIP players
local vipXP = 10
local regularXP = 5

-- Function to give XP to players
function apex.xp.Give(client)
	if ( apex.xp.double:GetBool() ) then
		vipXP = vipXP * 2
		regularXP = regularXP * 2
	end

	if ( client:GetDarkRPVar("AFK") ) then
		client:ChatPrint("You did not get any XP because you are AFK!")
	elseif ( client:IsUserGroup("vip") ) then
		client:AddXP(vipXP)
		client:ChatPrint("For playing on the server (and owning VIP) for 10 minutes, you have been awarded " .. vipXP .. " XP!")
	else
		client:AddXP(regularXP)
		client:ChatPrint("For playing on the server for 10 minutes, you have been awarded " .. regularXP .. " XP!")
	end
end

-- Hook to create a timer for XP rewards when a player joins
hook.Add("PlayerInitialSpawn", "apex.xp.player.spawn.initial", function(client)
	-- Load the player's XP from PData
	local experience = client:GetPData("apex.xp")
	if ( experience == nil ) then
		client:SetPData("apex.xp", 0)
		client:SetXP(0)
	else
		client:SetXP(experience)
	end

	local timerName = "apex.xp." .. client:SteamID64()
	timer.Create(timerName, time, 0, function()
		if ( IsValid(client) ) then
			apex.xp.Give(client)
		else
			timer.Remove(timerName)
		end
	end)
end)