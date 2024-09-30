--# selene: allow(incorrect_standard_library_use)

local numberUtil = require("../other/numberUtil") :: any
local process = require("@lune/process") :: any
local roblox = require("@lune/roblox") :: any
local config = require("../../config") :: any

local function setupBuildInfoScript(updatedRemotePlace)
	for serviceName, scriptType in config.buildInfoScriptInfo.parents do
		local buildInfoScript = roblox.Instance.new(scriptType)
		buildInfoScript.Name = config.buildInfoScriptInfo.buildInfoScriptName
		local formattedOsDate = os.date("!*t", os.time())
		buildInfoScript.Source = string.format(
			'warn(string.format("[lune]: Build %s %s %d [%d:%s %s] (from OS: %s)")) script:Destroy()',
			numberUtil.ordinalNumbers(formattedOsDate.day),
			os.date("%B"),
			formattedOsDate.year,
			numberUtil.h24toh12(formattedOsDate.hour),
			numberUtil.formatM(formattedOsDate.min),
			if formattedOsDate.hour >= 12 then "PM" else "AM",
			process.os
		)

		local parentService = updatedRemotePlace:GetService(serviceName)

		if parentService:FindFirstChild(config.buildInfoScriptInfo.buildInfoScriptName) then
			parentService[config.buildInfoScriptInfo.buildInfoScriptName]:Destroy()
		end

		buildInfoScript.Parent = parentService
	end
end

return setupBuildInfoScript
