apex = apex or {}
apex.cp = apex.cp or {}
apex.cp.ranks = {}
apex.cp.divisions = {}

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Civil Protection NPC"
ENT.Category = "Apex Roleplay"
ENT.Author = "Riggs, Datamats, JamesAMG, TheVingard"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true

function apex.cp.RegisterRank(data)
	if ( !data or !data.name or !data.abbreviation or !data.description ) then
		ErrorNoHaltWithStack("Invalid rank data provided to apex.cp.RegisterRank!\n")
		return
	end

	data.abbreviation = data.abbreviation or "NULL" -- Ensure abbreviation is provided, default to "NULL"
	data.weapons = data.weapons or {} -- Default to an empty table if no weapons are provided
	data.xp = data.xp or 0 -- Default XP to 0 if not provided

	local rank = table.Copy(data)
	rank.id = table.Count(apex.cp.ranks) + 1 -- Assign a new ID based on the current count of ranks
	apex.cp.ranks[rank.id] = rank

	return rank.id
end

function apex.cp.RegisterDivision(data)
	if ( !data or !data.name or !data.abbreviation or !data.model or !data.description ) then
		ErrorNoHaltWithStack("Invalid division data provided to apex.cp.RegisterDivision!\n")
		return
	end

	data.abbreviation = data.abbreviation or "NULL" -- Ensure abbreviation is provided, default to "NULL"
	data.weapons = data.weapons or {} -- Default to an empty table if no weapons are provided
	data.xp = data.xp or 0 -- Default XP to 0 if not provided

	local division = table.Copy(data)
	division.id = table.Count(apex.cp.divisions) + 1 -- Assign a new ID based on the current count of divisions
	apex.cp.divisions[division.id] = division

	return division.id
end

RANK_RCT = apex.cp.RegisterRank({
	name = "Recruit",
	abbreviation = "RCT",
	description = "Recruits are little more than citizens in a uniform. Most recruits are in the process of receiving basic training and are kept within the bounds of the Nexus at all times, unless partnered with another unit.",
	xp = 35,
	roguePerms = true
})

RANK_05 = apex.cp.RegisterRank({
	name = "Ground Unit 05",
	abbreviation = "05",
	description = "05's are the first official rank a Civil Protection unit receives. They have undergone some basic training but still have very little knowledge of Civil Protection procedure. 05's are often partnered with other units, from other divisions.",
	xp = 75,
	roguePerms = true
})

RANK_04 = apex.cp.RegisterRank({
	name = "Ground Unit 04",
	abbreviation = "04",
	description = "04's are the last trainee ranks of the Civil Protection. They have almost completed basic training, and have a good knowledge of Civil Protection procedure.",
	xp = 100,
	roguePerms = true
})

RANK_03 = apex.cp.RegisterRank({
	name = "Ground Unit 03",
	abbreviation = "03",
	description = "03's have completed Civil Protection basic training, and are ready to begin their official duties. They are the first of the frontline Civil Protection forces and work with other Ground Units to perform their duties. They and all higher units are fitted with biosignals.",
	xp = 200,
	roguePerms = true
})

RANK_02 = apex.cp.RegisterRank({
	name = "Ground Unit 02",
	abbreviation = "02",
	description = "02's have been promoted from 03 after proving their competence and loyalty to their superiors. 02's are frequently given training in advanced techniques, such as breaching.",
	xp = 300
})

RANK_01 = apex.cp.RegisterRank({
	name = "Ground Unit 01",
	abbreviation = "01",
	description = "01's are Ground Units that have proven themselves completely loyal to the Combine, and have undergone some basic memory replacement, removing negative thoughts about the Combine. Many of them are promoted in order to prepare them for a command position, and frequently undergo leadership training.",
	xp = 400
})

RANK_OFC = apex.cp.RegisterRank({
	name = "Officer",
	abbreviation = "OfC",
	description = "OfC's are Civil Protection units that have been chosen to join the high command of the Civil Protection. They have undergone leadership training and are often tasked with commanding small squads of Civil Protection officers, and training recruits and other low ranked units. They have undergone significant memory modification, removing almost all negative thoughts about the Combine.",
	xp = 500
})

RANK_EPU = apex.cp.RegisterRank({
	name = "Elite Protection Unit",
	abbreviation = "EpU",
	description = "EpU's are Elite Protection Units. They have been promoted as a reward for their exceptional service to the Combine, and their loyalty to the Civil Protection is unquestionable. EpU's are frequently given more powerful weaponry and often lead squads of other Civil Protection units. They also are tasked with giving basic training to recruits.",
	max = 2,
	xp = 600,
})

RANK_DVL = apex.cp.RegisterRank({
	name = "Division Leader",
	abbreviation = "DvL",
	description = "The DvL is an exceptional unit, chosen to become the leader of a particular division. They are responsible for the activities of all units assigned to their division. Often, they will select an EpU to act as their second in command and will frequently organise training sessions for their own division.",
	max = 1,
	xp = 800
})

