AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_team.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile("cl_vote.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("roles.lua")
AddCSLuaFile("player_ext.lua")

print("WELCOME TO WEREWOLF")

include("shared.lua")
include("game_state.lua")
include("picking.lua")
include("player_ext.lua")
include("player_ext_sv.lua")--this may not work
include("roles.lua")

--install base roles
--roles need to be server only so the player can't figure shit out
include("roles/villager.lua")
include("roles/werewolf.lua")
include("roles/guardian.lua")
include("roles/detective.lua")

function GM:Initialize()
 SetGameState(ROUND_WAITING)
end

function GM:PlayerSpawn( ply )  --What happens when the player spawns
	self.BaseClass:PlayerSpawn( ply )
	ply:SetGravity( 0.75 )
	ply:SetMaxHealth( 100, true )

	ply:SetWalkSpeed( 325 )
	ply:SetRunSpeed( 325 )

	SendGameState()

end

function GM:PlayerInitialSpawn( ply )
	print("PLAYER JOIN")
	joining( ply )
	StartRound()
end --close the function


	function GM:PlayerLoadout( ply )
	if ply:Team() == TEAM_PLAYERS then
		ply:Give( "ww_weapon_picker" )
 end
end

function KillPlayer(ply)
	ply:SetTeam(TEAM_SPECTATOR)
	ply:SetRole(nil)
end

function ww_team_player( ply )
	ply:UnSpectate()
	ply:SetTeam( TEAM_PLAYERS )
	ply:Spawn()
	ply:Give( "ww_weapon_picker" )--?

end

function ww_team_spectate( ply )
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetTeam( TEAM_SPECTATOR )
	--ply:Spawn()
end

function ww_role_werewolf(ply)
	ply:SetRole('Werewolf')
	SendPlayerRoles()
end

function ww_role_guardian(ply)
	ply:SetRole('Guardian')
	SendPlayerRoles()
end

function ww_role_detective(ply)
	ply:SetRole('Detective')
	SendPlayerRoles()
end

function ww_role_villager(ply)
	ply:SetRole('Villager')
	SendPlayerRoles()
end

function joining( ply ) -- The function that's called when the player is not admin or a special character, at the top.
	ply:Spectate( 5 ) --Set him to spectate in free-roam mode. He doesn't actually fly around, since he has a window open at this point.
	ply:SetTeam( TEAM_JOINING ) --Set his team to Joining

end --End the function

concommand.Add( "ww_team_player", ww_team_player )
concommand.Add( "ww_role_werewolf", ww_role_werewolf )--debug
concommand.Add( "ww_role_guardian", ww_role_guardian )--debug
concommand.Add( "ww_role_detective", ww_role_detective )--debug
concommand.Add( "ww_role_villager", ww_role_villager)--debug
concommand.Add( "ww_team_spectate", ww_team_spectate )
concommand.Add( "ww_debug_resolve", ResolveNight )
concommand.Add( "ww_debug_roles", SelectRoles )

util.AddNetworkString("WW_Role")
util.AddNetworkString("WW_NightPick")
util.AddNetworkString("WW_DayPick")
util.AddNetworkString("WW_RoundStart")
util.AddNetworkString("WW_OtherPlayersRole")
util.AddNetworkString("WW_PlayerInfoReset")
util.AddNetworkString("WW_GameState")

CreateConVar("ww_player_min", "2")
CreateConVar("ww_werewolf_pct", "0.25")
CreateConVar("ww_werewolf_max", "3")
CreateConVar("ww_neutral_pct", "0.1")
CreateConVar("ww_neutral_max", "2")
CreateConVar("ww_villager_min", "1")
CreateConVar("ww_day_time", "20")

function ResetPlayerInfo(ply)
	ply:SetDead(false)--alive
	ply:SetHunted(false)
	ply:SetRole("villager")
	net.Start("WW_PlayerInfoReset")
		net.WriteString(ply:SteamID())
	net.Send(ply)
end

function SendPlayerRoles()
	for _,v in pairs(player.GetAll()) do
		if v:GetRole() == nil then
			v:SetRole('Villager')--debug
		end
		net.Start("WW_Role")
			net.WriteString(v:GetRole())
		net.Send(v)

	end
end

function SendOtherPlayersRole(owner, selected)
	net.Start("WW_OtherPlayersRole")
		net.WriteString(selected:SteamID())
		net.WriteString(selected:GetRoleString())
	net.Send(owner)
end

function PlayerRoleFilter(role)
	local players = {}
	for _,v in pairs(player.GetAll()) do
		if v:GetRole() == role then
			table.insert(players, v)
		end
	end
	return players
end

function PlayerTeamFilter(team)
	local players = {}
	for _,v in pairs(player.GetAll()) do
		if v:HasRole() && v:GetRole() != nil then
			local role = GetRole(v:GetRole())
			if role != nil then
				if role.Team == team then
					table.insert(players, v)
				end
			end
		end
	end
	return players
end

function TeamRoleFilter(team, without)
	local roles = {}
	for _,v in pairs(ROLES) do
		if v.Team == team && v.Name != without then
			table.insert(roles, v)
		end
	end
	return roles
end

function GetWerewolfCount(ply_count)
	--this is a direct copy from TTT, fits our needs perfectly
	local count = math.floor(ply_count * GetConVar("ww_werewolf_pct"):GetFloat())
	count = math.Clamp(count, 1, GetConVar("ww_werewolf_max"):GetInt())
	return count
end

function GetNeutralCount(ply_count)
	local count = math.floor(ply_count * GetConVar("ww_neutral_pct"):GetFloat())
	count = math.Clamp(count, 1, GetConVar("ww_neutral_max"):GetInt())
	return count
end

function GetVillagerCount(ply_count)
	local count = GetConVar("ww_villager_min"):GetInt()
	if count > ply_count then
		--if we have a min that is greater than what is left, we need to pull back a bit
		if ply_count > 1 then return ply_count - 1 end --should have one special role at least
		return ply_count--if we absolutely can't we'll return what is left.
		--this is all just from bad server config, but it should still run regardless
	end
	return count
end

function SelectRoles()
	--ok we need to select roles for everyone!
	local choices = {}
	local villager_roles = TeamRoleFilter(TEAM_VILLAGER, "Villager")--doesn't include villager
	local werewolf_roles = TeamRoleFilter(TEAM_WEREWOLF, "Werewolf")--doesn't include werewolf
	local neutral_roles = TeamRoleFilter(TEAM_NEUTRAL)
	for k,v in pairs(player.GetAll()) do
		table.insert(choices, v)
		ResetPlayerInfo(v)--reset any info just incase. i bet i get a bug here though
	end

	--pick the werewolves first
	local ww = 0
	local ww_count = GetWerewolfCount(#choices)
	while ww < ww_count do
		local pick = math.random(1, #choices)
		local ww_ply = choices[pick]
		if IsValid(ww_ply) then
			table.remove(choices, pick)
			ww_ply:SetRole("Werewolf")
			ww = ww + 1
		end
	end
	--if we meet the requirements for a neutral player, % pick one
	local neutral = 0
	local neutral_count = GetNeutralCount(#choices)
	while neutral < neutral_count && #neutral_roles > 0 do
		local pick = math.random(1, #choices)
		local neutral_ply = choices[pick]
		if IsValid(neutral_ply) then
			table.remove(choices, neutral_ply)
			local role_pick = math.random(1, #neutral_roles)
			local role = neutral_roles[role_pick]
			neutral_ply:SetRole(role.Name)
			table.remove(neutral_roles, role_pick)
			table.remove(choices, pick)
			neutral = neutral + 1
		end
	end
	--if we meed the requirements for a werewolf aligned player, % pick one

	--everyone left is a villager. let's pick which roles they get
	--check to make sure min villager count is met first
	local villager = 0
	local villager_count = GetVillagerCount(#choices)
	while villager < villager_count do
		local pick = math.random(1, #choices)
		local villager_ply = choices[pick]
		if IsValid(villager_ply) then
			villager_ply:SetRole("Villager")--unlucky!
			table.remove(choices, pick)
			villager = villager + 1
		end
	end
	--ok now special roles for villagers. we will fill in everyone who is left
	for _,v in pairs(choices) do
		if #choices > #villager_roles then
			v:SetRole("Villager")--if we dont have enough roles installed they will be vanilla
		else
			local pick = math.random(1, #villager_roles)
			local role = villager_roles[pick]
			v:SetRole(role.Name)
			table.remove(villager_roles, pick)
		end
	end
	SendPlayerRoles()
end

function GM:PlayerDisconnect(ply)
	print("disconnected")
	if !EnoughPlayers() then
		print("not enough people!")
		WaitingForPlayers()--someone left, not enough, gotta look for more
	end
	WaitingForPlayersCheck()
end

WaitingForPlayers()
