local numberUtil = {}

function numberUtil.h24toh12(h)
	if h > 12 then
		return h - 12
	else
		return h
	end
end

-- https://stackoverflow.com/questions/20694133/how-to-to-add-th-or-rd-to-the-date
function numberUtil.ordinalNumbers(number)
	local ordinal, digit = { "st", "nd", "rd" }, string.sub(number, -1)
	if
		tonumber(digit) > 0
		and tonumber(digit) <= 3
		and tonumber(string.sub(number, -2)) ~= 11
		and tonumber(string.sub(number, -2)) ~= 12
		and tonumber(string.sub(number, -2)) ~= 13
	then
		return number .. ordinal[tonumber(digit) :: number]
	else
		return number .. "th"
	end
end

function numberUtil.formatM(m)
	if m < 10 then
		return string.format("0%d", m)
	else
		return tostring(m)
	end
end

return table.freeze(numberUtil)
