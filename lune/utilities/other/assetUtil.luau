--# selene: allow(incorrect_standard_library_use)
local tableUtil = require("tableUtil") :: any

local BLACK_LISTED_CHILDREN_FOR_DESTRUCTION = { "StarterPlayerScripts", "StarterCharacterScripts" }

local assetUtil = {}

function assetUtil.destroyBlacklistedAssets(game, assets, optionalAssetData, optionalChild)
	if optionalAssetData then
		for childWithinChildName, otherAssetData in optionalAssetData do
			if typeof(otherAssetData) == "string" then
				if not tableUtil.find(BLACK_LISTED_CHILDREN_FOR_DESTRUCTION, otherAssetData) then
					while optionalChild:FindFirstChild(otherAssetData) do
						optionalChild:FindFirstChild(otherAssetData):Destroy()
					end
				end
			else
				assetUtil.destroyBlacklistedAssets(
					game,
					assets,
					otherAssetData,
					optionalChild[childWithinChildName]
				)
			end
		end

		return
	end

	for serviceName, assetHierarchy in assets do
		local service = game:GetService(serviceName)

		for childName, assetData in assetHierarchy do
			if typeof(assetData) == "string" then
				if not tableUtil.find(BLACK_LISTED_CHILDREN_FOR_DESTRUCTION, assetData) then
					while service:FindFirstChild(assetData) do
						service:FindFirstChild(assetData):Destroy()
					end
				end
			else
				assetUtil.destroyBlacklistedAssets(game, assets, assetData, service[childName])
			end
		end
	end
end

function assetUtil.destroyAllAssetsExceptWhitelisted(game, assets, optionalAssetData, optionalChild)
	if optionalAssetData then
		local optionalChildChildren = optionalChild:GetChildren()

		for _, child in optionalChildChildren do
			local matchFound = false
			local shouldSkip = false

			for assetChildName, assetData in optionalAssetData do
				if typeof(assetData) == "string" then
					matchFound = assetData == child.Name

					if matchFound then
						break
					end
				else
					assetUtil.destroyBlacklistedAssets(
						game,
						assets,
						assetData,
						optionalChild[assetChildName]
					)
					shouldSkip = true
				end
			end

			if
				not matchFound
				and not shouldSkip
				and not tableUtil.find(BLACK_LISTED_CHILDREN_FOR_DESTRUCTION, child.Name)
			then
				child:Destroy()
			end
		end

		return
	end

	for serviceName, assetHierarchy in assets do
		local service = game:GetService(serviceName)
		local serviceChildren = service:GetChildren()

		for _, child in serviceChildren do
			local matchFound = false
			local shouldSkip = false

			for assetChildName, assetData in assetHierarchy do
				if typeof(assetData) == "string" then
					matchFound = assetData == child.Name

					if matchFound then
						break
					end
				else
					assetUtil.destroyAllAssetsExceptWhitelisted(
						game,
						assets,
						assetData,
						service[assetChildName]
					)
					shouldSkip = true
				end
			end

			if
				not matchFound
				and not shouldSkip
				and not tableUtil.find(BLACK_LISTED_CHILDREN_FOR_DESTRUCTION, child.Name)
			then
				child:Destroy()
			end
		end
	end
end

function assetUtil.copyAssetsToPlace(
	inputGame,
	outputGame,
	assets,
	optionalAssetData,
	optionalInputParent,
	optionalOutputParent
)
	if optionalAssetData then
		for childWithinChildName, otherAssetData in optionalAssetData do
			if typeof(otherAssetData) == "string" then
				local asset = optionalInputParent:FindFirstChild(otherAssetData)

				if asset then
					asset.Parent = optionalOutputParent
				end
			else
				assetUtil.copyAssetsToPlace(
					inputGame,
					outputGame,
					assets,
					otherAssetData,
					optionalInputParent[childWithinChildName],
					optionalOutputParent[childWithinChildName]
				)
			end
		end

		return
	end

	for serviceName, assetHierarchy in assets do
		local inputService = inputGame:GetService(serviceName)
		local outputService = outputGame:GetService(serviceName)

		for childName, assetData in assetHierarchy do
			if typeof(assetData) == "string" then
				local asset = inputService:FindFirstChild(assetData)

				if asset then
					asset.Parent = outputService
				end
			else
				assetUtil.copyAssetsToPlace(
					inputGame,
					outputGame,
					assets,
					assetData,
					inputService[childName],
					outputService[childName]
				)
			end
		end
	end
end

return table.freeze(assetUtil)
