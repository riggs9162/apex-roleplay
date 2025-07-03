local playerMeta = FindMetaTable("Player")

function playerMeta:setWepRaised(state)
	-- Sets the networked variable for being raised.
	self:setNetVar("raised", state)

	-- Delays any weapon shooting.
	local weapon = self:GetActiveWeapon()

	if (IsValid(weapon)) then
		weapon:SetNextPrimaryFire(CurTime() + 1)
		weapon:SetNextSecondaryFire(CurTime() + 1)
	end
end

-- Inverts whether or not the weapon is raised.
function playerMeta:toggleWepRaised()
	self:setWepRaised(!self:isWepRaised())

	local weapon = self:GetActiveWeapon()

	if (IsValid(weapon)) then
		if (self:isWepRaised() and weapon.OnRaised) then
			weapon:OnRaised()
		elseif (!self:isWepRaised() and weapon.OnLowered) then
			weapon:OnLowered()
		end
	end
end


function GM:Notify(client, msgtype, len, msg)
	if not IsValid(client) then return end
	umsg.Start("_Notify", client)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function GM:NotifyAll(msgtype, len, msg)
	umsg.Start("_Notify")
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function GM:PrintMessageAll(msgtype, msg)
	for k, v in player.Iterator() do
		v:PrintMessage(msgtype, msg)
	end
end

function GM:TalkToRange(client, PlayerName, Message, size)
	local ents = ents.FindInSphere(client:EyePos(), size)
	local col = team.GetColor(client:Team())
	local filter = RecipientFilter()
	filter:RemoveAllPlayers()
	for k, v in pairs(ents) do
		if v:IsPlayer() then
			filter:AddPlayer(v)
		end
	end

	if PlayerName == client:Nick() then PlayerName = "" end -- If it's just normal chat, why not cut down on networking and get the name on the client

	umsg.Start("DarkRP_Chat", filter)
		umsg.Short(col.r)
		umsg.Short(col.g)
		umsg.Short(col.b)
		umsg.String(PlayerName)
		umsg.Entity(client)
		umsg.Short(255)
		umsg.Short(255)
		umsg.Short(255)
		umsg.String(Message)
	umsg.End()
end

function GM:TalkToPerson(receiver, col1, text1, col2, text2, sender)
	umsg.Start("DarkRP_Chat", receiver)
		umsg.Short(col1.r)
		umsg.Short(col1.g)
		umsg.Short(col1.b)
		umsg.String(text1)
		if sender then
			umsg.Entity(sender)
		end
		if col2 and text2 then
			umsg.Short(col2.r)
			umsg.Short(col2.g)
			umsg.Short(col2.b)
			umsg.String(text2)
		end
	umsg.End()
end

function GM:FindPlayer(info)
	if not info or info == "" then return nil end
	for k, v in player.Iterator() do
		if tonumber(info) == v:UserID() then
			return v
		end

		if info == v:SteamID64() then
			return v
		elseif info == v:SteamID() then
			return v
		end

		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) != nil then
			return v
		end

		if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) != nil then
			return v
		end
	end

	return nil
end

