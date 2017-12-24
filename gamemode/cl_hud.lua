local surface = surface
local draw = draw

--setup fonts
surface.CreateFont("RoleFont", {font = "Trebuchet24", size = 24, weight = 800})
surface.CreateFont("KnowledgeFont", {font = "Trebuchet24", size = 18, weight = 800})
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
  if client:GetNightPick() != nil then
    ShadowedText(string.format("You've selected %s for your action.",client:GetNightPickString()), "RoleFont", 0, 34, COLOR_WHITE)
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

  local prep_time = GetGlobalFloat("ww_prep_time") - CurTime()
  local text = util.SimpleTime(math.max(0, prep_time), "%02i:%02i")
  ShadowedText(text, "RoleFont", 240, 240, COLOR_BLUE)
end
