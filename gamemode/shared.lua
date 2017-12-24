GM.Name		= "werewolf"
GM.Author	= "dirak"
GM.Email	= "dirak.social@gmail.com"
GM.Website  = "twitter.com/dirak_"

--Team chat will be handled via roles, not teams. ex, cl_voice.lua & gamemsg.lua
TEAM_PLAYERS = 1
team.SetUp( TEAM_PLAYERS, "Players", Color( 125, 125, 125, 255 ) )
team.SetUp( TEAM_SPECTATOR, "Spectators", Color(125, 125, 125, 255) )

COLOR_WHITE  = Color(255, 255, 255, 255)
COLOR_BLACK  = Color(0, 0, 0, 255)
COLOR_GREEN  = Color(0, 255, 0, 255)
COLOR_DGREEN = Color(0, 100, 0, 255)
COLOR_RED    = Color(255, 0, 0, 255)
COLOR_YELLOW = Color(200, 200, 0, 255)
COLOR_LGRAY  = Color(200, 200, 200, 255)
COLOR_BLUE   = Color(0, 0, 255, 255)
COLOR_NAVY   = Color(0, 0, 100, 255)
COLOR_PINK   = Color(255,0,255, 255)
COLOR_ORANGE = Color(250, 100, 0, 255)
COLOR_OLIVE  = Color(100, 100, 0, 255)

TEAM_WEREWOLF = 1
TEAM_VILLAGER = 2
TEAM_NEUTRAL = 3
TEAM_JOINING = 4

STATE_BEGIN = -30
STATE_END = -20

--game state
ROUND_NIGHT = 1
ROUND_PREP = 2
ROUND_WAITING = 3
ROUND_OVER = 4

--day state
ROUND_DAY_PICK_1 = 5
ROUND_DAY_PICK_2 = 6

--win state
ROUND_WEREWOLF_WIN = 7
ROUND_VILLAGER_WIN = 8

function util.SimpleTime(seconds, fmt)
	if not seconds then seconds = 0 end

    local ms = (seconds - math.floor(seconds)) * 100
    seconds = math.floor(seconds)
    local s = seconds % 60
    seconds = (seconds - s) / 60
    local m = seconds % 60

    return string.format(fmt, m, s, ms)
end
