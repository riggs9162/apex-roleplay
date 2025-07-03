include('shared.lua')

local draw_SimpleText = draw.SimpleText
local glowMaterial = Material("sprites/glow04_noz")

local colors = {
    green = Color(0, 255, 0, 255),
    red = Color(255, 0, 0, 255),
    orange = Color(255, 125, 0, 255),
    white = Color(255, 255, 255, 255)
}

local buttonOffsets = {
    Vector(18, -24.4, 5.3),
    Vector(18, -24.4, 3.35),
    Vector(18, -24.4, 1.35)
}

function ENT:Initialize()
    self.buttons = {}
    local position = self:GetPos()
    local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

    for i, offset in ipairs(buttonOffsets) do
        self.buttons[i] = position + f * offset.x + r * offset.y + u * offset.z
    end
end

function ENT:Draw()
    self:DrawModel()

    local position, angles = self:GetPos(), self:GetAngles()
    angles:RotateAroundAxis(angles:Up(), 90)
    angles:RotateAroundAxis(angles:Forward(), 90)

    local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

    -- Draw 3D2D text
    cam.Start3D2D(position + f * 17.33 + r * -19.5 + u * 5.75, angles, 0.06)
        for i, text in ipairs({"Regular", "Sparkling", "Special"}) do
            draw_SimpleText(text, "ChatFont", 0, (i - 1) * 36, colors.white, 0, 0)
        end
    cam.End3D2D()

    -- Render glowing buttons
    render.SetMaterial(glowMaterial)

    if self.buttons then
        local stocks = util.JSONToTable(self:GetStocks())
        local closest = self:GetNearestButton()

        for k, buttonPos in ipairs(self.buttons) do
            local color = self:GetActive() and colors.green or colors.orange

            if self:GetActive() and stocks and stocks[k] and stocks[k] < 1 then
                color = table.Copy(colors.red)
                color.a = 200
            end

            if self:GetActive() and closest != k then
                color.a = color == colors.red and 100 or 75
            elseif self:GetActive() and closest == k then
                color.a = 230 + math.sin(RealTime() * 7.5) * 25
            end

            if LocalPlayer():KeyDown(IN_USE) and closest == k then
                color = table.Copy(color)
                color.r = math.min(color.r + 100, 255)
                color.g = math.min(color.g + 100, 255)
                color.b = math.min(color.b + 100, 255)
            end

            render.DrawSprite(buttonPos, 4, 4, color)
        end
    end
end