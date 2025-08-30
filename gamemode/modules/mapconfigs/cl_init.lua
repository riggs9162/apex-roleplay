local viewButtons = CreateClientConVar("apex_mapconfig_viewbuttons", "0", true, false, "View buttons with their map creation IDs in the world. Only visible to admins.")

hook.Add("HUDPaint", "apex.mapconfig.viewbuttons", function()
    if ( !viewButtons:GetBool() ) then return end

    local client = LocalPlayer()
    if ( !client:IsAdmin() ) then return end

    for _, ent in ipairs(ents.FindByClass("class C_BaseToggle")) do
        if ( ent:MapCreationID() > 0 ) then
            local pos = ent:GetPos()
            local screenPos = pos:ToScreen()
            draw.SimpleTextOutlined(tostring(ent), "DermaDefault", screenPos.x, screenPos.y - 5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
            draw.SimpleTextOutlined(ent:MapCreationID(), "DermaDefault", screenPos.x, screenPos.y + 5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
    end
end)