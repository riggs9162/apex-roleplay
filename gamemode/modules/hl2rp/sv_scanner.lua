local antiSpam = {}

scannerSounds = {
	"npc/scanner/scanner_scan1.wav",
	"npc/scanner/scanner_scan2.wav",
	"npc/scanner/scanner_scan4.wav",
	"npc/scanner/scanner_scan5.wav"
}

angryScannerSounds = {
	"npc/scanner/cbot_servoscared.wav",
	"npc/scanner/scanner_siren1.wav",
	"npc/scanner/scanner_alert1.wav"
}


function MakeScanner(client)

	if not ScnWep then

		ScnWep = {}

	end

	if not ScnAmmo then

		ScnAmmo = {}

	end



		if IsValid(client:GetDarkRPVar("Scanner")) and IsEntity(client:GetDarkRPVar("Scanner")) then

			client:GetDarkRPVar("Scanner"):Remove()

			return

		end

		local client = client

		class =  "npc_cscanner"





		if not client:IsCombine() then

			client:Notify("You must be a Civil Protection GRID Unit to deploy a scanner!")

			return

		end



		if not (client.DarkRPVars.Division and client.DarkRPVars.Division == 3) then

			client:Notify("You must be a GRID Unit to deploy a scanner!")

			return

		end



		local waittime = 60*10

		if CurTime() - (antiSpam[client:UniqueID()] or 0) < waittime and not client:IsAdmin() then

			local waittimes = math.ceil(waittime- (CurTime() - (antiSpam[client:UniqueID()] or 0)))

			client:Notify("You must wait "..waittimes.." second('s) before using /scanner again!")

			return

		end

			antiSpam[client:UniqueID()] = CurTime();



		local entity = ents.Create(class)



		if (!IsValid(entity)) then

			return

		end



		entity:SetPos(client:GetPos() + Vector(0, 0, 110))

		entity:SetAngles(client:GetAngles())

		entity:SetColor(client:GetColor())

		entity:Spawn()

		entity:Activate()

		entity.player = client

		entity:SetNWEntity("player", client) -- Draw the player info when looking at the scanner.

		entity:CallOnRemove("nutRestore", function()

			if (IsValid(client)) then

				local position = entity.spawn or client:GetPos()

				hook.Run("UpdatePlayerSpeed", client)

				client:UnSpectate()

				client:SetViewEntity(NULL)

				client:Freeze( false )

				if (entity:Health() > 0) then

				--	client:Spawn()

				--else

				--	client:KillSilent()

				end



				timer.Simple(0, function()

				if client:IsCombine() then

					for k,v in pairs(ScnWep[client]) do

			--			print(v)

						client:Give(tostring(v), true)

					end

					for k,v in pairs(ScnAmmo[client]) do

			--			print(v)

						client:SetAmmo(v["amount"], v["id"])

						client:SetAmmo(v["amount2"], v["id2"])

					end
				end
				end)

			end

		end)



		local name = "nutScn"..os.clock()

		entity.name = name



		local target = ents.Create("path_track")

		target:SetPos(entity:GetPos())

		target:Spawn()

		target:SetName(name)



		entity:Fire("setfollowtarget", name)

		entity:Fire("inputshouldinspect", false)

		entity:Fire("setdistanceoverride", "48")

		entity:SetKeyValue("spawnflags", 8208)







		client.nutScn = entity

		ScnWep[client] = {}

		ScnAmmo[client] = {}

		for k,v in pairs(client:GetWeapons()) do

			table.insert( ScnWep[client] , v:GetClass() )

		end



		for k,v in pairs(client:GetWeapons()) do

			local ammoName = v:GetPrimaryAmmoType()

			local ammoAmount = client:GetAmmoCount(v:GetPrimaryAmmoType())

			local ammoName2 = v:GetSecondaryAmmoType()

			local ammoAmount2 = client:GetAmmoCount(v:GetSecondaryAmmoType())

			addammo = {

				id = ammoName,

				amount = ammoAmount,

				id2 = ammoName2,

				amount2 = ammoAmount2

			}

			table.insert( ScnAmmo[client] , addammo)

		end





		--PrintTable(client:GetWeapons())

		client:StripWeapons()

	--	client:Freeze( true )

		client:SetRunSpeed(1)

		client:SetWalkSpeed(1)

	--	client:Spectate(OBS_MODE_CHASE)

	--	client:SpectateEntity(entity)

		client:SetViewEntity(entity)

		client:SetDarkRPVar("Scanner", entity)

		local uniqueID = "nut_Scanner"..client:UniqueID()



		timer.Create(uniqueID, 0.33, 0, function()

			if (!IsValid(client) or !IsValid(entity)) then

				if (IsValid(entity)) then

					entity:Remove()

				end



				return timer.Remove(uniqueID)

			end



			local factor = 128



			if (client:KeyDown(IN_SPEED)) then

				factor = 64

			end



			if (client:KeyDown(IN_FORWARD)) then

				target:SetPos((entity:GetPos() + client:GetAimVector()*factor) - Vector(0, 0, 64))

				entity:Fire("setfollowtarget", name)

			elseif (client:KeyDown(IN_BACK)) then

				target:SetPos((entity:GetPos() + client:GetAimVector()*-factor) - Vector(0, 0, 64))

				entity:Fire("setfollowtarget", name)

			elseif (client:KeyDown(IN_JUMP)) then

				target:SetPos(entity:GetPos() + Vector(0, 0, factor))

				entity:Fire("setfollowtarget", name)

			elseif (client:KeyDown(IN_DUCK)) then

				target:SetPos(entity:GetPos() - Vector(0, 0, factor))

				entity:Fire("setfollowtarget", name)

		--	elseif (client:KeyDown(IN_RELOAD)) then

		--		entity:Remove()

		--		timer.Remove(uniqueID)

			end



			--client:SetPos(entity:GetPos())

		end)



	--	return entity

	end



