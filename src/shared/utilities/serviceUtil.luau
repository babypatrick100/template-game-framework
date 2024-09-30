local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local instanceAttributeUtil = require(ReplicatedStorage.core.sharedPackages.instanceAttributeUtil)
local network = require(ReplicatedStorage.core.sharedPackages.network)
local servicesNetworkConfig =
	require(ReplicatedStorage.core.shared.configurations.servicesNetworkConfig)
local sharedEnums = require(ReplicatedStorage.core.shared.miscellaneous.sharedEnums)

local SERVICE_NOT_FOUND_BASE_ERROR_MESSAGE = 'Service "%s" was not found!'
local CAN_ONLY_RUN_ON_CLIENT_BASE_ERROR_MESSAGE = "Can only run on client"
local SERVICE_CORRUPT_CLIENT_MEMBER_BASE_ERROR_MESSAGE =
	"Service \"%s\" has corrupt 'client' member. Expected type 'table' or 'nil' but got type '%s' instead."
local SERVICE_NETWORKS_FOLDER_NOT_FOUND_WITHIN_DUE_TIME_BASE_ERROR_MESSAGE =
	'Service networks folder "%s" not found in %s - (%.2fs elapsed). Are you sure [%s] was required on the server?'

local NetworkServer = network.Server

local replicatedServices = {}

local serviceUtil = {}

local function servicesNetworkFolder()
	if RunService:IsClient() then
		local targetServicesNetworkFolder =
			servicesNetworkConfig.servicesNetworkFolderParent:WaitForChild(
				servicesNetworkConfig.servicesNetworkFolderName,
				servicesNetworkConfig.servicesNetworkFolderRetrievalTimeout
			)

		assert(
			targetServicesNetworkFolder,
			string.format(
				SERVICE_NETWORKS_FOLDER_NOT_FOUND_WITHIN_DUE_TIME_BASE_ERROR_MESSAGE,
				servicesNetworkConfig.servicesNetworkFolderName,
				servicesNetworkConfig.servicesNetworkFolderParent:GetFullName(),
				servicesNetworkConfig.servicesNetworkFolderRetrievalTimeout,
				script:GetFullName()
			)
		)

		return targetServicesNetworkFolder
	end

	return servicesNetworkConfig.servicesNetworkFolderParent[servicesNetworkConfig.servicesNetworkFolderName]
end

function serviceUtil.registerServicesForReplicationToClient(services)
	local networkFolder = servicesNetworkFolder()

	for serviceName, service in services do
		assert(
			service.client == nil or typeof(service.client) == "table",
			string.format(
				SERVICE_CORRUPT_CLIENT_MEMBER_BASE_ERROR_MESSAGE,
				serviceName,
				typeof(service.client)
			)
		)

		if service.client == nil then
			continue
		end

		local serviceNetwork = NetworkServer.new(
			serviceName,
			service.middleware,
			servicesNetworkConfig.serviceNetworkServerConfig
		)

		for key, value in service.client do
			serviceNetwork:append(key, value)
		end

		serviceNetwork:dispatch(networkFolder)
	end

	networkFolder:SetAttribute(sharedEnums.Attribute.Initialized, true)
end

function serviceUtil.service(serviceName: string)
	assert(RunService:IsClient(), CAN_ONLY_RUN_ON_CLIENT_BASE_ERROR_MESSAGE)
	assert(
		replicatedServices[serviceName] ~= nil,
		string.format(SERVICE_NOT_FOUND_BASE_ERROR_MESSAGE, serviceName)
	)

	return replicatedServices[serviceName]
end

function serviceUtil.ensureServicesAreReplicatedAndSetup()
	assert(RunService:IsClient(), CAN_ONLY_RUN_ON_CLIENT_BASE_ERROR_MESSAGE)
	local networkFolder = servicesNetworkFolder()

	instanceAttributeUtil
		.instanceAttributePromise(networkFolder, sharedEnums.Attribute.Initialized)
		:expect()

	replicatedServices = network.client.allFromParent(networkFolder)
end

if RunService:IsServer() then
	local serviceNetworksFolder = Instance.new("Folder")
	serviceNetworksFolder.Name = servicesNetworkConfig.servicesNetworkFolderName
	serviceNetworksFolder.Parent = servicesNetworkConfig.servicesNetworkFolderParent
end

return table.freeze(serviceUtil)
