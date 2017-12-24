Villager = {}

--we need to define the visual name of the role
Villager.Name = "Villager"
Villager.Desc = "The Vanilla role. They have no extra knowledge & are easy to suspect."
Villager.Team = TEAM_VILLAGER
Villager.RunWhen = STATE_BEGIN
Villager.Multiple = true
Villager.SelfSelect = true--doesn't matter

function Villager:PrimaryAction(owner, selected)
	--do nothing
end

hook.Run("InstallRole", Villager)
