--!nocheck
--!nolint
--# selene: allow(incorrect_standard_library_use)
local config = require("config")
local enums = require("enums")
local process = require("@lune/process")
local publishRemotePlace = require("./utilities/remotePlace/publishRemotePlace")
local stdio = require("@lune/stdio")

local PUBLISH_LOCAL_PLACE_SERVICES_ARG = "entire"

local args = process.args
local publishType = nil

if args[1] ~= nil and args[1]:lower() == PUBLISH_LOCAL_PLACE_SERVICES_ARG then
	local confirmed = stdio.prompt(
		"confirm",
		string.format(
			'[publish.luau]: ⚠️  This will sync in your entire local file "%s" to the actual remote place [%d], are you sure you want to do this?',
			config.localProjectFileDir,
			config.remotePlaceId
		)
	)

	if not confirmed then
		return
	end

	publishType = enums.PublishType.EntireLocalPlace
end

if publishType == enums.PublishType.EntireLocalPlace then
	print(string.format("[publish.luau]: Publishing entire local place to remote place [%d]..", config.remotePlaceId))
else
	print(string.format("[publish.luau]: Publishing local place codebase to remote place [%d]..", config.remotePlaceId))
end

local clockBefore = os.clock()
local successfullyPublishedRemotePlace, response = publishRemotePlace(publishType)

if successfullyPublishedRemotePlace then
	local clockDelta = os.clock() - clockBefore
	if publishType == enums.PublishType.EntireLocalPlace then
		print(
			string.format(
				"[publish.luau]: ✅ Successfully published entire local place to remote place [%d]! (%.2fs)",
				config.remotePlaceId,
				clockDelta
			)
		)
	else
		print(
			string.format(
				"[publish.luau]: ✅ Successfully published local place codebase to remote place [%d]! (%.2fs)",
				config.remotePlaceId,
				clockDelta
			)
		)
	end
else
	print(
		string.format(
			"[publish.luau]: ❌ Failed to publish changes to remote place [%d]. Error: \n\t %s",
			config.remotePlaceId,
			response
		)
	)
end
