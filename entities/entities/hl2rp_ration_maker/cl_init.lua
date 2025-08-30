include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local imgui = apex.imgui
    if ( imgui.Entity3D2D(self, Vector(-14, 22, 25), Angle(0, 0, 270), 0.1, 1024, 512) ) then
        imgui.Button(0, 0, 64, 64,
            function(width, height, pressing, hovering)
                surface.SetDrawColor(0, 0, 0, 230)
                surface.DrawRect(0, 0, width, height)

                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(0, 0, width, height)

                draw.SimpleText("+", "DermaLarge", width / 2, height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end,
            function()
                net.Start("RationMaker")
                net.SendToServer()
            end
        )
        imgui.Cursor(0, 0, 64, 64)
        imgui.End3D2D()
    end
end