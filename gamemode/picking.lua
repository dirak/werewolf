-- Picking Process for exiles
PICKS = {}

--Each day, steamid -> chosen player
--exile
PICKS.PlayerDayPicks = {}

--Each night, steamid -> chosen player
--role stuff (ex. kill/check/see)
PICKS.PlayerNightPicks = {}

--Convars
PICKS.cv = {}

--Functions for handling picks

function PICKS.NewDay()
	--this may need to change a bit, depending on how roles work
	--idea is that each new day, populate the tables w/ the living people
	--so we can check the tables for game-state data
	PICKS.PlayerNightPicks = {}
	PICKS.PlayerDayPicks = {}
	for k,v in pairs(player.GetAll()) do
		PICKS.PlayerNightPicks[v:SteamID()] = 0
		PICKS.PlayerDayPicks[v:SteamID()] = 0
		--end
	end
end

function PICKS.PlayerDayPick(ply, cmd, args)--first two are console
	if #args != 1 then return end
	local pickee = args[1]
	PICKS.PlayerDayPicks[ply:SteamID()] = pickee
end

function PICKS.PlayerNightPick(ply, cmd, args)
	if #args != 1 || !IsValid(ply)  then return end
	local pickee = args[1]
	if ply:SteamID() == pickee then
		--we are self-selecting
		if !ROLES[ply:GetRole()].SelfSelect then
			return--we aren't allowed to self select!
		end
	end
	pickee = player.GetBySteamID(pickee)
	PICKS.PlayerNightPicks[ply:SteamID()] = pickee
	SendPlayerNightPick(ply, pickee:SteamID())
end

function PICKS.PlayerNightUnPick(ply, cmd, args)
	if !ply:IsValid() then return end
	PICKS.PlayerNightPicks[ply:SteamID()] = 0
	SendPlayerNightPick(ply, 0)
end

function PICKS.DayPicksReady()
	local ready = true
	for _,v in pairs(PICKS.PlayerDayPicks) do
		if v == 0 then ready = false end
	end
	return ready
end

function PICKS.NightPicksReady()
	local ready = true
	for _,v in pairs(PICKS.PlayerNightPicks) do
		if v == 0 then ready = false end
	end
	return ready
end

function SendPlayerNightPick(ply, pick)
	ply.NightPick = pick
	net.Start("WW_NightPick")
		net.WriteString(pick)
	net.Send(ply)
end

--the API for using this table
concommand.Add("ww_day_pick", PICKS.PlayerDayPick)
concommand.Add("ww_night_pick", PICKS.PlayerNightPick)
concommand.Add("ww_night_unpick", PICKS.PlayerNightUnPick)
