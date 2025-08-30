
if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )


end

if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 7;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Broom";
	SWEP.DrawCrosshair = true;
end

SWEP.Author			= "NightAngel, TheVingard"
SWEP.Instructions = "Primary Fire: Sweep";
SWEP.Purpose = "To sweep up dirt and trash.";
SWEP.Contact = ""
SWEP.AdminSpawnable = true;
SWEP.ViewModel      = ""
SWEP.WorldModel   = ""
SWEP.HoldType = "melee"

SWEP.Primary.Delay			= 0.2 	--In seconds
SWEP.Primary.Recoil			= 0		--Gun Kick
SWEP.Primary.Damage			= 0	--Damage per Bullet
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.Cone			= 0 	--Bullet Spread
SWEP.Primary.ClipSize		= -1	--Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= -1	--Number of shots in next clip
SWEP.Primary.Automatic   	= false	--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "none"	--Ammo Type

SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Delay = 1;
SWEP.Secondary.Ammo	= "";



function SWEP:Deploy()
	if SERVER then
	self:GetOwner().broomProp = ents.Create("prop_dynamic")
	self:GetOwner().broomProp:SetModel("models/props_c17/pushbroom.mdl")
	self:GetOwner().broomProp:DrawShadow(true)
	self:GetOwner().broomProp:SetMoveType(MOVETYPE_NONE)
	self:GetOwner().broomProp:SetParent(self:GetOwner())
	self:GetOwner().broomProp:SetSolid(SOLID_NONE)
	self:GetOwner().broomProp:Spawn()
	self:GetOwner().broomProp:Fire("setparentattachment", "cleaver_attachment", 0.01)

end
end;

function SWEP:Holster()
	if (self:GetOwner().broomProp) then
		if (self:GetOwner().broomProp:IsValid()) then
			self:GetOwner().broomProp:Remove()
			--self:GetOwner():Freeze(false)
			--self:GetOwner():SetForcedAnimation(false)
		end;
	end;
	return true
end;



function SWEP:OnRemove()
	if (self:GetOwner().broomProp) then
		if (self:GetOwner().broomProp:IsValid()) then
			self:GetOwner().broomProp:Remove()
			--self:GetOwner():SetForcedAnimation(false)
		end;
	end;
	return true
end;

function SWEP:PrimaryAttack()
if SERVER then
		if (!self.isSweep) then
			self.isSweep = true
			self:GetOwner():Freeze(true)
			self:GetOwner():forceSequence("Sweep",function()
				self.isSweep=nil
				self:GetOwner():Freeze(false)
			end)
		end;
end
end;



function SWEP:SecondaryAttack()
	return false
end
