--[[Author informations]]--
SWEP.Author = "Brooke"
SWEP.Contact = "dirak.social@gmail.com"

local debug = false

if SERVER then
	AddCSLuaFile()

else
	SWEP.PrintName = "picker"
	SWEP.Slot = 1

	-- client side model settings
	SWEP.UseHands = true -- should the hands be displayed
	SWEP.ViewModelFlip = false -- should the weapon be hold with the left or the right hand
	SWEP.ViewModelFOV = 50

	-- equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "Tool for picking your target."
	}
end

--[[Default GMod values]]--

--[[Model settings]]--
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_PISTOL

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = false

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

SWEP.Primary.Delay = 0.1

function SWEP:PrimaryAttack()
	local trace = util.GetPlayerTrace(self.Owner)
	local tr = util.TraceLine(trace)
	if tr.Entity.IsPlayer() then
		self.Owner:SetPick(tr.Entity)
	end
end

--we don't want an alternative fire yet
function SWEP:SecondaryAttack()
	self.Owner:SetPick(self.Owner)
	return false
end
