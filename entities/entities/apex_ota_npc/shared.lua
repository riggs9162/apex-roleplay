apex = apex or {}
apex.overwatch = apex.overwatch or {}
apex.overwatch.ranks = {}
apex.overwatch.divisions = {}

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Overwatch NPC"
ENT.Category = "Apex Roleplay"
ENT.Author = "Riggs, Datamats, JamesAMG, TheVingard"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true

function apex.overwatch.RegisterRank(data)
	if ( !data or !data.name or !data.abbreviation or !data.description ) then
		ErrorNoHaltWithStack("Invalid rank data provided to apex.overwatch.RegisterRank!\n")
		return
	end

	data.abbreviation = data.abbreviation or "NULL" -- Ensure abbreviation is provided, default to "NULL"
	data.weapons = data.weapons or {} -- Default to an empty table if no weapons are provided
	data.xp = data.xp or 0 -- Default XP to 0 if not provided

	local rank = table.Copy(data)
	rank.id = table.Count(apex.overwatch.ranks) + 1 -- Assign a new ID based on the current count of ranks
	apex.overwatch.ranks[rank.id] = rank

	return rank.id
end

function apex.overwatch.RegisterDivision(data)
	if ( !data or !data.name or !data.abbreviation or !data.model or !data.description ) then
		ErrorNoHaltWithStack("Invalid division data provided to apex.overwatch.RegisterDivision!\n")
		return
	end

	data.abbreviation = data.abbreviation or "NULL" -- Ensure abbreviation is provided, default to "NULL"
	data.weapons = data.weapons or {} -- Default to an empty table if no weapons are provided
	data.xp = data.xp or 0 -- Default XP to 0 if not provided

	local division = table.Copy(data)
	division.id = table.Count(apex.overwatch.divisions) + 1 -- Assign a new ID based on the current count of divisions
	apex.overwatch.divisions[division.id] = division

	return division.id
end

RANK_OWS = apex.overwatch.RegisterRank({
	name = "Overwatch Soldier",
	abbreviation = "OWS",
	description = "Overwatch Soldiers comprise most of the Overwatch Transhuman Arm forces. They have been extensively modified with technology and organs from other Combine races and are completely without empathy or emotions of any kind. They were once human. Prisoners and volunteers from, the ranks of the Civil Protection, but they are far from human now. They have become something new.",
	xp = 600
})

RANK_EOW = apex.overwatch.RegisterRank({
	name = "Overwatch Elite Soldier",
	abbreviation = "EOW",
	description = "Overwatch Elite are the best of the best. They have undergone further modification and are human in name only, with very few original components remaining. A single EOW is easily capable of killing dozens of lesser beings and they are rightly feared by foe and ally alike. The Elite of the Overwatch Transhuman Arm are death incarnate.",
	xp = 1000
})

DIVISION_ECHO = apex.overwatch.RegisterDivision({
	name = "Ground Soldier",
	abbreviation = "ECHO",
	model = "models/Combine_Soldier.mdl",
	weapons = {
		[RANK_OWS] = {"weapon_r_handcuffs", "weapon_smg1"},
		[RANK_EOW] = {"weapon_r_handcuffs", "weapon_ar2", "weapon_frag"}
	},
	description = "ECHO are the footsoldiers of the Overwatch Transhuman Arm. They make up the bulk of the Combine's military forces, and often function in small squads of two or three units, led by an Elite unit. Mostly, ECHO’s will Patrol the Combine Highways as well as defending hardpoints and the Nexus.",
	xp = 600
})

DIVISION_RANGER = apex.overwatch.RegisterDivision({
	name = "Tactical Sniper",
	abbreviation = "RANGER",
	model = "models/Combine_Soldier.mdl",
	weapons = {
		[RANK_OWS] = {"ironsight_pistol", "weapon_r_handcuffs", "grub_combine_sniper"},
		[RANK_EOW] = {"ironsight_pistol", "weapon_r_handcuffs", "grub_combine_sniper", "weapon_frag"}
	},
	description = "RANGER division are Overwatch Transhuman Arm trained in the use of sniper rifles and intended to engage the enemy at long range. They will almost never accompany a squad and will mostly remain somewhere high, and with good lines of site. They are often used to safely eliminate high profile targets and scout areas for other Overwatch Transhuman Arm.",
	max = 2,
	xp = 800
})

