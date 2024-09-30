local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.core.sharedPackages.Component)
local Trove = require(ReplicatedStorage.core.sharedPackages.Trove)
local sharedEnums = require(ReplicatedStorage.core.shared.miscellaneous.sharedEnums)

local ExamplePlayerEffect = Component.new({
	tag = sharedEnums.Tag.AFKPlayer,
	extensions = {},
})

function ExamplePlayerEffect:construct()
	self._trove = Trove.new()
end

function ExamplePlayerEffect:start() end

function ExamplePlayerEffect:stop()
	self._trove:Destroy()
end

return ExamplePlayerEffect
