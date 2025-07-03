AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- These are the default laws, they're unchangeable in-game.
local Laws = {
	"Do not attack other citizens except in self-defence.",
	"Do not steal or break in to peoples homes.",
	"Money printers/drugs are illegal."
}

local FixedLaws = table.Copy(Laws)

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/Billboard.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

local function AddLaw(client, args)
	if not RPExtraTeams[client:Team()] or not RPExtraTeams[client:Team()].mayor then
		GAMEMODE:Notify(client, 1, 4, "You must be the mayor to set laws!")
		return ""
	end

	if string.len(args) < 3 then
		GAMEMODE:Notify(client, 1, 4, "Law too short.")
		return ""
	end

	if #Laws >= 12 then
		GAMEMODE:Notify(client, 1, 4, "The laws are full.")
		return ""
	end

	table.insert(Laws, args)

	umsg.Start("DRP_AddLaw")
		umsg.String(args)
	umsg.End()

	GAMEMODE:Notify(client, 0, 2, "Law added.")

	return ""
end
apex.commands.Register("/addlaw", AddLaw)

local function RemoveLaw(client, args)
	if not RPExtraTeams[client:Team()] or not RPExtraTeams[client:Team()].mayor then
		GAMEMODE:Notify(client, 1, 4, "You must be the mayor to remove laws!")
		return ""
	end

	if not tonumber(args) then
		GAMEMODE:Notify(client, 1, 4, "Invalid arguments.")
		return ""
	end

	if not Laws[ tonumber(args) ] then
		GAMEMODE:Notify(client, 1, 4, "Invalid law.")
		return ""
	end

	if FixedLaws[ tonumber(args) ] then
		GAMEMODE:Notify(client, 1, 4, "You are not allowed to change the default laws.")
		return ""
	end

	table.remove(Laws, tonumber(args))

	umsg.Start("DRP_RemoveLaw")
		umsg.Char(tonumber(args))
	umsg.End()

	GAMEMODE:Notify(client, 0, 2, "Law removed.")

	return ""
end
apex.commands.Register("/removelaw", RemoveLaw)

local numlaws = 0
local function PlaceLaws(client, args)
	if not RPExtraTeams[client:Team()] or not RPExtraTeams[client:Team()].mayor then
		GAMEMODE:Notify(client, 1, 4, "You must be the mayor to place a list of laws.")
		return ""
	end

	if numlaws >= GAMEMODE.Config.maxlawboards then
		GAMEMODE:Notify(client, 1, 4, "You have reached the max number of laws you can place!")
		return ""
	end

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	local ent = ents.Create("darkrp_laws")
	ent:SetPos(tr.HitPos + Vector(0, 0, 100))

	local ang = client:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)
	ent:SetAngles(ang)

	ent:CPPISetOwner(client)
	ent.SID = client.SID

	ent:Spawn()
	ent:Activate()

	if IsValid(ent) then
		numlaws = numlaws + 1
	end

	client.lawboards = client.lawboards or {}
	table.insert(client.lawboards, ent)

	return ""
end
apex.commands.Register("/placelaws", PlaceLaws)

function ENT:OnRemove()
	numlaws = numlaws - 1
end

hook.Add("PlayerInitialSpawn", "SendLaws", function(client)
	for i, law in pairs(Laws) do
		if FixedLaws[i] then continue end

		umsg.Start("DRP_AddLaw", client)
			umsg.String(law)
		umsg.End()
	end
end)