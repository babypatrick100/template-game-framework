--!nolint
--!nocheck
--# selene: allow(incorrect_standard_library_use)
local assetUtil = require("../other/assetUtil")
local config = require("../../config")
local fs = require("@lune/fs")
local readRemotePlace = require("readRemotePlace")
local roblox = require("@lune/roblox")
local tableUtil = require("../other/tableUtil")

local BLACKLISTED_ASSETS = tableUtil.merge(
	-- Don't sync in code since developers will sync in their code through
	-- Rojo..
	config.scriptAssets,
	{
		-- For some reason duplicates of camera instances are created during build,
		-- which is not what we want.
		Workspace = { "Camera" },
	}
)

local function buildPlace(remotePlaceId)
	if fs.isDir(config.localProjectAssetsDir) then
		fs.removeDir(config.localProjectAssetsDir)
	end

	fs.writeDir(config.localProjectAssetsDir)

	local remotePlaceSuccessfullyRead, remotePlace = readRemotePlace(remotePlaceId)
	if not remotePlaceSuccessfullyRead then
		return remotePlaceSuccessfullyRead, remotePlace
	end

	assetUtil.destroyBlacklistedAssets(remotePlace, BLACKLISTED_ASSETS)

	for _, directory in config.services do
		local desiredPath = string.format("%s/%s.rbxm", config.localProjectAssetsDir, directory)
		local serializedModel = roblox.serializeModel({ remotePlace:GetService(directory) })
		fs.writeFile(desiredPath, serializedModel)
	end

	return true, nil
end

return buildPlace
