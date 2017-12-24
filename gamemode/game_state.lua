--

game_state = ROUND_WAITING

--first we start the server as prep
function WaitingForPlayersCheck()
	if game_state == ROUND_WAITING then
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
	local prep_end_time = CurTime() + 30
	SetGlobalFloat("ww_prep_time", prep_end_time)
	timer.Create("prep_time", 30, 1, StartDayPick)
end

function StartDay()
	local day_pick_time = CurTime() + GetconVar("ww_day_time"):GetInt()
	SetGlobalFloat("ww_day_time", day_pick_time)
	timer.Create("day_time", day_pick_time, 1, )
end

function StartDayPick()
	SetGameState(ROUND_DAY_PICK_1)
	local day_pick_time = CurTime() + GetconVar("ww_day_time"):GetInt()
	SetGlobalFloat("ww_day_time", day_pick_time)
	timer.Create("day_time", day_pick_time, 1, )

end

function StartNightPick()
	SetGameState(ROUND_DAY_PICK_1)
	local day_pick_time = CurTime() + GetconVar("ww_day_time"):GetInt()
	SetGlobalFloat("ww_day_time", day_pick_time)
	timer.Create("day_time", day_pick_time, 1, )

end
--these are helper functions & aren't directly part of the flow
function GetGameState()
	return game_state
end

function SetGameState(state)
	--we want to uset his so we can sync all the players each time it changes
	game_state = state
	SendGameState()
end

function SendGameState()
	net.Start("ww_GameState")
		net.WriteUInt(game_state, 2)
	net.Broadcast()--send to everyone
end

function EnoughPlayers()
	local ply_count = #player.GetAll()
	print(GetConVar("ww_player_min"):GetInt())
	return ply_count >= GetConVar("ww_player_min"):GetInt()
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
		end
	end
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
