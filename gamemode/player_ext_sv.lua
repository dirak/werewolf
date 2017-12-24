--this is server only stuff for the player
local plymeta = FindMetaTable( "Player" )
if not plymeta then return end

AccessorFunc(plymeta, "hunted", "Hunted", FORCE_BOOL)--this makes get/set automatically
AccessorFunc(plymeta, "dead", "Dead", FORCE_BOOL)--this makes get/set automatically

function plymeta:PrimaryAction()
	if !self:GetRole() then return end--no role people should be excluded from actions
	local ply = player.GetBySteamID(self.NightPick)
	hook.Run("RunPrimaryAction", self, ply)
end
