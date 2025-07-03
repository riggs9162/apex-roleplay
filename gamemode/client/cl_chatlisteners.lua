-----------------------------------------------------------------------------[[
/*---------------------------------------------------------------------------
This module finds out for you who can see you talk or speak through the microphone
---------------------------------------------------------------------------*/
-----------------------------------------------------------------------------]]

/*---------------------------------------------------------------------------
Variables
---------------------------------------------------------------------------*/
local receivers
local currentChatText = {}
local receiverConfigs = {
	[""] = { -- The default config decides who can hear you when you speak normally
		text = "talk",
		hearFunc = function(client)
			if GAMEMODE.Config.alltalk then return nil end

			return LocalPlayer():GetPos():Distance(client:GetPos()) < 250
		end
	}
}

local currentConfig = receiverConfigs[""] -- Default config is normal talk

/*---------------------------------------------------------------------------
AddChatReceiver
Add a chat command with specific receivers

prefix: the chat command itself ("/pm", "/ooc", "/me" are some examples)
text: the text that shows up when it says "Some people can hear you X"
hearFunc: a function(client, splitText) that decides whether this player can or cannot hear you.
	return true if the player can hear you
		   false if the player cannot
		   nil if you want to prevent the text from showing up temporarily
---------------------------------------------------------------------------*/
function GM:AddChatReceiver(prefix, text, hearFunc)
	receiverConfigs[prefix] = {
		text = text,
		hearFunc = hearFunc
	}
end

/*---------------------------------------------------------------------------
removeChatReceiver
Remove a chat command.

prefix: the command, like in addChatReceiver
---------------------------------------------------------------------------*/
function GM:removeChatReceiver(prefix)
	receiverConfigs[prefix] = nil
end

/*---------------------------------------------------------------------------
Draw the results to the screen
---------------------------------------------------------------------------*/
local function drawChatReceivers()
	if not receivers then return end

	local x, y = chat.GetChatBoxPos()
	y = y - 21

	-- No one hears you
	if #receivers == 0 then
		draw.WordBox(2, x, y, apex.language.GetPhrase("hear_noone", currentConfig.text), "ChatFont", Color(0,0,0,160), Color(255,10,10,255))
		return
	-- Everyone hears you
	elseif #receivers == #player.GetAll() - 1 then
		draw.WordBox(2, x, y, apex.language.GetPhrase("hear_everyone"), "ChatFont", Color(0,0,0,160), Color(0,255,0,255))
		return
	end

	draw.WordBox(2, x, y - (#receivers * 21), apex.language.GetPhrase("hear_certain_persons", currentConfig.text), "ChatFont", Color(0,0,0,160), Color(0,255,0,255))
	for i = 1, #receivers, 1 do
		if not IsValid(receivers[i]) then
			receivers[i] = receivers[#receivers]
			receivers[#receivers] = nil
			continue
		end

		draw.WordBox(2, x, y - (i - 1)*21, receivers[i]:Nick(), "ChatFont", Color(0,0,0,160), Color(255,255,255,255))
	end
end

/*---------------------------------------------------------------------------
Find out who could hear the player if they were to speak now
---------------------------------------------------------------------------*/
local function chatGetRecipients()
	if not currentConfig then return end

	receivers = {}
	for _, client in player.Iterator() do
		if client:FAdmin_GetGlobal("FAdmin_cloaked") then continue end
		if not IsValid(client) or client == LocalPlayer() then continue end
		local val = currentConfig.hearFunc(client, currentChatText)

		-- Return nil to disable the chat recipients temporarily.
		if val == nil then
			receivers = nil
			return
		elseif val == true then
			table.insert(receivers, client)
		end
	end
end

/*---------------------------------------------------------------------------
Called when the player starts typing
---------------------------------------------------------------------------*/
local function startFind()
	currentConfig = receiverConfigs[""]
	hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
	hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("StartChat", "DarkRP_StartFindChatReceivers", startFind)

/*---------------------------------------------------------------------------
Called when the player stops typing
---------------------------------------------------------------------------*/
local function stopFind()
	hook.Remove("Think", "DarkRP_chatRecipients")
	hook.Remove("HUDPaint", "DarkRP_DrawChatReceivers")
end
hook.Add("FinishChat", "DarkRP_StopFindChatReceivers", stopFind)

/*---------------------------------------------------------------------------
Find out which chat command the user is typing
---------------------------------------------------------------------------*/
local function findConfig(text)
	local split = string.Explode(' ', text)
	local prefix = string.lower(split[1])

	currentChatText = split

	currentConfig = receiverConfigs[prefix] or receiverConfigs[""]
end
hook.Add("ChatTextChanged", "DarkRP_FindChatRecipients", findConfig)



GM:AddChatReceiver("/ooc", "speak in OOC", function(client) return true end)
GM:AddChatReceiver("//", "speak in OOC", function(client) return true end)
GM:AddChatReceiver("/a", "speak in OOC", function(client) return true end)
GM:AddChatReceiver("/w", "whisper", function(client) return LocalPlayer():GetPos():Distance(client:GetPos()) < 90 end)
GM:AddChatReceiver("/y", "yell", function(client) return LocalPlayer():GetPos():Distance(client:GetPos()) < 550 end)
GM:AddChatReceiver("/me", "perform your action", function(client) return LocalPlayer():GetPos():Distance(client:GetPos()) < 250 end)
GM:AddChatReceiver("/looc", "speak in LOOC", function(client) return LocalPlayer():GetPos():Distance(client:GetPos()) < 250 end)
GM:AddChatReceiver(".//", "speak in LOOC", function(client) return LocalPlayer():GetPos():Distance(client:GetPos()) < 250 end)
GM:AddChatReceiver("/g", "talk to your group", function(client)
	for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
		if func(LocalPlayer()) and func(client) then
			return true
		end
	end
	return false
end)

GM:AddChatReceiver("/pm", "PM", function(client, text)
	if not isstring(text[2]) then return false end
	text[2] = string.lower(tostring(text[2]))

	return string.find(string.lower(client:Nick()), text[2], 1, true) != nil or
		string.find(string.lower(client:SteamName()), text[2], 1, true) != nil or
		string.lower(client:SteamID64()) == text[2]
end)

/*---------------------------------------------------------------------------
Voice chat receivers
---------------------------------------------------------------------------*/
GM:AddChatReceiver("speak", "speak", function(client)
	if not LocalPlayer().DRPIsTalking then return nil end
	if LocalPlayer():GetPos():Distance(client:GetPos()) > 550 then return false end

	return not GAMEMODE.Config.dynamicvoice or client:IsInRoom()
end)

/*---------------------------------------------------------------------------
Called when the player starts using their voice
---------------------------------------------------------------------------*/
local function startFindVoice(client)
	if client != LocalPlayer() then return end

	currentConfig = receiverConfigs["speak"]
	hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
	hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("PlayerStartVoice", "DarkRP_VoiceChatReceiverFinder", startFindVoice)

/*---------------------------------------------------------------------------
Called when the player stops using their voice
---------------------------------------------------------------------------*/
local function stopFindVoice(client)
	if client != LocalPlayer() then return end

	stopFind()
end
hook.Add("PlayerEndVoice", "DarkRP_VoiceChatReceiverFinder", stopFindVoice)

-- THE FOLLOWING FUNCTION IS REMOVED IN REFACTOR BRANCH
local meta = FindMetaTable("Player")
function meta:IsInRoom()
	local tracedata = {}
	tracedata.start = LocalPlayer():GetShootPos()
	tracedata.endpos = self:GetShootPos()
	local trace = util.TraceLine(tracedata)

	return not trace.HitWorld
end
