

function GM:KeyPress(client, key)
	if (key == IN_RELOAD) then
		timer.Create("hl2rpToggleRaise"..client:SteamID64(), 1, 1, function()
			if (IsValid(client)) then
				client:toggleWepRaised()
			end
		end)
	end

end

function GM:KeyRelease(client, key)
	if (key == IN_RELOAD) then
		timer.Remove("hl2rpToggleRaise"..client:SteamID64())
	end
end

function GM:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
	client:setWepRaised(false)
end