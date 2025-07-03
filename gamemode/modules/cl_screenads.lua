apex = apex or {}
apex.screenads = apex.screenads or {}

function apex.screenads.Init()
    if ( IsValid(apex.screenads.panel) ) then
        apex.screenads.panel:Remove()
    end

    local panel = vgui.Create("DNotify")
    panel:SetPos(15, 50)
    panel:SetSize(ScrW() - 40, ScrH() - 80)

    local label = vgui.Create("DLabel", panel)
    label:Dock(TOP)
    label:SetText("Loading...")
    label:SetFont("GModNotify")
    label:SetTextColor(color_white)

    panel:AddItem(label)

    apex.screenads.panel = panel
end

function apex.screenads.ChangeAd(text, col)
    local panel = apex.screenads.panel
    if ( !IsValid(panel) ) then
        apex.screenads.Init()
    end

    local label = vgui.Create("DLabel", panel)
    label:Dock(TOP)
    label:SetText(text)
    label:SetTextColor(col)
    label:SetFont("GModNotify")

    panel:SetLife(12)
    panel:AddItem(label)
end

apex.screenads.Init()

local screenAds = {
    "Join us on Discord by typing discord.apex-roleplay.com into your browser.",
    "Connect with us online, goto apex-roleplay.com",
    "Want to donate? Type !vip in chat."
}

if ( timer.Exists("apex-screen-ads") ) then
    timer.Remove("apex-screen-ads")
end

timer.Create("apex-screen-ads", 300, 0, function()
    apex.screenads.ChangeAd(screenAds[math.random(#screenAds)], color_white)
end)