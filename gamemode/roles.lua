ROLES = {}

function GM:InstallRole(role)
	--role is the class(?) that has the functionality
	--role name is the server known name for it, i.e. 'werewolf', 'villager'
	ROLES[role.Name] = role
	print(string.format("[Installed] Role : %s", role.Name) )
end

function GM:RunPrimaryAction(player, selected)
	if player:HasRole() then
		ROLES[player:GetRoleString()]:PrimaryAction(player, selected)
	end
end
