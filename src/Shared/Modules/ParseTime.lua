local s, m, h, d, w = 1, 60, 3600, 86400, 604800;
local timePatterns = {
  s = s, second = s, seconds = s, sec = s, secs = s,
  m = m, minute = m, minutes = m, min = m, mins = m,
  h = h, hour = h, hours = h, hr = h, hrs = h,
  d = d, day = d, days = d,
  w = w, week = w, weeks = w, wk = w, wks = w
}

local function parseTime(time: string): number
  local seconds = 0 
  for value, unit in time:gsub(" ", ""):gmatch("(%d+)(%a)") do
    local figure: number = value
    seconds += figure * timePatterns[unit]
  end
  return seconds
end

return parseTime