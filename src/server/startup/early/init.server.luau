local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local startupUtil = require(ReplicatedStorage.core.shared.utilities.startupUtil)

startupUtil.startup({
	bootstrapperHolders = { script.bootstrapers, ReplicatedStorage.core.shared.bootstrapers },
	componentHolders = {
		ServerStorage.core.server.components,
		ReplicatedStorage.core.shared.components,
	},
	controllers = {
		paths = { ReplicatedStorage.core.shared.controllers },
		nameFormat = "Controller$",
	},
	services = {
		paths = { ServerStorage.core.server.services },
		nameFormat = "Service$",
	},
})
