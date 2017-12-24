--

GAMEMODE.GameState = ROUND_WAITING

--first we start the server as prep
function WaitingForPlayersCheck()
	if GAMEMODE.GameState == ROUND_WAITING then
		if EnoughPlayers() then
			timer.Create("start_prep", 1, 1, StartRoundPrep)
			timer.Stop("waiting_for_players")
		end
	end
end

function WaitingForPlayers()
	SetGameState(ROUND_WAITING)
	SetGlobalFloat("ww_prep_time", 0)
	if not timer.Start("waiting_for_players") then
		timer.Create("waiting_for_players", 1, 0, WaitingForPlayersCheck)
	end
end

function StartRoundPrep()
	SetGameState(ROUND_PREP)
	local prep_end_time = CurTime() + 3--TODO:cvar this
	SetGlobalFloat("ww_prep_time", prep_end_time)
	timer.Create("prep_time", 3, 1, StartFirstDay)
end

function StartFirstDay()
	print("start first day")
	SelectRoles()
	StartDayTwo()
end

function StartDay(pick)
	print("start day")
	print(pick)
	local day_pick_time = CurTime() + GetConVar("ww_day_time"):GetInt()
	SetGlobalFloat("ww_day_time", day_pick_time)
	if pick == 1 then
		SetGameState(ROUND_DAY_PICK_1)
		if CheckForWin() then return end
		timer.Create("day_time", GetConVar("ww_day_time"):GetInt(), 1, StartDayTwo)
	else
		ResolveDay()
		SetGameState(ROUND_DAY_PICK_2)
		timer.Create("day_time", GetConVar("ww_day_time"):GetInt(), 1, StartNight)
	end
end

function StartDayOne()
	StartDay(1)
end

function StartDayTwo()
	StartDay(2)
end

function StartNight()
	print("start night")
	--first we clean up whoever we exiled
	SetGameState(ROUND_NIGHT)
	ResolveNight()
	timer.Create("night_time", 5, 1, StartDayOne)
end

--these are helper functions & aren't directly part of the flow
function GetGameState()
	return GAMEMODE.GameState
end

function SetGameState(state)
	--we want to uset his so we can sync all the players each time it changes
	GAMEMODE.GameState = state
	SendGameState()
end

function SendGameState()
	net.Start("WW_GameState")
		net.WriteString(GAMEMODE.GameState)
	net.Broadcast()--send to everyone
	print("sent this game state")
	print(GAMEMODE.GameState)
end

function EnoughPlayers()
	local ply_count = #player.GetAll()
	return ply_count >= GetConVar("ww_player_min"):GetInt()
end

function ResolveDay()
	local voted = ResolveVoted()
	for _,v in pairs(voted) do
		local ply = player.GetBySteamID(v)
		print(ply)
		ply:Kill()
		KillPlayer(ply)
	end
end

function ResolveNight()
	--ok let's do this. we're going to resolve the nights events.
	--all this shit can probably be done once the round starts & never again?
	local ROUND_START = {}
	local ROUND_MIDDLE = {}
	local ROUND_END = {}
	--ok first lets put all the actions into bins
	for _,v in pairs(player.GetAll()) do
		if v:GetRole() != nil then
			local role = ROLES[v:GetRole()]
			if role.RunWhen == STATE_BEGIN then
				ROUND_START[v:SteamID()] = v
			elseif role.RunWhen == STATE_END then
				ROUND_END[v:SteamID()] = v
			else
				ROUND_MIDDLE[v:SteamID()] = v
			end
		end
	end

	for _,v in pairs(ROUND_START) do
		v:PrimaryAction()--do the primary action
	end
	local hunted = ResolveHunted()
	if hunted == nil then
		--uhhhhhh something bad happened, this shouldnt happen
		return
	end
	hunted = player.GetBySteamID(hunted)
	hunted:SetDead(true)--we found our victim
	--should send off an event here for the hunted->dead person to react
	for _,v in pairs(ROUND_MIDDLE) do
		v:PrimaryAction()--do the primary action
	end

	for _,v in pairs(ROUND_END) do
		v:PrimaryAction()--do the primary action
	end

	ResolveDead()
end

function ResolveHunted()
	--ok we need to resolve who the werewolves decided to Kill
	local hunted = {}
	local highest_vote = 0
	for _,v in pairs(player.GetAll()) do
		if v:GetHunted() then
			v:SetHunted(false)--fixes it for next round, should do this all somewhere central prolly
			if hunted[v:SteamID()] == nil then hunted[v:SteamID()] = 0 end
			local vote_count = hunted[v:SteamID()] + 1
			hunted[v:SteamID()] = vote_count
			if vote_count > highest_vote then highest_vote = vote_count end
		end
	end

	local final = {}
	for id,v in pairs(hunted) do
		if v == highest_vote then
			table.insert(final, id)
		end
	end

	return math.randomchoice(final)--gotta decide somehow
end

function ResolveVoted()
	local voted = {}
	local highest_vote = 0
	for _,v in pairs(PICKS.PlayerDayPicks) do
		if voted[v:SteamID()] == nil then voted[v:SteamID()] = 0 end
		local vote_count = voted[v:SteamID()] + 1
		voted[v:SteamID()] = vote_count
		if vote_count > highest_vote then highest_vote = vote_count end
	end

	local final = {}
	for id,v in pairs(voted) do
		if v == highest_vote then
			table.insert(final, id)
		end
	end
	PrintTable(final)
	if #final > 1 then return {} end
	return final
end

function StartRound()
	--prep time is up time to start the round
	for _,v in pairs(player.GetAll()) do
		net.Start("WW_RoundStart")
		net.Send(v)
	end
	PICKS.NewDay()
end

function ResolveDead()
	--we need to kill off the person(s) that died tonight
	for _,v in pairs(player.GetAll()) do
		if v:GetDead() then
			v:SetDead(false)--fixes for next round
			v:Kill()--TODO: rewrite to make them spectator & create ragdoll like TTT
			KillPlayer(v)
		end
	end
end

function CheckForWin()
	local werewolves = PlayerTeamFilter(TEAM_WEREWOLF)
	local villagers = PlayerTeamFilter(TEAM_VILLAGER)
	if #werewolves >= #villagers then
		timer.Stop("day_time")--stop the day from ending
		timer.Stop("night_time")
		SetGameState(ROUND_WEREWOLF_WIN)
		return true
		--werewolf win
	elseif werewolves == 0 then
		timer.Stop("day_time")
		timer.Stop("night_time")
		SetGameState(ROUND_VILLAGER_WIN)
		return true
		--villager win
	end
	return false
end

--util
function math.randomchoice(t) --Selects a random item from a table
    local keys = {}
    for key, value in pairs(t) do
			table.insert(keys, key)
    end
    index = keys[math.random(1, #keys)]
    return t[index]
end
