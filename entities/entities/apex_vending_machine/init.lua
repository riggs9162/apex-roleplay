AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local buttonOffsets = {
	Vector(18, -24.4, 5.3),
	Vector(18, -24.4, 3.35),
	Vector(18, -24.4, 1.35)
}

function ENT:Initialize()
	self:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()
	if ( IsValid(physicsObject) ) then
		physicsObject:EnableMotion(false)
		physicsObject:Sleep()
	end

	self.buttons = {}

	local position = self:GetPos()
	local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()
	for i, offset in ipairs(buttonOffsets) do
		self.buttons[i] = position + f * offset.x + r * offset.y + u * offset.z
	end

	self:SetStocks(util.TableToJSON({10, 5, 5}))
	self:SetActive(1)
end

function ENT:Use(activator)
	activator:EmitSound("buttons/lightswitch2.wav", 55, 125)

	if ( self.nextUse or 0 ) >= CurTime() then return end
	self.nextUse = CurTime() + 2

	local button = self:getNearestButton(activator)
	local stocks = util.JSONToTable(self:GetStocks())

	if activator:IsCombine() then
		self:HandleCombineUse(activator, button, stocks)
		return
	end

	if self:GetActive() == 0 then return end

	if button and stocks and stocks[button] and stocks[button] > 0 then
		self:HandlePurchase(activator, button, stocks)
	end
end

function ENT:HandleCombineUse(activator, button, stocks)
	if activator:KeyDown(IN_SPEED) and button and stocks[button] then
		if stocks[button] > 0 then
			return activator:Notify("NO REFILL IS REQUIRED FOR THIS MACHINE.")
		end

		self:EmitSound("buttons/button5.wav")

		if not activator:CanAfford(20) then
			return activator:Notify("INSUFFICIENT FUNDS (25 TOKENS) TO REFILL MACHINE.")
		end

		activator:Notify("25 TOKENS HAVE BEEN TAKEN TO REFILL MACHINE.")
		activator:AddMoney(-20)

		timer.Simple(1, function()
			if not IsValid(self) then return end
			stocks[button] = button == 1 and 10 or 5
			self:SetStocks(util.TableToJSON(stocks))
		end)
	else
		self:EmitSound("buttons/combine_button1.wav")
	end
end

local items = {
	[1] = {name = "water", price = 5, power = 1, skin = 0},
	[2] = {name = "water_sparkling", price = 15, power = 3, skin = 2},
	[3] = {name = "water_special", price = 20, power = 5, skin = 1},
}

function ENT:HandlePurchase(activator, button, stocks)

	local item = items[button]
	if not item then return end

	if not activator:CanAfford(item.price) then
		self:EmitSound("buttons/button2.wav")
		return activator:Notify("You need " .. item.price .. " tokens to purchase this selection.")
	end

	local position = self:GetPos()
	local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

	local spawnedFood = ents.Create("spawned_food")
	spawnedFood.ShareGravgun = true
	spawnedFood:SetPos(position + f * 9 + r * 4 + u * -12)
	spawnedFood.onlyremover = true
	spawnedFood:SetModel("models/props_junk/PopCan01a.mdl")
	spawnedFood.FoodEnergy = item.power
	spawnedFood:Spawn()
	spawnedFood:SetSkin(item.skin or 0)

	stocks[button] = stocks[button] - 1
	if stocks[button] < 1 then
		self:EmitSound("buttons/button6.wav")
	end

	self:SetStocks(util.TableToJSON(stocks))
	self:EmitSound("buttons/button4.wav")

	activator:AddMoney(-item.price)
	activator:Notify("You have spent " .. item.price .. " tokens on this vending machine.")
end
