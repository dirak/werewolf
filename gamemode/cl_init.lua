include("shared.lua")

include("cl_vote.lua")
include("cl_hud.lua")
include("cl_team.lua")
include("player_ext.lua")

local function RoundStart()
	print("test")
	RunConsoleCommand("ww_team_player")
end

net.Receive("WW_RoundStart", RoundStart)

local function ReceiveRole()
	local client = LocalPlayer()
	local role = net.ReadString()
	client:SetRole(role)
end

net.Receive("WW_Role", ReceiveRole)

function ReceiveNightPick()
	local client = LocalPlayer()
	local pick = net.ReadString()
	client.NightPick = pick
end

net.Receive("WW_NightPick", ReceiveNightPick)

function ReceiveDayPick()
	local client = LocalPlayer()
	local pick = net.ReadString()
	client.DayPick = pick
end

net.Receive("WW_DayPick", ReceiveNightPick)


function ReceiveOtherPlayersRole()
	local client = LocalPlayer()
	local target = net.ReadString()--this is steamID
	local role = net.ReadString()
	client:SetKnownRole(target, role)
end

net.Receive("WW_OtherPlayersRole", ReceiveOtherPlayersRole)

function ReceivePlayerInfoReset()
	local client = LocalPlayer()
	local id = net.ReadString()--verify it is for us
	print("hello debug")
	if id == client:SteamID() then
		--this is fine to be on client, if they fiddle with this
		--it will just change the UI, the server won't be affected
		client:SetRole("villager")
		client.RolesKnown = {}
	end 
end

net.Receive("WW_PlayerInfoReset", ReceivePlayerInfoReset)

function ReceiveGameState()
	local new_state = net.ReadString()
	local client = LocalPlayer()
	client.GameState = tonumber(new_state)
end

net.Receive("WW_GameState", ReceiveGameState)
