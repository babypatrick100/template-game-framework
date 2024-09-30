--!nocheck
--!nolint
--# selene: allow(incorrect_standard_library_use)
local assetUtil = require("../other/assetUtil")
local config = require("../../config")
local enums = require("../../enums")
local fs = require("@lune/fs")
local readRemotePlace = require("readRemotePlace")
local roblox = require("@lune/roblox")
local setupBuildInfoScript = require("setupBuildInfoScript")
local tableUtil = require("../other/tableUtil")
local writeToRemotePlace = require("writeToRemotePlace")

local BLACKLISTED_SERVICES_CHILDREN = {
	Workspace = { "Camera" },
}

local function scriptIsKnown(service, script)
	if not config.scriptAssets[service.Name] then
		return false
	end

	if
		tableUtil.size(config.scriptAssets[service.Name]) == 1
		and typeof(config.scriptAssets[service.Name][1]) == "string"
	then
		return script.Name == config.scriptAssets[service.Name][1]
	end

	for key, folderData in config.scriptAssets[service.Name] do
		local dir = service

		if typeof(folderData) == "table" then
			dir = dir[key]

			if #folderData == 1 then
				if script.Name == folderData[1] then
					return true
				else
					continue
				end
			end
		end

		if script:IsDescendantOf(dir) then
			return true
		end
	end

	return false
end

local function publishRemotePlace(publishType)
	local localPlace = roblox.deserializePlace(fs.readFile(config.localProjectFileDir))
	if localPlace == nil then
		return false, string.format('Local place "%s" was not found!', config.localProjectFileDir)
	end

	local remotePlaceSuccessfullyRead, updatedRemotePlace = readRemotePlace(config.remotePlaceId)
	if not remotePlaceSuccessfullyRead then
		return remotePlaceSuccessfullyRead, updatedRemotePlace
	end

	for service in config.scriptAssets do
		local localService = localPlace:GetService(service)

		for _, child in localService:GetDescendants() do
			if child:IsA("Script") and not scriptIsKnown(localService, child) then
				print(string.format("    ⚠️ Found unknown script [%s], ignoring it.", child:GetFullName()))

				child:Destroy()
			end
		end
	end

	if publishType == enums.PublishType.EntireLocalPlace then
		for _, service in config.services do
			local localService = localPlace:GetService(service)

			for _, child in localService:GetChildren() do
				if
					BLACKLISTED_SERVICES_CHILDREN[service]
					and tableUtil.find(BLACKLISTED_SERVICES_CHILDREN[service], child.Name)
				then
					child:Destroy()
				end
			end

			updatedRemotePlace:GetService(service):Destroy()
			localService.Parent = updatedRemotePlace
		end
	else
		assetUtil.destroyBlacklistedAssets(updatedRemotePlace, config.scriptAssets)
		assetUtil.copyAssetsToPlace(localPlace, updatedRemotePlace, config.scriptAssets)
	end

	if config.buildInfoScriptInfo.shouldSetup then
		setupBuildInfoScript(updatedRemotePlace)
	end

	local assetApiResponse = writeToRemotePlace(
		updatedRemotePlace,
		config.remotePlaceId,
		config.remoteUniverseId,
		config.cloudApiPublishingKey
	)

	if assetApiResponse.ok then
		return true, nil
	else
		return false, assetApiResponse.statusMessage
	end
end

return publishRemotePlace
