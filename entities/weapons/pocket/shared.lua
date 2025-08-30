if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Pocket"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "FPtje and everyone who gave FPtje the idea"
SWEP.Instructions = "Left click to pick up, right click to drop, reload for menu"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 0
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "normal"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

if CLIENT then
	SWEP.FrameVisible = false
end

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if not SERVER then return end
	--self:SetWeaponHoldType("normal")
	self:GetOwner():DrawViewModel(false)
	self:GetOwner():DrawWorldModel(false)
end

function SWEP:PreDrawViewModel()
		return false;
end

function SWEP:Equip(newOwner)
	if not SERVER then return end

	local t = self:GetOwner():Team()
	self.MaxPocketItems = RPExtraTeams[t] and RPExtraTeams[t].maxpocket or GAMEMODE.Config.pocketitems

	local i = self:GetOwner().Pocket and #self:GetOwner().Pocket or 0
	while i > self.MaxPocketItems do
		self:GetOwner():DropPocketItem(self:GetOwner().Pocket[i])
		self:GetOwner().Pocket[i] = nil
		i = i - 1
	end
end

local blacklist = {"fadmin_jail", "drug_lab", "money_printer", "meteor", "microwave", "door", "func_", "player", "beam", "worldspawn", "env_", "path_", "spawned_shipment", "prop_physics", "prop_static", "prop", "pill", "npc", "scanner", "hl2rp_rawration", "hl2rp_rationoven", "hl2rp_ration_maker", "hl2rp_beerbrewer", "club", "apex_atm", "ironsight_357", "weapon_shotgun", "weapon_smg1", "ironsight_pistol", "weapon_ar2", "Keypad", "gmod_light", "gmod_emitter", "gmod_button", "gmod_wire_keypad", "gmod_wire_button", "gmod_wire_expression", "gmod_wire_light", "Keypad_Wire", "gmod_wire_", "gmod_", "trash_logic", "trash_", "ration", "nexus_ration", "spawned_trash", "ironsight_", "sight_", "sight_smg2", "sight_usp2", "ironsight_mozin","item_healthcharger","re_microphone","re_radio", "rebel_microphone", "rebel_radio", "combine_mine"}
function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	local trace = self:GetOwner():GetEyeTrace()

	if not IsValid(trace.Entity) or (SERVER and trace.Entity:IsPlayerHolding()) then
		return
	end

	if self:GetOwner():EyePos():Distance(trace.HitPos) > 150 then
		return
	end


	if CLIENT then return end

	local phys = trace.Entity:GetPhysicsObject()
	if not phys:IsValid() then return end
	local mass = trace.Entity.RPOriginalMass and trace.Entity.RPOriginalMass or phys:GetMass()

	self:GetOwner():GetTable().Pocket = self:GetOwner():GetTable().Pocket or {}
	if not trace.Entity:CPPICanPickup(self:GetOwner()) or trace.Entity.IsPocketed or trace.Entity.jailWall then
		self:GetOwner():Notify("You can not put this in your pocket!")
		return
	end
	for k,v in pairs(blacklist) do
		if string.find(string.lower(trace.Entity:GetClass()), v) then
			self:GetOwner():Notify( "You can not put this in your pocket!")
			return
		end
	end

	if mass > 100 then
		self:GetOwner():Notify( "This object is too heavy.")
		return
	end

	if #self:GetOwner():GetTable().Pocket >= self.MaxPocketItems then
		self:GetOwner():Notify( "Your pocket is full!")
		return
	end


	umsg.Start("Pocket_AddItem", self:GetOwner())
		umsg.Short(trace.Entity:EntIndex())
	umsg.End()

	table.insert(self:GetOwner():GetTable().Pocket, trace.Entity)
	trace.Entity:SetNoDraw(true)
	trace.Entity:SetPos(trace.Entity:GetPos())
	local phys = trace.Entity:GetPhysicsObject()
	phys:EnableMotion(false)
	trace.Entity.OldCollisionGroup = trace.Entity:GetCollisionGroup()
	trace.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	trace.Entity.PhysgunPickup = false
	trace.Entity.OldPlayerUse = trace.Entity.PlayerUse
	trace.Entity.PlayerUse = false
	trace.Entity.IsPocketed = true
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)

	if CLIENT then return end

	if not self:GetOwner():GetTable().Pocket or #self:GetOwner():GetTable().Pocket <= 0 then
		self:GetOwner():Notify( "Your pocket contains no items.")
		return
	end

	timer.Simple(0.2, function() if self:IsValid() then self:NewSetWeaponHoldType("normal") end end)

	local ent = self:GetOwner():GetTable().Pocket[#self:GetOwner():GetTable().Pocket]
	self:GetOwner():GetTable().Pocket[#self:GetOwner():GetTable().Pocket] = nil
	if not IsValid(ent) then self:GetOwner():Notify( "Your pocket contains no items.") return end

	self:GetOwner():DropPocketItem(ent)
end

SWEP.OnceReload = false
function SWEP:Reload()
	if CLIENT or self.Weapon.OnceReload or not IsValid(self.Weapon) then return end
	self.Weapon.OnceReload = true
	timer.Simple(0.5, function() if IsValid(self) and IsValid(self.Weapon) then self.Weapon.OnceReload = false end end)

	if not self:GetOwner():GetTable().Pocket or #self:GetOwner():GetTable().Pocket <= 0 then
		self:GetOwner():Notify( "Your pocket contains no items.")
		return
	end

	for k,v in pairs(self:GetOwner():GetTable().Pocket) do
		if not IsValid(v) then
			self:GetOwner():GetTable().Pocket[k] = nil
			self:GetOwner():GetTable().Pocket = table.ClearKeys(self:GetOwner():GetTable().Pocket)
			if #self:GetOwner():GetTable().Pocket <= 0 then -- Recheck after the entities have been validated.
				self:GetOwner():Notify( "Your pocket contains no items.")
				return
			end
		end
	end

	umsg.Start("StartPocketMenu", self:GetOwner())
	umsg.End()
end

if CLIENT then
	local frame
	local function Reload()
		if not ValidPanel(frame) or not frame:IsVisible() then return end
		local items = LocalPlayer():GetTable().Pocket
		if not items or next(items) == nil then frame:Close() return end
		frame:SetSize(#items * 64, 90)
		frame:Center()
		for k,v in pairs(items) do
			if not IsValid(v) then
				items[k] = nil
				for a,b in pairs(LocalPlayer().Pocket) do
					if b == v or not IsValid(b) then
						LocalPlayer():GetTable().Pocket[a] = nil
					end
				end
				items = table.ClearKeys(items)
				frame:Close()
				PocketMenu()
				break
			end
			local icon = vgui.Create("SpawnIcon", frame)
			icon:SetPos((k-1) * 64, 25)
			icon:SetModel(v:GetModel())
			icon:SetSize(64, 64)
			icon:SetToolTip()
			icon.DoClick = function()
				icon:SetToolTip()
				RunConsoleCommand("_RPSpawnPocketItem", v:EntIndex())
				items[k] = nil
				for a,b in pairs(LocalPlayer().Pocket) do
					if b == v then
						LocalPlayer():GetTable().Pocket[a] = nil
					end
				end
				if #items == 0 then
					frame:Close()
					return
				end
				items = table.ClearKeys(items)
				Reload()
				--LocalPlayer():GetActiveWeapon():SetWeaponHoldType("pistol")
				timer.Simple(0.2, function() if LocalPlayer():GetActiveWeapon():IsValid() then LocalPlayer():GetActiveWeapon():SetWeaponHoldType("normal") end end)
			end
		end
	end

	local function StorePocketItem(um)
		LocalPlayer():GetTable().Pocket = LocalPlayer():GetTable().Pocket or {}

		local ent = Entity(um:ReadShort())
		if IsValid(ent) and not table.HasValue(LocalPlayer():GetTable().Pocket, ent) then
			table.insert(LocalPlayer():GetTable().Pocket, ent)
		end

		Reload()
	end
	usermessage.Hook("Pocket_AddItem", StorePocketItem)

	local function RemovePocketItem(um)
		LocalPlayer():GetTable().Pocket = LocalPlayer():GetTable().Pocket or {}

		local ent = Entity(um:ReadShort())
		for k,v in pairs(LocalPlayer():GetTable().Pocket) do
			if v == ent then LocalPlayer():GetTable().Pocket[k] = nil end
		end

		Reload()
	end
	usermessage.Hook("Pocket_RemoveItem", RemovePocketItem)

	local function PocketMenu()
		if frame and frame:IsValid() and frame:IsVisible() then return end
		if LocalPlayer():GetActiveWeapon():GetClass() != "pocket" then return end
		if not LocalPlayer():GetTable().Pocket then LocalPlayer():GetTable().Pocket = {} return end
		for k,v in pairs(LocalPlayer():GetTable().Pocket) do if not IsValid(v) then table.remove(LocalPlayer():GetTable().Pocket, k) end end
		if #LocalPlayer():GetTable().Pocket <= 0 then return end
		LocalPlayer():GetTable().Pocket = table.ClearKeys(LocalPlayer():GetTable().Pocket)
		frame = vgui.Create("DFrame")
		frame:SetTitle("Drop item")
		frame:SetVisible(true)
		frame:MakePopup()

		Reload()
		frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
	end
	usermessage.Hook("StartPocketMenu", PocketMenu)
elseif SERVER then
	local function Spawn(client, cmd, args)
		if not IsValid(client:GetActiveWeapon()) or client:GetActiveWeapon():GetClass() != "pocket" then
			return
		end
		if client:GetTable().Pocket and IsValid(Entity(tonumber(args[1]))) then
			local ent = Entity(tonumber(args[1]))
			if not table.HasValue(client.Pocket, ent) then return end

			for k,v in pairs(client:GetTable().Pocket) do
				if v == ent then
					client:GetTable().Pocket[k] = nil
				end
			end
			client:GetTable().Pocket = table.ClearKeys(client:GetTable().Pocket)

			--client:GetActiveWeapon():SetWeaponHoldType("pistol")
			timer.Simple(0.2, function() if client:GetActiveWeapon():IsValid() then client:GetActiveWeapon():SetWeaponHoldType("normal") end end)

			client:DropPocketItem(ent)
		end
	end
	concommand.Add("_RPSpawnPocketItem", Spawn)

	local meta = FindMetaTable("Player")
	function meta:DropPocketItem(ent)
		local trace = {}
		trace.start = self:EyePos()
		trace.endpos = trace.start + self:GetAimVector() * 85
		trace.filter = self
		local tr = util.TraceLine(trace)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetNoDraw(false)
		ent:SetCollisionGroup(ent.OldCollisionGroup)
		ent:SetPos(tr.HitPos)
		ent:SetSolid(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
			phys:Wake()
		end
		umsg.Start("Pocket_RemoveItem", self)
			umsg.Short(ent:EntIndex())
		umsg.End()
		ent.PhysgunPickup = nil
		ent.PlayerUse = ent.OldPlayerUse
		ent.OldPlayerUse = nil
		ent.IsPocketed = nil
	end

	hook.Add("PlayerDeath", "DropPocketItems", function(client)
		local pocket = client.Pocket
		if not GAMEMODE.Config.droppocketdeath or not pocket then return end

		client.Pocket = nil

		for k, v in pairs(pocket) do
			if IsValid(v) then
				client:DropPocketItem(v)
			end
		end
	end)
end
