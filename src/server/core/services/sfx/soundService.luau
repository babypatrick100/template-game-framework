local ReplicatedStorage = game:GetService("ReplicatedStorage")

local network = require(ReplicatedStorage.core.sharedPackages.network)

local NetworkServer = network.Server

local soundService = {
	client = {
		playSound = NetworkServer.RemoteSignal.new(),
	},
}

return table.freeze(soundService)
