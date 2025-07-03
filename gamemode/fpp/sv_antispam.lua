FPP = FPP or {}
FPP.AntiSpam = FPP.AntiSpam or {}

function FPP.AntiSpam.GhostFreeze(ent, phys)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:DrawShadow(false)
	ent.OldColor = ent.OldColor or ent:GetColor()
	ent.StartPos = ent:GetPos()
	ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a - 155))

	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent.CollisionGroup = COLLISION_GROUP_WORLD

	ent.FPPAntiSpamMotionEnabled = phys:IsMoveable()
	phys:EnableMotion(false)

	ent.FPPAntiSpamIsGhosted = true
end

function FPP.UnGhost(client, ent)
	if ent.FPPAntiSpamIsGhosted then
		ent.FPPAntiSpamIsGhosted = nil
		ent:DrawShadow(true)
		if ent.OldCollisionGroup then ent:SetCollisionGroup(ent.OldCollisionGroup) ent.OldCollisionGroup = nil end

		if ent.OldColor then
			ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a))
		end
		ent.OldColor = nil


		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		ent.CollisionGroup = COLLISION_GROUP_NONE

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(ent.FPPAntiSpamMotionEnabled)
		end
	end
end

function FPP.AntiSpam.CreateEntity(client, ent, IsDuplicate)
	if not tobool(FPP.Settings.FPP_ANTISPAM1.toggle) then return end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end

	local class = ent:GetClass()
	-- I power by ten because the volume of a prop can vary between 65 and like a few billion
	if phys:GetVolume() and phys:GetVolume() > math.pow(10, FPP.Settings.FPP_ANTISPAM1.bigpropsize) and not string.find(class, "constraint") and not string.find(class, "hinge")
	and not string.find(class, "magnet") and not string.find(class, "collision") then
		if not IsDuplicate then
			client.FPPAntispamBigProp = (client.FPPAntispamBigProp or 0) + 1
			timer.Simple(10*FPP.Settings.FPP_ANTISPAM1.bigpropwait, function()
				if not client:IsValid() then return end
				client.FPPAntispamBigProp = client.FPPAntispamBigProp or 0
				client.FPPAntispamBigProp = math.Max(client.FPPAntispamBigProp - 1, 0)
			end)
		end

		if client.FPPAntiSpamLastBigProp and client.FPPAntiSpamLastBigProp > (CurTime() - (FPP.Settings.FPP_ANTISPAM1.bigpropwait * client.FPPAntispamBigProp)) then
			FPP.Notify(client, "Please wait " .. FPP.Settings.FPP_ANTISPAM1.bigpropwait * client.FPPAntispamBigProp .. " Seconds before spawning a big prop again", false)
			client.FPPAntiSpamLastBigProp = CurTime()
			ent:Remove()
			return
		end

		if not IsDuplicate then
			client.FPPAntiSpamLastBigProp = CurTime()
		end
		FPP.AntiSpam.GhostFreeze(ent, phys)
		FPP.Notify(client, "Your prop is ghosted because it is too big. Interract with it to unghost it.", true)
		return
	end

	if not IsDuplicate then
		client.FPPAntiSpamCount = (client.FPPAntiSpamCount or 0) + 1
		local time = math.Max(1, FPP.Settings.FPP_ANTISPAM1.smallpropdowngradecount)
		timer.Simple(client.FPPAntiSpamCount / time, function()
			if IsValid(client) then
				client.FPPAntiSpamCount = client.FPPAntiSpamCount - 1
			end
		end)

		if client.FPPAntiSpamCount >= FPP.Settings.FPP_ANTISPAM1.smallpropghostlimit and client.FPPAntiSpamCount <= FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit
			and not ent:IsVehicle()--[[Vehicles don't like being ghosted, they tend to crash the server]] then
			FPP.AntiSpam.GhostFreeze(ent, phys)
			FPP.Notify(client, "Your prop is ghosted for antispam, interract with it to unghost it.", true)
			return
		elseif client.FPPAntiSpamCount > FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit then
			ent:Remove()
			FPP.Notify(client, "Prop removed due to spam", false)
			return
		end
	end
end

function FPP.AntiSpam.DuplicatorSpam(client)
	if not tobool(FPP.Settings.FPP_ANTISPAM1.toggle) then return true end
	client.FPPAntiSpamLastDuplicate = client.FPPAntiSpamLastDuplicate or 0
	client.FPPAntiSpamLastDuplicate = client.FPPAntiSpamLastDuplicate + 1

	timer.Simple(client.FPPAntiSpamLastDuplicate / FPP.Settings.FPP_ANTISPAM1.duplicatorlimit, function() if IsValid(client) then client.FPPAntiSpamLastDuplicate = client.FPPAntiSpamLastDuplicate - 1 end end)

	if client.FPPAntiSpamLastDuplicate >= FPP.Settings.FPP_ANTISPAM1.duplicatorlimit then
		FPP.Notify(client, "Can't duplicate due to spam", false)
		return false
	end
	return true
end


local function IsEmpty(ent)
	local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
	local tr = {}
	tr.start = mins
	tr.endpos = maxs
	local ignore = player.GetAll()
	table.insert(ignore, ent)
	tr.filter = ignore
	local trace = util.TraceLine(tr)
	return trace.Entity
end

hook.Add("InitPostEntity", "FPP.InitializePreventSpawnInProp", function()
	local backupPropSpawn = DoPlayerEntitySpawn
	function DoPlayerEntitySpawn(client, ...)
		local ent = backupPropSpawn(client, ...)
		if not tobool(FPP.Settings.FPP_ANTISPAM1.antispawninprop) then return ent end

		local PropInProp = IsEmpty(ent)
		if not IsValid(PropInProp) then return ent end
		local pos = PropInProp:NearestPoint(client:EyePos()) + client:GetAimVector() * -1 * ent:BoundingRadius()
		ent:SetPos(pos)
		return ent
	end
end)

--More crash preventing:
local function antiragdollcrash(client)
	local pos = client:GetEyeTraceNoCursor().HitPos
	for k,v in pairs(ents.FindInSphere(pos, 30)) do
		if v:GetClass() == "func_door" then
			FPP.Notify(client, "Can't spawn a ragdoll near doors", false)
			return false
		end
	end
end
hook.Add("PlayerSpawnRagdoll", "FPP.AntiSpam.AntiCrash", antiragdollcrash)