DIVISION_MACE = apex.overwatch.RegisterDivision({
	name = "Shotgunner Soldier",
	abbreviation = "MACE",
	model = "models/Combine_Soldier.mdl",
	skin = 1,
	weapons = {
		[RANK_OWS] = {"sight_shotgun", "weapon_r_handcuffs", "breachingcharge"},
		[RANK_EOW] = {"sight_shotgun", "weapon_r_handcuffs", "breachingcharge", "weapon_frag"}
	},
	description = "MACE division are Overwatch Transhuman Arm trained and augmented to perform in extreme close quarters. They are specialist units, and often only one will accompany a squad. MACE are trained to use aggressive tactics, and are equipped to breach apartment buildings and move in fast. They may patrol with Overwatch Transhuman Arm squads but mainly will remain in the Nexus unless taking part in a raid or assigned to a squad.",
	max = 8,
	xp = 800
})

DIVISION_KING = apex.overwatch.RegisterDivision({
	name = "Elite Ground Soldier",
	abbreviation = "KING",
	model = "models/Combine_Super_Soldier.mdl",
	weapons = {
		[RANK_OWS] = {"weapon_r_handcuffs", "sight_xr4"},
		[RANK_EOW] = {"weapon_r_handcuffs", "sight_xr4", "weapon_frag"}
	},
	description = "KING are elite Overwatch Transhuman Arm, moved from other divisions because of their exemplary performance. KING are intimidating figures, feared even by their comrades in the Civil Protection. They are cold, calculating and brutally efficient. KING are often assigned to lead squads of Overwatch Transhuman Arm or command a Hardpoint on behalf of the OWC.",
	max = 6,
	xp = 1000
})

DIVISION_XRAY = apex.overwatch.RegisterDivision({
	name = "Heavy Medical Soldier",
	abbreviation = "XRAY",
	model = "models/Combine_Soldier.mdl",
	weapons = {
		[RANK_OWS] = {"weapon_medkit", "weapon_r_handcuffs", "weapon_smg1"},
		[RANK_EOW] = {"weapon_medkit", "weapon_r_handcuffs", "weapon_frag"}
	},
	description = "XRAY are Overwatch Transhuman Arm field medics, trained in treating transhuman soldiers for wounds likely to be sustained on the battlefield. They will often accompany an Overwatch Transhuman Arm squad, functioning as a field medic. Like all Overwatch Transhuman Arm, they are completely without empathy, caring only to get their patients in fighting condition as fast as possible.",
	max = 2,
	xp = 1200
})

DIVISION_SENTINEL = apex.overwatch.RegisterDivision({
	name = "Administrator's Bodyguard",
	abbreviation = "SENTINEL",
	model = "models/Combine_Super_Soldier.mdl",
	weapons = {
		[RANK_OWS] = {"stunstick", "weapon_r_handcuffs", "weapon_ar2"},
		[RANK_EOW] = {"stunstick", "weapon_r_handcuffs", "weapon_ar2", "weapon_frag"}
	},
	description = "SENTINEL units are the elite personal bodyguards of the City Administrator. They answer only to the him, serving his every need. Whilst they do not care personally for the Administrator, his safety is the only thing that concerns them. They are always found close to the CA, never leaving his side.",
	max = 4,
	xp = 1300
})

DIVISION_NOVA = apex.overwatch.RegisterDivision({
	name = "Prison Guard",
	abbreviation = "NOVA",
	model = "models/combine_soldier_prisonguard.mdl",
	weapons = {
		[RANK_OWS] = {"stunstick", "weapon_r_handcuffs", "weapon_ar2"},
		[RANK_EOW] = {"stunstick", "weapon_r_handcuffs", "weapon_ar2", "weapon_frag"}
	},
	description = "NOVA is charged with guarding, manning and maintaining prisons of Combine facilities. In the detention, they are in charge. And when someone escapes, they are at fault. They are not allowed to leave the nexus even with JW/AJ.",
	max = 4,
	xp = 1300
})

DIVISION_OWC = apex.overwatch.RegisterDivision({
	name = "Overwatch Commander",
	abbreviation = "OWC",
	model = "models/dpfilms/metropolice/rtb_police.mdl",
	weapons = {"ironsight_357", "weapon_ar2", "weapon_r_handcuffs", "weapon_frag"},
	description = "The Overwatch Commander is the leader of all Overwatch Transhuman Arm forces. Whilst other Overwatch Transhuman Arm are modified for combat exclusively, the OWC is allowed some free thought, in order to better fulfill their role as the tactical mastermind of the Universal Unions forces. The OWC will organise Overwatch Transhuman Arm units and will almost always lead from the front lines.",
	max = 1,
	xp = 3000
})