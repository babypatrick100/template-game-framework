--!nolint
--!nocheck
--# selene: allow(incorrect_standard_library_use)
local net = require("@lune/net")
local roblox = require("@lune/roblox")

local ROBLOX_PLACE_ASSET_DELIEVERY_URL = "https://apis.roblox.com/universes/v1/%d/places/%d/versions"

local function writeToRemotePlace(place, remotePlaceId, universeId, apiKey)
	local assetApiResponse = net.request({
		url = string.format(ROBLOX_PLACE_ASSET_DELIEVERY_URL, universeId, remotePlaceId),
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/octet-stream",
		},
		query = {
			versionType = "Published",
		},
		method = "POST",
		body = roblox.serializePlace(place),
	})

	return assetApiResponse
end

return writeToRemotePlace
