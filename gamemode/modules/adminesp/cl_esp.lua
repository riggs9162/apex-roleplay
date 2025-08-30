local showesp = CreateClientConVar("apex_admin_esp", "0", true, false, "Enable or disable the admin ESP feature.")

local function isRebelPlayer(ply)
    return ply:Alive() and ply:GetModel():lower():find("group03") != nil
end

local color_background = Color(0, 0, 0, 230)

hook.Add("HUDPaint", "apex.admin.esp", function()
    local client = LocalPlayer()
    if not (client:IsAdmin() and client:GetMoveType() == MOVETYPE_NOCLIP and showesp:GetBool()) then return end

    local rebelCount = 0
    local teamColorCache = {}
    local players = player.GetAll()

    for i = 1, #players do
        local v = players[i]
        if v != client then
            local rebel = isRebelPlayer(v)
            if rebel then
                rebelCount = rebelCount + 1
            end

            local pos = v:LocalToWorld(v:OBBCenter()):ToScreen()
            local teamID = v:Team()
            local color = teamColorCache[teamID]
            if ( !color ) then
                color = team.GetColor(teamID)
                teamColorCache[teamID] = color
            end

            draw.DrawText(v:Nick(), "TargetID", pos.x, pos.y, color, TEXT_ALIGN_CENTER)

            if ( rebel ) then
                draw.DrawText("REBEL", "TargetID", pos.x, pos.y + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end
    end

    for _, ent in ents.Iterator() do
        local class = ent:GetClass()
        if ( class == "apex_cp_npc" or class == "apex_ota_npc" ) then
            local pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
            local label = class == "apex_cp_npc" and "CP NPC" or "OTA NPC"
            draw.DrawText(label, "TargetID", pos.x, pos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end
    end

    local scrW, scrH = ScrW(), ScrH()
    local width, height = scrW / 7, 140
    local x, y = 10, scrH / 2 - height / 2

    surface.SetDrawColor(color_background)
    surface.DrawRect(x, y, width, height)

    draw.DrawText("Players connected: " .. #players .. "/" .. game.MaxPlayers(), "TargetID", x + 10, y + 10, Color(255, 255, 255))
    draw.DrawText("Cached entity count: " .. #ents.GetAll(), "TargetID", x + 10, y + 30, Color(255, 255, 255))
    draw.DrawText("Total combine: " .. (#team.GetPlayers(TEAM_CP) + #team.GetPlayers(TEAM_OVERWATCH)), "TargetID", x + 10, y + 50, Color(255, 255, 255))
    draw.DrawText("Total citizens: " .. #team.GetPlayers(TEAM_CITIZEN) - rebelCount, "TargetID", x + 10, y + 70, Color(255, 255, 255))
    draw.DrawText("Total rebels: " .. rebelCount, "TargetID", x + 10, y + 90, Color(255, 255, 255))
    draw.DrawText("Total workers: " .. #team.GetPlayers(TEAM_CWU), "TargetID", x + 10, y + 110, Color(255, 255, 255))
end)

concommand.Add("apex_admin_esp_toggle", function(ply)
    if ( !ply:IsAdmin() ) then return end

    showesp:SetBool(!showesp:GetBool())
    LocalPlayer():Notify("Admin ESP is now " .. (showesp:GetBool() and "enabled" or "disabled") .. ".")
end)