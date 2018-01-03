-- shared extensions to player table

local plymeta = FindMetaTable( "Player" )
if not plymeta then return end

AccessorFunc(plymeta, "role", "Role", FORCE_STRING)--this makes get/set automatically

plymeta.NightPick = nil
plymeta.DayPick = nil
plymeta.RolesKnown = {}

--player role stuff

function plymeta:HasRole() return self:GetRole() != nil end

function plymeta:GetRoleString()
	if self:GetRole() == nil then return "None Selected" end--may want to return a default here
	return self:GetRole()
end

--player pick stuff
function plymeta:SetPick(pick)
	if self.GameState == ROUND_DAY_PICK_1 then
		if pick == nil then RunConsoleCommand("ww_day_unpick")
		else RunConsoleCommand("ww_day_pick", pick:SteamID() ) end
	elseif self.GameState == ROUND_DAY_PICK_2 then
		if pick == nil then RunConsoleCommand("ww_night_unpick")
		else
			RunConsoleCommand("ww_night_pick", pick:SteamID() )
		end
	end
end

function plymeta:GetNightPick()
	return self.NightPick
end

function plymeta:GetDayPick()
	return self.DayPick
end

function plymeta:GetNightPickString()
	local ply = player.GetBySteamID(self.NightPick)
	if ply && ply:IsValid() then
		return ply:Nick()
	end
	return "error"
end

function plymeta:GetDayPickString()
	local ply = player.GetBySteamID(self.DayPick)
	if ply && ply:IsValid() then
		return ply:Nick()
	end
	return "error"
end

function plymeta:SetKnownRole(target, role)
	print(target, role)
	plymeta.RolesKnown[target] = role
end

function plymeta:ClearKnownRole()
	plymeta.RolesKnown = {}
end
