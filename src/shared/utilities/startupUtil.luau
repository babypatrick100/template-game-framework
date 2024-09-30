local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Loader = require(ReplicatedStorage.core.sharedPackages.Loader)
local debugLoggerUtil = require(ReplicatedStorage.core.sharedPackages.debugLoggerUtil)
local serviceUtil = require(ReplicatedStorage.core.shared.utilities.serviceUtil)

local STARTUP_METHOD = "start"
local HEADER_LOG_REP = 85
local VERBOSE_LOGGING_ENABLED = true
local SERVICE_OR_CONTROLLER_STARTUP_BASE_LOG_MESSAGE = '✔ %s "%s" started in %.2fs.'
local BOOTSTRAPPER_STARTUP_BASE_LOG_MESSAGE = '✔ %sBootstrapper "%s" started in %.2fs.'
local BOOTSTRAPPER_NOT_YET_FINISHED_RUNNING_BASE_ERROR_MESSAGE =
	'%sBootstrapper "%s" has not yet finished starting up as it has very likely yielded - this is not allowed!'
local SERVICE_OR_CONTROLLER_NOT_YET_FINISHED_RUNNING_BASE_ERROR_MESSAGE =
	'%s "%s" has not yet finished starting up as it has very likely yielded - this is not allowed!'

local startupUtil = {}

local function logHeader()
	debugLoggerUtil.log(print, string.format("<%s>", string.rep("-", HEADER_LOG_REP)))
end

local function bootstrapperLocationHouser(holder: Folder): string
	if holder:IsDescendantOf(ReplicatedStorage.core.shared) then
		return "Shared "
	end

	return if RunService:IsServer() then "Server " else "Client "
end

local function startupBootstrappers(
	bootstrapperHolders,
	startupBaseLogMessage: string,
	notYetFinishedRunningBaseErrorMessage: string
): number
	local startupCount = 0

	for _, bootstrapperHolder in bootstrapperHolders do
		local loadedBootstrappers = Loader.LoadDescendants(bootstrapperHolder)

		for loadedHolderName, loadedBootstrapperOrGameState in loadedBootstrappers do
			local startupThread = task.spawn(function()
				debug.setmemorycategory(loadedHolderName)

				local clockBefore = os.clock()
				if typeof(loadedBootstrapperOrGameState) == "function" then
					loadedBootstrapperOrGameState()
				else
					loadedBootstrapperOrGameState[STARTUP_METHOD]()
				end

				startupCount += 1
				debugLoggerUtil.log(
					print,
					string.format(
						startupBaseLogMessage,
						bootstrapperLocationHouser(bootstrapperHolder),
						loadedHolderName,
						os.clock() - clockBefore
					)
				)
			end)

			assert(
				coroutine.status(startupThread) == "dead",
				string.format(
					notYetFinishedRunningBaseErrorMessage,
					bootstrapperLocationHouser(bootstrapperHolder),
					loadedHolderName
				)
			)
		end

		logHeader()
	end

	return startupCount
end

local function startupServicesOrControllers(loadedServicesOrControllers)
	local serviceOrControllerTag = if RunService:IsServer() then "Service" else "Controller"

	for loadedServicesOrControllerName, loadedServicesOrController in loadedServicesOrControllers do
		if loadedServicesOrController[STARTUP_METHOD] ~= nil then
			local startupThread = task.spawn(function()
				debug.setmemorycategory(STARTUP_METHOD)
				local clockBefore = os.clock()
				loadedServicesOrController[STARTUP_METHOD]()
				debugLoggerUtil.log(
					print,
					string.format(
						SERVICE_OR_CONTROLLER_STARTUP_BASE_LOG_MESSAGE,
						serviceOrControllerTag,
						loadedServicesOrControllerName,
						os.clock() - clockBefore
					)
				)
			end)

			assert(
				coroutine.status(startupThread) == "dead",
				string.format(
					SERVICE_OR_CONTROLLER_NOT_YET_FINISHED_RUNNING_BASE_ERROR_MESSAGE,
					serviceOrControllerTag,
					loadedServicesOrControllerName
				)
			)
		end
	end
end

--[=[ 
    Starts up all services/controllers, components and bootstrapers.

    ```lua
    startupUtil.startup("start", {
        path = ServerStorage.services,
        nameFormat = "Service$",
    },  ServerStorage.core.server.components, {script.bootstrapers})
    ```
]=]

function startupUtil.startup(startupData: {
	bootstrapperHolders: { Instance },
	componentHolders: { Instance },
	controllers: { paths: { Instance }, nameFormat: string },
	services: { paths: { Instance }, nameFormat: string }?,
})
	if RunService:IsClient() then
		serviceUtil.ensureServicesAreReplicatedAndSetup()
	end

	local services = startupData.services
	local componentHolders = startupData.componentHolders
	local controllers = startupData.controllers
	local bootstrapperHolders = startupData.bootstrapperHolders

	if services ~= nil then
		for _, servicePath in services.paths do
			local loadedServices =
				Loader.LoadDescendants(servicePath, Loader.MatchesName(services.nameFormat))
			if next(loadedServices) ~= nil then
				logHeader()
			end

			serviceUtil.registerServicesForReplicationToClient(loadedServices)
			startupServicesOrControllers(loadedServices)
			if next(loadedServices) ~= nil then
				logHeader()
			end
		end
	end

	for _, controllerPath in controllers.paths do
		local loadedControllers =
			Loader.LoadDescendants(controllerPath, Loader.MatchesName(controllers.nameFormat))

		if next(loadedControllers) ~= nil then
			logHeader()
		end

		startupServicesOrControllers(loadedControllers)

		if next(loadedControllers) ~= nil then
			logHeader()
		end
	end

	-- We defer the startup of bootstrappers and game states in order to ensure that
	-- all services / controllers have started - we make the assumption here that all
	-- services & controllers never yield during startup!
	task.defer(function()
		local bootstrappersStartupCount = startupBootstrappers(
			bootstrapperHolders,
			BOOTSTRAPPER_STARTUP_BASE_LOG_MESSAGE,
			BOOTSTRAPPER_NOT_YET_FINISHED_RUNNING_BASE_ERROR_MESSAGE
		)

		if bootstrappersStartupCount > 0 then
			logHeader()
		end

		for _, componentsHolder in componentHolders do
			Loader.LoadDescendants(componentsHolder)
		end
	end)
end

debugLoggerUtil.toggleLoggingEnabled(VERBOSE_LOGGING_ENABLED)

return table.freeze(startupUtil)
