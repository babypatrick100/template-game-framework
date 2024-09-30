local ReplicatedStorage = game:GetService("ReplicatedStorage")

local servicesNetworkConfig = {
	servicesNetworkFolderParent = ReplicatedStorage,
	servicesNetworkFolderName = "ServiceNetworks",
	servicesNetworkFolderRetrievalTimeout = 15,

	serviceNetworkServerConfig = {
		automaticArgumentSerializationAndDeserializationEnabled = true,
		promisifyCallbacks = true,
	},
}

return table.freeze(servicesNetworkConfig)
