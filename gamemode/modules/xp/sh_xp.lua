apex.xp = apex.xp or {}
apex.xp.double = CreateConVar("apex_xp_double", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enable double XP for the server. 0 = Disabled, 1 = Enabled")

local meta = FindMetaTable("Player")

-- Gets the player's XP
function meta:GetXP()
    return self:GetNWInt("apex.xp", 0)
end

-- Prints the player's XP to their chat
concommand.Add("apex_xp_get", function(client)
    if ( SERVER ) then return end

    client:Notify("Your XP is: " .. client:GetXP())
end)

-- Sets the player's XP
concommand.Add("apex_xp_set", function(client, _, args)
    if ( CLIENT ) then return end
    if ( !client:IsAdmin() ) then
        client:Notify("You do not have permission to set XP!")
        return
    end

    local xp = tonumber(args[1])
    if ( !xp or xp < 0 ) then
        client:Notify("Invalid XP value.")
        return
    end

    local target
    local trailingArgs = table.concat(args, " ", 2)
    if ( trailingArgs and trailingArgs != "" ) then
        target = GAMEMODE:FindPlayer(trailingArgs)
    else
        target = client
    end

    target:SetXP(xp)
    target:Notify("Your XP has been set to: " .. xp)
end)