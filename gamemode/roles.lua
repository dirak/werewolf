ROLES = {}

function GM:InstallRole(role)
	--role is the class(?) that has the functionality
	--role name is the server known name for it, i.e. 'werewolf', 'villager'
	ROLES[role.Name] = role
	print(string.format("[Installed] Role : %s", role.Name) )
end

function GetRole(role_string)
	for _,v in pairs(ROLES) do
		if v.Name == role_string then return v end
	end
	return nil
end

function GM:RunPrimaryAction(player, selected)
	if player:HasRole() then
		ROLES[player:GetRoleString()]:PrimaryAction(player, selected)
	end
end
