include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

local color_halo = Color(0, 0, 255)
hook.Add("PreDrawHalos", "apex.armor.halo", function()
	local entities = {}
	for _, ent in ipairs(ents.FindByClass("apex_ammo_crate")) do
		if ( IsValid(ent) and ent:IsLineOfSightClear(LocalPlayer()) ) then
			table.insert(entities, ent)
		end
	end

	halo.Add(entities, color_halo, 0, 0, 0)
end)