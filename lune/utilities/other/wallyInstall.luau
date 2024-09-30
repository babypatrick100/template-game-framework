--!nolint
--!nocheck
--# selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")
local processUtil = require("../other/processUtil")

local function wallyInstall()
	if fs.isFile("wally.lock") then
		fs.removeFile("wally.lock")
	end

	processUtil.spawn("wally", { "install" })
end

return wallyInstall
