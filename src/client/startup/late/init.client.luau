local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local clientEnums = require(ReplicatedStorage.core.client.miscellaneous.clientEnums)
local instanceAttributeUtil = require(ReplicatedStorage.core.sharedPackages.instanceAttributeUtil)
local startupUtil = require(ReplicatedStorage.core.shared.utilities.startupUtil)

-- Ensure all persistent models are loaded before starting up, otherwise we would
-- run into bugs.
instanceAttributeUtil
	.instanceAttributePromise(Workspace, clientEnums.Attribute.WorkspacePersistentLoaded)
	:expect()

startupUtil.startup({
	bootstrapperHolders = { script.bootstrapers, ReplicatedStorage.core.shared.bootstrapers },
	componentHolders = {
		ReplicatedStorage.core.client.components,
		ReplicatedStorage.core.shared.components,
	},
	controllers = {
		paths = {
			ReplicatedStorage.core.shared.controllers,
			ReplicatedStorage.core.client.controllers,
		},
		nameFormat = "Controller$",
	},
})
