#!/usr/bin/env luajit

local moonxml = require 'moonxml'
local json = require "cjson"

local name = ...

for i=2, select('#', ...) do
	local file = assert(io.open(select(i, ...), "r"))
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
	for idx, entry in ipairs(input) do
		local date = todate(entry.tag)
		local year = tonumber(os.date("%Y", date))
		local week = tonumber(os.date("%V", date))
		years[year] = years[year] or {}
		years[year][week] = years[year][week] or {}
		table.insert(years[year][week], entry)
	end

	for year, weeks in pairs(years) do
		for week, days in pairs(weeks) do
			local filename = string.format("%i-%02i.html", year, week)
			local file = assert(io.open(filename, "w"))
			moonxml.html.environment.print = function(...)
				file:write(...)
			end
			moonxml.html:loadmoonfile('template.moonhtml')(year, week, days, name)
			file:close()
		end
	end
end

os.execute('ls *.html | sort | xargs -I % wkhtmltopdf % %.pdf')
os.execute('echo Uniting: `ls *.html.pdf | sort`')
os.execute('pdfunite `ls *.html.pdf | sort` "'..name..'".pdf')
--os.execute('rm *.html.pdf *.html')
