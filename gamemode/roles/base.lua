BaseRole = {}

--we need to define the visual name of the role
BaseRole.Name = "Base"
BaseRole.Desc = "The base role. This should never be seen in the game."
--we need to define the TEAM of the role (Villager, Werewolf, Neutral)
BaseRole.Team = TEAM_NEUTRAL
--we need to define when it resolves. this should be in groups
--possible values are run in this order: STATE_BEGIN, 1, 2, 3, ... , STATE_END
BaseRole.RunWhen = STATE_BEGIN
--we need to know if we can select ourselves. in the base roles, only werewolves can't
BaseRole.SelfSelect = false
--we need to define if we can have more than one of these roles
BaseRole.Multiple = false
--we need to define the primary action of the role
function BaseRole:PrimaryAction(owner, selected)
	--do nothing
end
