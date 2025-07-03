function RappelFinish(e,playercolor,movetype,weaponcolor,overridepos)

	local oldwepcolor = weaponcolor

	local oldcolor = playercolor

	if IsValid(e.Rappel) then

		e:EmitSound("npc/combine_soldier/zipline_hitground"..math.random(1,2)..".wav")


			if IsValid(e.Rappel) then

				local client = e.Rappel
                               client.IsRappeling = nil
				e:EmitSound("npc/combine_soldier/zipline_clip2.wav")

				if IsValid(client.RappelEnt) then
			--	client:UnSpectate()
                                 if overridepos then
					client:SetPos(overridepos)
else
					client:SetPos(client.RappelEnt:GetPos())
end
					client:SetEyeAngles(Angle(0,client.RappelEnt:GetAngles().yaw,0))

					e:Remove()

				end

				client:SetMoveType(movetype)

				if (client:GetMoveType()!=MOVETYPE_WALK) then

					client:SetMoveType(MOVETYPE_WALK)

				end

				-- Doing observer makes clockwork observer fuck up D;

				client:SetWeaponColor(oldwepcolor)
 

				--Clockwork.player:ToggleWeaponRaised(client);

				client:SetNoDraw(false)
    client:SetNWEntity("sh_Eyes",nil)

                                client:SetNotSolid(false)


				--client:UnSpectate()
    client:GodDisable()

 				client:Freeze(false)
                             

				client:SetColor(oldcolor)


			else

				e:Remove()

			end

	end

end





function PlayerRappel(client)

	local playerwepcolor = client:GetWeaponColor()

	local playercolor = client:GetColor()

	local movetype = client:GetMoveType()

	local po = client:GetPos() + (client:GetForward() * 30)

	local t = {}

	t.start = po

	t.endpos = po - Vector(0,0,1000)

	t.filter = {client}

	local tr = util.TraceLine(t)

	if tr.HitPos.z <= client:GetPos().z then
if tr.HitPos:Distance(client:GetPos()) < 200 then return end
--if tr.HitPos.y > client:GetPos().y + 10 or tr.HitPos.y < client:GetPos().y - 10 then return end
--if tr.HitPos.x > client:GetPos().x + 10 or tr.HitPos.x < client:GetPos().x - 10 then return end
client.StartPos=client:GetPos()
		local e = ents.Create("npc_metropolice")

		e:SetKeyValue("waitingtorappel",1)

		e:SetPos(po)

		e:SetAngles(Angle(0,client:EyeAngles().yaw,0))

		e:Spawn()

		e:CapabilitiesClear()

		e:CapabilitiesAdd( CAP_MOVE_GROUND  )

 		--timer.Simple(10, function() RappelFinish(e,playercolor,movetype) end)
timer.Simple(16, function() 
if e and IsValid(e) then
e:Remove()

if IsValid(client) then

				client:SetMoveType(movetype)

				if (client:GetMoveType()!=MOVETYPE_WALK) then

					client:SetMoveType(MOVETYPE_WALK)

				end
client:ChatPrint("You got stuck, fixing....")
				-- Doing observer makes clockwork observer fuck up D;

				client:SetWeaponColor(Vector(1,1,1))
 

				--Clockwork.player:ToggleWeaponRaised(client);

				client:SetNoDraw(false)
    client:SetNWEntity("sh_Eyes",nil)
    client:SetNotSolid(false)


				--client:UnSpectate()
    client:GodDisable()

 			client:Freeze(false)
                             

				client:SetColor(Color(255,255,255,255))
    client.IsRappeling = nil


end

end
end)

		timer.Create( "rappelchecker", 0.5, 0, function()
if IsValid(e) then

			if e:IsOnGround() then
    if loopsnd then
    loopsnd:Stop()
    end
				RappelFinish(e,playercolor,movetype,playerwepcolor)

				timer.Destroy("rappelchecker")
    
    else
    local loopsnd = CreateSound(e,"npc/combine_soldier/zipline2.wav")
    loopsnd:Play()
    
    if e.LastPos and e.LastPos==e:GetPos() then 
    RappelFinish(e,playercolor,movetype,playerwepcolor,client.StartPos)
    timer.Destroy("rappelchecker")
    end
    

			end
e.LastPos = e:GetPos()
end
		end)

		e.Rappel = client

  e:EmitSound("npc/combine_soldier/zipline_clip1.wav")
		local loopsnd = CreateSound(e,"npc/combine_soldier/zipline2.wav")
  loopsnd:Play()

		e:SetModel(client:GetModel())

		local plyweapon = client:GetActiveWeapon():GetClass()

		if plyweapon == "cw_hands" then

			local plyweapon = "weapon_stunstick"

		end

		if plyweapon == "cw_keys" then

			local plyweapon = "weapon_stunstick"

		end

	--	e:Give(plyweapon)

		e:SetName("npc_gman")

		e.Gods = true

		e.God = true

		client:SetMoveType(MOVETYPE_FLY)
client.IsRappeling = true

		client:Freeze(true)
  client:SetNoDraw(true)

		client:SetNWEntity("sh_Eyes",e)

		--client:SetViewEntity(e)

		--client:Spectate( OBS_MODE_CHASE )

		--client:SpectateEntity( e )


		--Clockwork.player:ToggleWeaponRaised(client);

		e:Fire("beginrappel")

		e:Fire("addoutput","OnRappelTouchdown rappelent,RunCode,0,-1", 0 )

		client.RappelEnt = e

	end

end



hook.Add("EntityTakeDamage","RAPPEL-DMG",function(ent)
if ent:IsNPC() and ent.God then
return true
end


end)


