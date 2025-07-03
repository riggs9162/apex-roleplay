local meta = FindMetaTable("Player")

function meta:NewHungerData()
	if not IsValid(self) then return end
	self:SetSelfDarkRPVar("Energy", 100)
	self:GetTable().LastHungerUpdate = 0
end

function meta:HungerUpdate()
	if not IsValid(self) then return end
	if not GAMEMODE.Config.hungerspeed then return end
	self:SetSelfDarkRPVar("Energy", math.Clamp(self:GetDarkRPVar("Energy") - GAMEMODE.Config.hungerspeed / 10, 0, 100))
	self:GetTable().LastHungerUpdate = CurTime()

	if self:GetDarkRPVar("Energy") == 0 then
		self:SprintDisable()

		if self:Health() > GAMEMODE.Config.starverate then
			self:EmitSound("vo/npc/male01/pain02.wav")
			self:SetHealth(self:Health() - GAMEMODE.Config.starverate)
		elseif self:Health() > 1 then
			self:EmitSound("vo/npc/male01/pain02.wav")
			self:SetHealth(self:Health() - 1)
		end
	else
		self:SprintEnable()
	end
end
