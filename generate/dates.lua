local json = require "json"

local file = io.open ((...) or 'nachweise.json')
local input = json.decode(file:read("*a"))
file:close()

local function todate(input)
	local year, month, day =
		input:match "(%d+)-(%d+)-(%d+)"
	return os.time{day=day, month=month, year=year}
end

local dates = {}
for idx, day in ipairs(input) do
	table.insert(dates, todate(day.tag))
end

local years = {}
for idx, date in ipairs(dates) do
	local year = tonumber(os.date("%Y", date))
	local week = tonumber(os.date("%V", date))
	years[year] = years[year] or {}
	years[year][week] = years[year][week] or {}
	table.insert(years[year][week], date)
end

for year, weeks in pairs(years) do
	for week, days in pairs(weeks) do
		print(year, string.format("%02i", week), #days, os.date("%d.%m.%Y", days[1]))
	end
end
