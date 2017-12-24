Werewolf = {}

--we need to define the visual name of the role
Werewolf.Name = "Werewolf"
Werewolf.Desc = "The main antagonist. Can kill one person per night."
--we need to define the TEAM of the role (Villager, Werewolf, Neutral)
Werewolf.Team = TEAM_WEREWOLF
--possible values are run in this order: STATE_BEGIN, 1, 2, 3, ... , STATE_END
Werewolf.RunWhen = STATE_BEGIN--we want to do werewolf at the start, so guardians can save their victims
--we need to know if we can select ourselves. in the base roles, only werewolves can't
Werewolf.SelfSelect = false
--we need to define the primary action of the role
function Werewolf:PrimaryAction(owner, selected)
	--set the state of the target as hunted.
	--if there is only 1 player set to hunted, that player's state is set to dead.
	--if there is a majority player set to hunted, that player's state is set to dead.
	--if there is a tie, then randomly pick one to be set to dead.
	selected:SetHunted(true)
end

hook.Run("InstallRole", Werewolf)
