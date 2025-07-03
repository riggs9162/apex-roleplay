ENT.Type = "anim"
ENT.PrintName = "Vending Machine"
ENT.Category = "Apex Roleplay"
ENT.Author = "Riggs, Datamats"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Stocks")
    self:NetworkVar("Float", 1, "Active")
end

function ENT:GetNearestButton(client)
    client = client or (CLIENT and LocalPlayer())

    if not self.buttons then return end

    if SERVER then
        local position = self:GetPos()
        local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

        local offsets = {
            Vector(18, -24.4, 5.3),
            Vector(18, -24.4, 3.35),
            Vector(18, -24.4, 1.35)
        }

        for i, offset in ipairs(offsets) do
            self.buttons[i] = position + f * offset.x + r * offset.y + u * offset.z
        end
    end

    local traceData = {
        start = client:GetShootPos(),
        endpos = client:GetShootPos() + client:GetAimVector() * 96,
        filter = client
    }
    local trace = util.TraceLine(traceData)
    local hitPos = trace.HitPos

    if hitPos then
        for k, buttonPos in ipairs(self.buttons) do
            if buttonPos:Distance(hitPos) <= 2 then
                return k
            end
        end
    end
end