DIVISION_UNION = apex.cp.RegisterDivision({
	name = "Specialist Patrol Unit",
	abbreviation = "UNION",
	model = "models/dpfilms/metropolice/hdpolice.mdl",
	weapons = {
		[RANK_RCT] = {"stunstick", "door_ram"},
		[RANK_05] = {"ironsight_pistol", "weapon_r_handcuffs"},
		[RANK_03] = {"weapon_smg1"}
	},
	description = "The UNION division is the most common within the Civil Protection. Their job is to patrol the city and man checkpoints. They will often carry out searches of the apartment complex and other buildings. They are the frontline of the Civil Protection, and all other divisions are designedto support them.",
	xp = 35,
	roguePerms = true
})

DIVISION_HELIX = apex.cp.RegisterDivision({
	name = "Specialist Medical Unit",
	abbreviation = "HELIX",
	model = "models/dpfilms/metropolice/civil_medic.mdl",
	weapons = {
		[RANK_RCT] = {"stunstick"},
		[RANK_05] = {"ironsight_pistol", "weapon_r_handcuffs", "weapon_medkit"},
		[RANK_03] = {"door_ram"}
	},
	description = "The HELIX division is made up of medically trained units and are responsible for the general health of the city and the Civil Protection. HELIX's often use CWU medics as assistants and frequently set up health centres to treat the injured and unwell. HELIX units are able to provide additional medical supplies to those that require them, in exchange for tokens. Individual HELIX units often join up with other Civil Protection divisions and squads in order to function as a field medic.",
	max = 6,
	xp = 60
})

DIVISION_GRID = apex.cp.RegisterDivision({
	name = "Specialist Engineering Unit",
	abbreviation = "GRID",
	model = "models/dpfilms/metropolice/hl2concept.mdl",
	weapons = {
		[RANK_RCT] = {"stunstick"},
		[RANK_05] = {"ironsight_pistol", "weapon_r_handcuffs"},
		[RANK_03] = {"ironsight_smg3", "breachingcharge", "door_ram"}
	},
	description = "The GRID division are mechanics, responsible for the maintenance of the Combine's technology, vehicles and weaponry. GRID units also operate scanner drones, which patrol throughout the city and are often used for reconnaissance. OCPsionally GRID units will carry out vehicular patrols in APCs. The main role of GRID units is to provide mechanical and technological support of other divisions.",
	max = 4,
	xp = 100
})

DIVISION_JURY = apex.cp.RegisterDivision({
	name = "Interrogation and Torture Unit",
	abbreviation = "JURY",
	model = "models/dpfilms/metropolice/policetrench.mdl",
	weapons = {
		[RANK_RCT] = {"stunstick"},
		[RANK_05] = {"ironsight_pistol", "weapon_r_handcuffs"},
		[RANK_03] = {"door_ram"},
		[RANK_01] = {"sight_shotgun"}
	},
	description = "The JURY division manages the Nexus prison, and is trained to interrogate captives. Their uniforms are often covered in the blood and viscera of their victims and not even their Civil Protection comrades are entirely comfortable being around them. Every officer is familiar with the screams that come from the interrogation rooms, and the cold, brutal efficiency the JURY's operate with. One shudders to imagine what inhuman thoughts lurk behind that mask…",
	max = 3,
	xp = 200
})

DIVISION_SPEAR = apex.cp.RegisterDivision({
	name = "Recon Unit",
	abbreviation = "SPEAR",
	model = "models/dpfilms/metropolice/elite_police.mdl",
	weapons = {
		[RANK_RCT] = {"weapon_r_handcuffs", "sight_shotgun", "door_ram"}
	},
	description = "The SPEAR division is an elite division, tasked with patrolling 404 zones in small squads and locating rogue units. Members of SPEAR are highly trained and hardened by the harsh conditions in the 404 zones they patrol and as such are almost entirely fearless, and highly loyal.",
	max = 2,
	xp = 1500
})

DIVISION_CMD = apex.cp.RegisterDivision({
	name = "Commander",
	abbreviation = "CmD",
	model = "models/dpfilms/metropolice/police_bt.mdl",
	weapons = {"stunstick", "ironsight_pistol", "weapon_smg1", "weapon_r_handcuffs", "door_ram"},
	description = "The CmD or Commander is the field commander of the Civil Protection forces. He is responsible for ensuring the SeC's instructions are respected and obeyed within the Civil Protection. When there is no SeC available, he is considered leader of the Civil Protection. The CmD is the field commander of the Civil Protection, and often leads raiding parties of Civil Protection. The CmD also acts as the Division Leader of SPEAR, and is responsible for organising patrols of 404 zones.",
	max = 1,
	xp = 1500,
	noRank = true
})

DIVISION_SEC = apex.cp.RegisterDivision({
	name = "Sectorial Commander",
	abbreviation = "SeC",
	model = "models/dpfilms/metropolice/phoenix_police.mdl",
	weapons = {"sight_usp2", "weapon_r_handcuffs"},
	description = "The Sectorial Commander is the commanding officer of a sectors Civil Protection force. The SeC is considered too important to risk on the frontline, and as such spends most of the time inside the Nexus. The SeC has the final say on anything Civil Protection related and has undergone extensive memory replacement and enhancement. He is harder, smarter, faster and stronger than any other Civil Protection unit and is a fearsome individual, second only to the City Administrator.",
	max = 1,
	xp = 2200,
	noRank = true
})