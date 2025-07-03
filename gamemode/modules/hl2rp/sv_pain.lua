local deathSounds = {
	Sound("npc/metropolice/die1.wav"),
	Sound("npc/metropolice/die2.wav"),
	Sound("npc/metropolice/die3.wav")
}

local fireSounds = {
	Sound("npc/metropolice/fire_scream1.wav"),
	Sound("npc/metropolice/fire_scream2.wav"),
	Sound("npc/metropolice/fire_scream3.wav")
}

local hurtSounds = {
	Sound("npc/metropolice/pain1.wav"),
	Sound("npc/metropolice/pain2.wav"),
	Sound("npc/metropolice/pain3.wav")
}

local vorthurtSounds = {
	Sound("vo/npc/vortigaunt/vortigese07.wav"),
	Sound("vo/npc/vortigaunt/vortigese04.wav"),
	Sound("vo/npc/vortigaunt/vortigese03.wav")
}

local citizenpainSounds = {
	Sound("vo/npc/male01/pain01.wav"),
	Sound("vo/npc/male01/pain02.wav"),
	Sound("vo/npc/male01/pain03.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/male01/pain05.wav"),
	Sound("vo/npc/male01/pain06.wav"),
	Sound("vo/npc/male01/pain07.wav"),
	Sound("vo/npc/male01/pain08.wav"),
	Sound("vo/npc/male01/pain09.wav")
}

hook.Add("DoPlayerDeath", "apex.death", function(client, attacker, dmginfo)
	client:SetDarkRPVar("rank", 0)
	client:SetDarkRPVar("division", 0)
end)

hook.Add("DoPlayerDeath", "apex.death.sound", function(client, attacker, dmginfo)
	if ( client:IsCombine() ) then
		local deathSound = hook.Run("GetPlayerDeathSound", client) or deathSounds[math.random(#deathSounds)]
		if ( dmginfo:IsDamageType(DMG_BURN) ) then
			deathSound = hook.Run("GetPlayerDeathFireSound", client) or fireSounds[math.random(#fireSounds)]
		end

		client:EmitSound(deathSound)
	end
end)

hook.Add("PlayerHurt", "apex.hurt.sound", function(client, attacker, health, damage)
	if ( client:IsCombine() and damage > 3 ) then
		local hurtSound = hook.Run("GetPlayerPainSound", client) or hurtSounds[math.random(#hurtSounds)]
		client:EmitSound(hurtSound)
	end

	if ( client:Team() == TEAM_VORT and damage > 3 ) then
		local hurtvortSound = hook.Run("GetPlayerPainSound", client) or vorthurtSounds[math.random(#vorthurtSounds)]
		client:EmitSound(hurtvortSound)
	else
		if ( damage > 3 ) then
			local painSound = hook.Run("GetPlayerCitizenPainSound", client) or citizenpainSounds[math.random(#citizenpainSounds)]
			client:EmitSound(painSound)
		end
	end
end)