local blacklisted = {
	"ackbar",
	"adderall",
	"adolf",
	"akbar",
	"allah",
	"allota",
	"anal",
	"anime",
	"anus",
	"applesauce",
	"ardiem",
	"arse",
	"ass",
	"autist",
	"balls",
	"bastard",
	"bellic",
	"biatch",
	"biggums",
	"bigums",
	"bitch",
	"bloody",
	"blow",
	"boi",
	"bollocks",
	"bollok",
	"boner",
	"boners",
	"bonerz",
	"bong",
	"boob",
	"bootie",
	"booty",
	"boss",
	"breen",
	"brownskin",
	"bugger",
	"butt",
	"calhoun",
	"castro",
	"chimp",
	"chimpy",
	"chink",
	"chinks",
	"chong",
	"civil",
	"clitoris",
	"cocaine",
	"cock",
	"coderall",
	"combine",
	"condom",
	"coon",
	"covid",
	"cp",
	"cracker",
	"crap",
	"cum",
	"cunt",
	"daboss",
	"daddy",
	"dahboss",
	"damn",
	"dark",
	"darth",
	"ddos",
	"derp",
	"dev",
	"dick",
	"dildo",
	"dis",
	"doctor",
	"doe",
	"dover",
	"downie",
	"drumpf",
	"dude",
	"dyke",
	"ebola",
	"egg",
	"eight",
	"fag",
	"fagot",
	"fat",
	"feck",
	"feet",
	"felching",
	"fellate",
	"fellatio",
	"fetus",
	"fifth",
	"first",
	"fist",
	"five",
	"flange",
	"foot",
	"foreskin",
	"four",
	"fourth",
	"freeman",
	"fuck",
	"fudgepacker",
	"fuhrer",
	"gae",
	"gay",
	"god",
	"goddamn",
	"goodman",
	"gook",
	"grandma",
	"grandpa",
	"granny",
	"grimes",
	"gurra",
	"gurrazor",
	"harambe",
	"hentai",
	"himmler",
	"hitler",
	"homo",
	"idk",
	"jedi",
	"jerk",
	"jesus",
	"jewy",
	"jizz",
	"jong",
	"jongil",
	"jongun",
	"kek",
	"kleiner",
	"knob",
	"knobend",
	"kok",
	"labia",
	"last",
	"lastname",
	"lil",
	"little",
	"lmao",
	"lmfao",
	"long",
	"lord",
	"magnusson",
	"mama",
	"mao",
	"mcfaggot",
	"mcnigbig",
	"mcnigga",
	"mcnigger",
	"meme",
	"mister",
	"money",
	"monkey",
	"mrs",
	"muff",
	"mungus",
	"muslim",
	"n 1 g",
	"n i g",
	"n1gga",
	"n1gger",
	"nazi",
	"negan",
	"neger",
	"negus",
	"nigg",
	"nil",
	"nine",
	"ninja",
	"ninth",
	"nlgg",
	"normous",
	"normus",
	"null",
	"obama",
	"omg",
	"osama",
	"ota",
	"overwatch",
	"papa",
	"pee",
	"penis",
	"penls",
	"pepe",
	"piss",
	"pissy",
	"pony",
	"poo",
	"porn",
	"pound",
	"prick",
	"princess",
	"protection",
	"pube",
	"pussy",
	"putin",
	"queer",
	"rasputin",
	"reich",
	"samurai",
	"satan",
	"schlong",
	"scrotum",
	"second",
	"semen",
	"server",
	"seven",
	"seventh",
	"sex",
	"sherlock",
	"shit",
	"shitter",
	"shitty",
	"short",
	"shorty",
	"shrek",
	"sith",
	"sixth",
	"size",
	"skibidi",
	"slave",
	"slut",
	"smegma",
	"snape",
	"snowden",
	"soprano",
	"soviet",
	"spartan",
	"spongebob",
	"squidward",
	"stalin",
	"stallone",
	"stoner",
	"stroker",
	"sydrome",
	"tenth",
	"terrorist",
	"testicles",
	"third",
	"three",
	"tits",
	"titties",
	"toff",
	"tosser",
	"trummp",
	"trump",
	"turd",
	"twat",
	"tyrone",
	"ugly",
	"uncle",
	"vader",
	"vagina",
	"vape",
	"vortigaunt",
	"wank",
	"wanker",
	"weed",
	"weiner",
	"whore",
	"wick",
	"willie",
	"willy",
	"wonka",
	"wtf",
}

--- Verifies a name string using advanced rules.
-- @param name string The full name to validate.
-- @return boolean True if valid, false otherwise.
-- @return string? Reason for failure (if invalid).
function GM:IsValidName(name)
	-- Make sure input is a string
	if ( type(name) != "string" ) then
		return false, "Invalid input type."
	end

	-- Trim whitespace
	name = string.Trim(name)

	if ( #name < 3 ) then
		return false, "Name is too short."
	end

	-- Reject disallowed characters
	if ( name:find("[^A-Za-z%s']") ) then
		return false, "Name contains invalid characters. Only English letters and single quotes are allowed."
	end

	-- Reject multiple spaces (e.g., "John    Pork")
	if ( name:find("%s%s+") ) then
		return false, "Name contains excessive spacing."
	end

	-- Count parts (words)
	local parts = {}
	for word in name:gmatch("%S+") do
		parts[#parts + 1] = word
	end

	if ( #parts < 2 ) then
		return false, "Name must include at least a first and last name."
	elseif ( #parts > 3 ) then
		return false, "Name can only contain a first, optional middle, and last name."
	end

	-- If 3 parts, ensure middle is in single quotes (e.g., 'Mint')
	if ( #parts == 3 ) then
		local middle = parts[2]
		if ( !middle:match("^'%a+'$") ) then
			return false, "Middle name must be in single quotes and contain only letters."
		end
	end

	-- Final shape validation
	if ( !name:match("^[A-Za-z]+%s[A-Za-z]+$") and
		!name:match("^[A-Za-z]+%s'%a+'%s[A-Za-z]+$") ) then
		return false, "Name format is invalid."
	end

	-- Check against blacklisted names
	for _, blacklistedName in ipairs(blacklisted) do
		if ( string.find(string.lower(name), string.lower(blacklistedName)) ) then
			return false, "This name is blacklisted."
		end
	end

	return true
end

function GM:IsEmpty(vector, ignore)
	ignore = ignore or {}

	local point = util.PointContents(vector)
	local a = point != CONTENTS_SOLID
		and point != CONTENTS_MOVEABLE
		and point != CONTENTS_LADDER
		and point != CONTENTS_PLAYERCLIP
		and point != CONTENTS_MONSTERCLIP

	local b = true

	for k,v in pairs(ents.FindInSphere(vector, 35)) do
		if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics") and not table.HasValue(ignore, v) then
			b = false
			break
		end
	end

	return a and b
end

function GM:FindEmptyPos(pos, ignore, distance, step, area)
	if GAMEMODE:IsEmpty(pos, ignore) and GAMEMODE:IsEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if GAMEMODE:IsEmpty(pos + Vector(k, 0, 0), ignore) and GAMEMODE:IsEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			-- Look East/West
			if GAMEMODE:IsEmpty(pos + Vector(0, k, 0), ignore) and GAMEMODE:IsEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			-- Look Up/Down
			if GAMEMODE:IsEmpty(pos + Vector(0, 0, k), ignore) and GAMEMODE:IsEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end