apex.commands.Register("/scanner", MakeScanner)

concommand.Add( "MakeScanner", function( client )

--MakeScanner(client, "npc_cscanner")

end)



concommand.Add( "apex_remove_scanners", function( client )

	if ( !client:IsSuperAdmin() ) then return end

	for k, v in pairs( ents.FindByClass( "npc_cscanner" ) ) do v:Remove() end

end )









util.AddNetworkString("nutScannerData")
util.AddNetworkString("apexScannerEmote")
util.AddNetworkString("apexScannerAngry")

net.Receive("apexScannerAngry", function(length, client)
			local scanangry = net.ReadBool()
			local scanner = net.ReadEntity()
			
			if scanangry == true then
				client:GetViewEntity():EmitSound( angryScannerSounds[ math.random( #angryScannerSounds) ],140 )
				scanner:EmitSound( angryScannerSounds[ math.random( #angryScannerSounds) ],140 )
				scanangry = false
			end
end)

net.Receive("apexScannerEmote", function(length, client)
			local scanemote = net.ReadBool()
			local scanner = net.ReadEntity()
			
			if scanemote == true then
				client:GetViewEntity():EmitSound( scannerSounds[ math.random( #scannerSounds) ], 140 )
				scanner:EmitSound( scannerSounds[ math.random( #scannerSounds) ], 140 )
				scanemote = false
			end
end)


net.Receive("nutScannerData", function(length, client)

		if (IsValid(client.nutScn) and client:GetViewEntity() == client.nutScn and (client.nutNextPic or 0) < CurTime()) then

			client.nutNextPic = CurTime() + (4 - 1)

			client:GetViewEntity():EmitSound("npc/scanner/scanner_photo1.wav", 140)

			client:EmitSound("npc/scanner/combat_scan5.wav")



			local length = net.ReadUInt(16)

			local data = net.ReadData(length)

			local scanner = net.ReadEntity()

			scanner:EmitSound("npc/scanner/scanner_photo1.wav", 140)



			if (length != #data) then

				return

			end



			local receivers = {}



			for k, v in player.Iterator() do

				if v:IsCombine() then

					receivers[#receivers + 1] = v

					v:EmitSound("npc/overwatch/radiovoice/preparevisualdownload.wav", 20)

					v:Notify("Prepare to receive visual download...")

				end

			end



			if (#receivers > 0) then

				net.Start("nutScannerData")

					net.WriteUInt(#data, 16)

					net.WriteData(data, #data)

				net.Send(receivers)









			end

		end

end)



apex.commands.Register("/photocache",function(client)

if client:IsCombine() then

client:ConCommand("nut_photocache")

end

end)



local ScnGib = {

["models/gibs/scanner_gib01.mdl"] = true,

["models/gibs/scanner_gib02.mdl"] = true,

["models/gibs/scanner_gib03.mdl"] = true,

["models/gibs/scanner_gib04.mdl"] = true,

["models/gibs/scanner_gib05.mdl"] = true

}



timer.Create("CLEANUPG",60,0,function()

for v,k in pairs(ents.GetAll()) do

if ScnGib[k:GetModel()] then

k:Remove()

end



end





end)