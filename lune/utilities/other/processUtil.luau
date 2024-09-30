--# selene: allow(incorrect_standard_library_use)
local process = require("@lune/process") :: any

local processUtil = {}

function processUtil.spawn(...)
	local response = process.spawn(...)

	if response.code ~= 0 then
		error(response.stderr)
	end
end

return table.freeze(processUtil)
