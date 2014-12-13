--[[ Calendar for classic conky lovers
Script displays a calendar for given month

To use this script in Conky
1. load scripts:
	lua_load /path/to/text_calendar.lua
2. call function:
	${lua_parse text_calendar}
3. ?????
4. PROFIT

Syntax
${lua_parse text_calendar orient=v dname=t}

Options and their variables:
orient	h (for horizontal orientation) or v (for vertical orientation)
view	b (for output one week - one line) or l (for output in one row/column)
dname	t, b (for orient=h), r or l (for orient=v) to show the days of the week
pos		l, c or r - to align left, center and right or number value to use goto
hofs	number value to use offset or empty to use space
vofs	number value to correct line spacing
month	to show different month


2011.04.07 First release!
2011.04.08 Added some position options
2011.04.09 Added output variations
2011.06.06 Changed the way arguments are passed
2012.01.01 Fix some bugs, cleaned up output
]]

function conky_text_calendar(...)

	local day_per_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local wdays = {'lu', 'ma', 'mi', 'ju', 'vi', 'sa', 'do'}
	local year = tonumber(os.date('%Y'))
	local month = tonumber(os.date('%m'))
	local day = tonumber(os.date('%d'))

	local start_pos
	local h_ofs = ' '
	local v_ofs = '\n'
	local t = {}
	local arg = {...}

	local c_weekday = '${color1}'
	local c_weekend = '${color2}'
	local c_today = '${color3}'

	for i in pairs(arg) do
		for k, v in string.gmatch(arg[i], "([-a-zA-Z0-9]+)=([-a-z0-9]+)") do
			t[k] = v
		end
	end


	if t.orient == nil then t.orient = 'h' end
	if t.view == nil then t.view = 'b' end
	if t.pos == nil then start_pos = ''
		elseif t.pos == 'c' then start_pos = '${alignc}'
		elseif t.pos == 'r' then start_pos = '${alignr}'
		else start_pos = '${goto ' .. t.pos .. '}'
	end
	if t.hofs ~= nil then h_ofs = '${offset ' .. t.hofs .. '}' end
	if t.vofs ~= nil then v_ofs = '${voffset ' .. t.vofs .. '}' end
	if t.month ~= nil then
		day = -1
		month = month + t.month
		year = year + math.floor( (month-1) / 12 )
		month = month - math.floor( (month-1) / 12 ) * 12
	else t.month = 0
	end


	if month == 2 then
		if (year % 4 == 0) and (year % 100 ~= 0) or (year % 400 == 0) then
			day_per_month[2] = 29
		end
	end


	local function fWeekDayByDate(d, m, y)
		tWeekDay = {1, 2, 3, 4, 5, 6, 7}
		local a = math.floor( ( 14 - m )/12 )
		y = y - a
		d = d +3*a
		local w = math.fmod((d+y+math.floor(y/4)-math.floor(y/100)+math.floor(y/400)+math.floor((31*m+10)/12)), 7) + 1
		return tWeekDay[w]
	end

	local sday = fWeekDayByDate(1, month, year)


	local result = start_pos

	if t.orient == 'h' then
		local week = 1
		if t.dname == 't' then
			local wday = sday
			result = result .. c_weekday
			local count
			if t.view == 'b' then
				count = 7
				wday = 1
			else
				count = day_per_month[month]
			end
			for i=1, count do
				if wday == 6 then
					result = result .. c_weekend
				end
				result = result .. wdays[wday]
				wday = wday + 1
				if wday == 8 then
					result = result .. c_weekday
					wday = 1
				end
				if i < count then result = result .. h_ofs end
			end
			result = result .. v_ofs .. start_pos
		end
		local wday = sday
		if t.view == 'b' then result = result .. string.rep('  ' .. h_ofs, wday-1) end
		if wday >=6 then result = result .. c_weekend end
		for i=1, day_per_month[month] do
	   		if i < 10 then result = result .. ' ' end
    	    if i == day then result = result .. c_today
			elseif wday == 6 then result = result .. c_weekend end
			result = result .. i
    	    if i == day then
				if wday >= 6 then result = result .. c_weekend
				elseif wday < 5 then result = result .. c_weekday
				end
			end
			wday = wday + 1
			if wday == 8 then
				wday = 1
				week = week + 1
				if t.view == 'b' then
					result = result .. v_ofs .. start_pos
				end
				if t.view == 'l' then
					result = result .. h_ofs
				end
				result = result .. c_weekday
			end
			if i < day_per_month[month] and wday > 1 then result = result .. h_ofs end
		end
		if t.view == 'b' then result = result .. string.rep(h_ofs .. '  ', 8-wday) end
		if t.view == 'b' and week < 6 then result = result .. v_ofs end
		if t.dname == 'b' then
			result = result .. v_ofs .. c_weekday .. start_pos
			local wday = sday
			local count
			if t.view == 'b' then
				count = 7
				wday = 1
			else
				count = day_per_month[month]
			end
			for i=1, count do
				if wday >= 6 then
					result = result .. c_weekend
				end
				result = result .. wdays[wday]
				wday = wday + 1
				if wday == 8 then
					result = result .. c_weekday
					wday = 1
				end
				if i < count then result = result .. h_ofs end
			end
		end


	elseif t.orient == 'v' then
		if t.view == 'l' then
			local wday = sday
			if wday >= 6 then
				result = result .. c_weekend
			else
				result = result .. c_weekday
			end
			for i=1, day_per_month[month] do
				if t.dname == 'l' then
					if wday == 6 then
						result = result .. c_weekend
					end
					result = result .. wdays[wday] .. h_ofs
				end
				if i < 10 then result = result .. ' ' end
				if wday == 6 and t.dname ~= 'l' then result = result .. c_weekend end
				if i == day then result = result .. c_today end
				result = result .. i
				if i == day then
					if wday >= 6 then
						result = result .. c_weekend
					else
						result = result .. c_weekday
					end
				end
				if t.dname == 'r' then result = result .. h_ofs .. wdays[wday] end
				if wday == 7 then
					result = result .. c_weekday
				end
				wday = wday + 1
				if wday == 8 then wday = 1 end
				if i < day_per_month[month] then result = result .. v_ofs .. start_pos end
			end
		elseif t.view == 'b' then
			result = result .. c_weekday
			for i=1, 7 do
				if i >= 6 then result = result .. c_weekend end
				if t.dname == 'l' then result = result .. wdays[i] .. h_ofs end
				for j=1, 6 do
					local wday = 7 * (j - 1) + 1 - sday + i
					if ( t.month == nil or t.month == 0 ) and wday == day then result = result .. c_today end
					if wday < 1 or wday > day_per_month[month] then
						result = result .. '  '
					else
						if wday < 10 then result = result .. ' ' end
						result = result .. wday
					end
					if ( t.month == nil or t.month == 0 ) and wday == day then
						if i >= 6 then result = result .. c_weekend
						else result = result .. c_weekday end
					end
					if j < 6 then result = result .. h_ofs end
				end
				if t.dname == 'r' then result = result .. h_ofs .. wdays[i] end
				if i < 7 then result = result .. v_ofs .. start_pos end
			end
		end
	end


	return result .. c_weekday

end
