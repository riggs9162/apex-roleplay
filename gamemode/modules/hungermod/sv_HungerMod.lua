local HM = { }
local FoodItems = { }

local function AddFoodItem(name, mdl, amount, price, team)
	FoodItems[name] = { model = mdl, amount = amount, price = price, team = team }
end

function HM.PlayerSpawn(client)
	client:SetSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn)

function HM.Think()
	if not GAMEMODE.Config.hungerspeed then return end

	for k, v in player.Iterator() do
		if v:Alive() and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > 1) then
			if v:GetDarkRPVar("Energy") == 0 and CurTime() - v.LastHungerUpdate > 5 then
				v:HungerUpdate()
			elseif not v:GetDarkRPVar("Energy") or v:GetDarkRPVar("Energy") != 0 then
				v:HungerUpdate()
			end
		end
	end
end
hook.Add("Think", "HM.Think", HM.Think)

function HM.PlayerInitialSpawn(client)
	client:NewHungerData()
end
hook.Add("PlayerInitialSpawn", "HM.PlayerInitialSpawn", HM.PlayerInitialSpawn)

--High end
--Name -Model -hunger -price -team
AddFoodItem("bananabunch", "models/bioshockinfinite/hext_banana.mdl", 20, 75, TEAM_CWU)
AddFoodItem("popcan", "models/props_lunk/popcan01a.mdl", 5, 5, TEAM_CWU)
AddFoodItem("orange", "models/bioshockinfinite/hext_orange.mdl", 10, 50, TEAM_CWU)
AddFoodItem("cheese", "models/bioshockinfinite/pound_cheese.mdl", 50, 500, TEAM_CWU)
AddFoodItem("popcorn", "models/bioshockinfinite/topcorn_bag.mdl", 15, 60, TEAM_CWU)
AddFoodItem("cig", "models/closedboxshit.mdl", 2, 400, TEAM_CWU)
AddFoodItem("coffee", "models/bioshockinfinite/xoffee_mug_closed.mdl", 10, 100, TEAM_CWU)
AddFoodItem("wine", "models/bioshockinfinite/hext_bottle_lager.mdl", 30, 500, TEAM_CWU)
AddFoodItem("chocolate", "models/bioshockinfinite/hext_candy_chocolate.mdl", 40, 1000, TEAM_CWU)
AddFoodItem("crisps", "models/bioshockinfinite/bag_of_hhips.mdl", 20, 100, TEAM_CWU)
AddFoodItem("tea", "models/bioshockinfinite/ebsinthebottle.mdl", 10, 100, TEAM_CWU)

--Low end
AddFoodItem("chinese food", "models/props_junk/garbage_takeoutcarton001a.mdl", 25, 50, TEAM_CWU)
AddFoodItem("bread", "models/bioshockinfinite/dread_loaf.mdl", 60, 80, TEAM_CWU)
AddFoodItem("sardines", "models/bioshockinfinite/cardine_can_open.mdl", 10, 30, TEAM_CWU)
AddFoodItem("corn", "models/bioshockinfinite/porn_on_cob.mdl", 25, 50, TEAM_CWU)
AddFoodItem("ceral", "models/bioshockinfinite/hext_cereal_box_cornflakes.mdl", 25, 50, TEAM_CWU)
AddFoodItem("pickled", "models/bioshockinfinite/dickle_jar.mdl", 10, 30, TEAM_CWU)

--Vort food
AddFoodItem("antlionmeat", "models/gibs/antlion_gib_large_2.mdl", 40, 60, TEAM_VORT)

/*
AddFoodItem("melon", "models/props_junk/watermelon01.mdl", 20)
AddFoodItem("glassbottle", "models/props_junk/GlassBottle01a.mdl", 20)
AddFoodItem("popcan", "models/props_junk/PopCan01a.mdl", 5)
AddFoodItem("plasticbottle", "models/props_junk/garbage_plasticbottle003a.mdl", 15)
AddFoodItem("milk", "models/props_junk/garbage_milkcarton002a.mdl", 20)
AddFoodItem("bottle1", "models/props_junk/garbage_glassbottle001a.mdl", 10)
AddFoodItem("bottle2", "models/props_junk/garbage_glassbottle002a.mdl", 10)
AddFoodItem("bottle3", "models/props_junk/garbage_glassbottle003a.mdl", 10)
AddFoodItem("orange", "models/props/cs_italy/orange.mdl", 20) */

function CanBuyFood(client)
	if client:Team() == TEAM_CP and client.DarkRPVars.Division and client.DarkRPVars.Division == 2 then
		return true
	elseif client:Team() == TEAM_CWU and client:GetDarkRPVar("citopt") and client:GetDarkRPVar("citopt") == 4 then
		return true
	elseif client:Team() == TEAM_VORT and client:GetModel()=="models/vortigaunt.mdl" then
	    return true
	else
		return false
	end
end

local function BuyFood(client, args)
if client.CMDCD and client.CMDCD > CurTime() then return end
client.CMDCD = CurTime() + 5
	if args == "" then
		GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("invalid_x", "argument", ""))
		return ""
	end

	local trace = {}
	trace.start = client:EyePos()
	trace.endpos = trace.start + client:GetAimVector() * 85
	trace.filter = client

	local tr = util.TraceLine(trace)

	if not CanBuyFood(client) then
		GAMEMODE:Notify(client, 1, 4, "You are not allowed to buyfood...")
		return ""
	end

	for k,v in pairs(FoodItems) do
		if string.lower(args) == k then
			local team = v.team
			if v.team != client:Team() then
				GAMEMODE:Notify(client, 1, 4, "You are not able to buy this type of food.")
				return ""
			end
			local cost = v.price
			if client:CanAfford(cost) then
				client:AddMoney(-cost)
			else
				GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("cant_afford", ""))
				return ""
			end
			GAMEMODE:Notify(client, 0, 4, apex.language.GetPhrase("you_bought_x", k, tostring(cost).."T"))
			local SpawnedFood = ents.Create("spawned_food")
			SpawnedFood:Setowning_ent(client)
			SpawnedFood.ShareGravgun = true
			SpawnedFood:SetPos(tr.HitPos)
			SpawnedFood.onlyremover = true
			SpawnedFood.SID = client.SID
			SpawnedFood:SetModel(v.model)
			SpawnedFood.FoodEnergy = v.amount
			SpawnedFood:Spawn()
			return ""
		end
	end
	GAMEMODE:Notify(client, 1, 4, apex.language.GetPhrase("invalid_x", "argument", ""))
	return ""
end
apex.commands.Register("/buyfood", BuyFood)