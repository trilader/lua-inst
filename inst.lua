local date_formats = {
  "(%d%d%d%d)%-(1[012])%-([012]%d)",
  "(%d%d%d%d)%-(1[012])%-(3[01])",

  "(%d%d%d%d)%-(0%d)%-([012]%d)",
  "(%d%d%d%d)%-(0%d)%-(3[01])",

  "(%d%d%d%d)%-(1[012])",
  "(%d%d%d%d)%-(0%d)",

  "(%d%d%d%d)(1[012])([012]%d)",
  "(%d%d%d%d)(1[012])(3[01])",

  "(%d%d%d%d)(0%d)([012]%d)",
  "(%d%d%d%d)(0%d)(3[01])",

  "(%d%d%d%d)(1[012])",
  "(%d%d%d%d)(0%d)",

  "(%d%d%d%d)",
}

local time_formats = {
  "([01]%d):([0-5]%d):([0-5]%d)%.(%d+)",
  "([2][0-4]):([0-5]%d):([0-5]%d)%.(%d+)",

  "([01]%d):([0-5]%d):(60)%.(%d+)",
  "([2][0-4]):([0-5]%d):(60)%.(%d+)",

  "([01]%d):([0-5]%d):([0-5]%d)",
  "([2][0-4]):([0-5]%d):([0-5]%d)",

  "([01]%d):([0-5]%d):(60)",
  "([2][0-4]):([0-5]%d):(60)",
}

local offset_formats = {
  "([+-])([01]%d):([0-5]%d)",
  "([+-])([2][0-4]):([0-5]%d)",

  "([+-])([01]%d)([0-5]%d)",
  "([+-])([2][0-4])([0-5]%d)",

  "([+-])([01]%d)",
  "([+-])([2][0-4])",

  "Z"
}

-- composing all possible ISO8601 patterns
local iso8601_formats = {}
for _,i in ipairs({1,2,3,4,7,8,9,10}) do
  for _,time_fmt in ipairs(time_formats) do
    for _,offset_fmt in ipairs(offset_formats) do
      iso8601_formats[#iso8601_formats+1] = "^"..date_formats[i].."T"..time_fmt..offset_fmt.."$"
    end
  end
end

local function is_leap_year(year)
  return 0 == year % 4 and (0 ~= year % 100 or 0 == year % 400)
end

local function parse_date_time (date_time_str)
  local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m

  -- trying to parse a complete ISO8601 date
  for _,fmt in pairs(iso8601_formats) do
    year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = date_time_str:match(fmt)
    if year then break end
  end

  -- milliseconds are optional, so offset may be stored in ms
  if not off_m and ms and ms:match("^[+-]") then
    off_m, off_h, sign, ms = off_h, sign, ms, 0
  end

  return year, mon, day, hh, mm, ss, ms, sign, off_h, off_m
end

local function parse_date (date_str)
  local year, mon, day
  for _,fmt in pairs(date_formats) do
    year, mon, day = date_str:match("^"..fmt.."$")
    if year ~= nil then break end
  end

  return year, mon, day
end

local function parse_iso8601 (date_str)
  local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = parse_date_time(date_str)
  sign, off_h, off_m = sign or "+", off_h or 0, off_m or 0

  if not year then
    -- trying to parse only a year with optional month and day
    year, mon, day = parse_date(date_str)
  end

  if not year then
    error("invalid date: date string doesn't match ISO8601 pattern", 2)
  end

  if is_leap_year(tonumber(year)) and tonumber(mon) == 2 and tonumber(day) > 28 then
    error("invalid date: wrong leap year date", 2)
  end

  return {
    year = tonumber(year) or 1970,
    month = tonumber(mon) or 01,
    day = tonumber(day) or 01,
    hour = (tonumber(hh) or 00) - (tonumber(sign..off_h) or 00),
    min = (tonumber(mm) or 00) - (tonumber(sign..off_m) or 00),
    sec = tonumber((ss or 00)),
    msec = tonumber(ms or 00)
  }
end

local function inst (date_str)
  local date = parse_iso8601(date_str)
  return setmetatable(
    date,
    {
      __len = function ()
        local str = os.date("#inst \"%Y-%m-%dT%H:%M:%S", os.time(date))
        return string.format("%s.%03d-00:00\"", str, date.msec)
      end
    }
  )
end

return inst
