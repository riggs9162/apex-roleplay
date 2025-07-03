local function doDeathPOV(client, origin, angles, fov)
	local Ragdoll = client:GetRagdollEntity()
	if not IsValid(Ragdoll) then return end

	local head = Ragdoll:LookupAttachment("eyes")
	head = Ragdoll:GetAttachment(head)
	if not head or not head.Pos then return end

	local view = {}
	view.origin = head.Pos
	view.angles = head.Ang
	view.fov = fov
	return view
end

hook.Add("CalcView", "DeathPOV", function(client, origin, angles, fov)
	if not client:IsValid() or not client:Alive() or not client:GetRagdollEntity():IsValid() then return end

	local view = doDeathPOV(client, origin, angles, fov)
	if view then
		return view
	end
end)