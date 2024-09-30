local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.core.sharedPackages.Promise)
local Property = require(ReplicatedStorage.core.sharedPackages.Property)
local marketPlaceServiceUtil = require(ReplicatedStorage.core.sharedPackages.marketPlaceServiceUtil)
local playerMonetizationUtil =
	require(ReplicatedStorage.core.shared.utilities.playerMonetizationUtil)
local sharedEnums = require(ReplicatedStorage.core.shared.miscellaneous.sharedEnums)

local monetizationProductsController = {
	developerProductInfos = Property.new(),
	gamepassProductInfos = Property.new(),
	subscriptionProductInfos = Property.new(),
}

local function loadProductInfos(idData, infoType: Enum.InfoType)
	local productInfoPromises = {}
	local productInfos = {}

	local function setupProductInfoForId(id)
		local productInfoPromise = marketPlaceServiceUtil.productInfo(id, infoType)
		table.insert(productInfoPromises, productInfoPromise)

		productInfoPromise:andThen(function(productInfo)
			productInfos[id] = productInfo
		end)
	end

	for _, ids in idData do
		-- `sharedEnms.GamepassId` will be a dictionary of gamepass keywords mapped to a dictionary
		-- of ids.
		if idData == sharedEnums.GamepassId then
			for _, id in playerMonetizationUtil.gamepassIdsFromGamepassIdData(ids) do
				setupProductInfoForId(id)
			end
		else
			setupProductInfoForId(ids)
		end
	end

	return Promise.new(function(resolve)
		Promise.allSettled(productInfoPromises):await()
		resolve(productInfos)
	end)
end

local function loadSubscriptionProductInfos()
	local subscriptionProductInfoPromises = {}
	local subscriptionProductInfos = {}

	for _, subscriptionId in sharedEnums.SubscriptionId do
		local subscriptionProductInfoPromise =
			marketPlaceServiceUtil.subscriptionInfoProductAsync(subscriptionId)
		table.insert(subscriptionProductInfoPromises, subscriptionProductInfoPromise)

		subscriptionProductInfoPromise:andThen(function(subscriptionProductInfo)
			subscriptionProductInfos[subscriptionId] = subscriptionProductInfo
		end)
	end

	return Promise.new(function(resolve)
		Promise.allSettled(subscriptionProductInfoPromises):await()
		resolve(subscriptionProductInfos)
	end)
end

function monetizationProductsController.start()
	loadProductInfos(sharedEnums.DeveloperProductId, Enum.InfoType.Product):andThen(
		function(developerProductInfos)
			monetizationProductsController.developerProductInfos:set(developerProductInfos)
		end
	)

	loadProductInfos(sharedEnums.GamepassId, Enum.InfoType.GamePass):andThen(
		function(gamepassProductInfos)
			monetizationProductsController.gamepassProductInfos:set(gamepassProductInfos)
		end
	)

	-- Subscription product infos can only be retrieved on the client.
	-- https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#GetSubscriptionProductInfoAsync
	if RunService:IsClient() then
		loadSubscriptionProductInfos():andThen(function(subscriptionProductInfos)
			monetizationProductsController.subscriptionProductInfos:set(subscriptionProductInfos)
		end)
	end
end

return table.freeze(monetizationProductsController)
