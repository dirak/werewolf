local surface = surface
local draw = draw

--setup fonts
surface.CreateFont("RoleFont", {font = "Arial", size = 24, weight = 800})
surface.CreateFont("KnowledgeFont", {font = "Arial", size = 18, weight = 800})
-- Hide the standard HUD stuff
local hud = {["CHudHealth"] = true, ["CHudBattery"] = true, ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true}
function GM:HUDShouldDraw(name)
   if hud[name] then return false end

   return self.BaseClass.HUDShouldDraw(self, name)
end

--draw who you have selected for the night
local function ShadowedText(text, font, x, y, color, xalign, yalign)
  draw.SimpleText(text, font, x+2, y+2, COLOR_BLACK, xalign, yalign)
  draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

function GM:HUDPaint()
  local client = LocalPlayer()
  ShadowedText(string.format("You are a %s",client:GetRoleString()), "RoleFont", 0, 0, COLOR_RED)
  if client.GameState == ROUND_DAY_PICK_2 then
    if client:GetNightPick() != nil then
      ShadowedText(string.format("You've selected %s for your night action.",client:GetNightPickString()), "RoleFont", 0, 34, COLOR_WHITE)
    end
  end

  if client.GameState == ROUND_DAY_PICK_1 then
    if client:GetDayPick() != nil then
      ShadowedText(string.format("You've voted to exile %s today.",client:GetDayPickString()), "RoleFont", 0, 34, COLOR_WHITE)
    end
  end

  local step = 0
  for id, role in pairs(client.RolesKnown) do
    local ply = player.GetBySteamID(id)
    if ply && ply:IsValid() then
      --for some reason, on file save this clears out & has to be reset?
      ShadowedText(string.format("- You know that %s is a %s", ply:Nick(), role), "KnowledgeFont", 0, 72 + (step * 15), COLOR_LGRAY)
      step = step + 1
    end
  end

  local state = ""
  local timer = ""
  if client.GameState == ROUND_VILLAGER_WIN then
    state = "Villagers Win"
  elseif client.GameState == ROUND_WEREWOLF_WIN then
    state = "Werewolves Win"
  elseif client.GameState == ROUND_NIGHT then
    state = "Nighttime"
  elseif client.GameState == ROUND_DAY_PICK_1 then
    state = "Day Exile Picking"
    local time = GetGlobalFloat("ww_day_time") - CurTime()
    text = util.SimpleTime(math.max(0, time), "%02i:%02i")
  elseif client.GameState == ROUND_DAY_PICK_2 then
    state = "Night Action Picking"
    local time = GetGlobalFloat("ww_day_time") - CurTime()
    text = util.SimpleTime(math.max(0, time), "%02i:%02i")
  elseif client.GameState == ROUND_WAITING then
    text = "Not Enough Players"
  elseif client.GameState == ROUND_PREP then
    local prep_time = GetGlobalFloat("ww_prep_time") - CurTime()
    text = util.SimpleTime(math.max(0, prep_time), "%02i:%02i")
  end
  ShadowedText(state, "RoleFont", 10, ScrH() - 120, COLOR_BLUE)
  ShadowedText(text, "RoleFont", 10, ScrH() - 60, COLOR_BLUE)
  ShadowedText(client.GameState, "RoleFont", 10, ScrH() - 400, COLOR_BLUE)
end
