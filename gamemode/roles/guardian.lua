Guardian = {}
--we need to define the visual name of the role
Guardian.Name = "Guardian"
Guardian.Desc = "A Villager role. Can protect one person per night."
--we need to define the TEAM of the role (Villager, Guardian, Neutral)
Guardian.Team = TEAM_VILLAGER
--we need to know when to run Guardian roles in the resolution of states
--possible values are run in this order: STATE_BEGIN, 1, 2, 3, ... , STATE_END
Guardian.RunWhen = STATE_END
--we need to know if we can select ourselves. in the base roles, only werewolves can't
Guardian.SelfSelect = true
--we need to define the primary action of the role
function Guardian:PrimaryAction(owner, selected)
	selected:SetDead(false)--whoever we choose just won't die! yay
end

hook.Run("InstallRole", Guardian)
