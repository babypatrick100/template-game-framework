local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedEnums = require(ReplicatedStorage.core.shared.miscellaneous.sharedEnums)

local function initializeCollisionGroups()
	for _, collisionGaroup in sharedEnums.PhysicsCollisionGroup do
		PhysicsService:RegisterCollisionGroup(collisionGaroup)
	end
end

return initializeCollisionGroups
