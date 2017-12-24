Detective = {}
--we need to define the visual name of the role
Detective.Name = "Detective"
Detective.Desc = "A Villager role. Can reveal one players role each night, but has a chance of revealing themselves to the werewolves."
--we need to define the TEAM of the role (Villager, Detective, Neutral)
Detective.Team = TEAM_VILLAGER
--we need to know when to run Detective roles in the resolution of states
--possible values are run in this order: STATE_BEGIN, 1, 2, 3, ... , STATE_END
Detective.RunWhen = STATE_END
--we need to know if we can select ourselves. in the base roles, only werewolves can't
Detective.SelfSelect = true
--we need to define the primary action of the role
function Detective:PrimaryAction(owner, selected)
	--learn the role of the selected
	SendOtherPlayersRole(owner, selected)
	if math.random() <= 0.4 then
		--reveal role to werewolves
		local werewolves = PlayerRoleFilter("werewolf")
		for _,wolf in pairs(werewolves) do
			SendOtherPlayersRole(wolf, owner)
		end
	end
end

hook.Run("InstallRole", Detective)
