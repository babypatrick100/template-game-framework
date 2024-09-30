local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ValueMultiplier = require(ReplicatedStorage.core.sharedPackages.ValueMultiplier)
local instancePropertyUtil = require(ReplicatedStorage.core.sharedPackages.instancePropertyUtil)
local instanceTroveUtil = require(ReplicatedStorage.core.sharedPackages.instanceTroveUtil)
local playerEventsUtil = require(ReplicatedStorage.core.sharedPackages.playerEventsUtil)
local playerHumanoidPropertyValueMultiplierConfig =
	require(ServerStorage.core.server.configurations.playerHumanoidPropertyValueMultiplierConfig)
local playerHumanoidUtil = require(ReplicatedStorage.core.sharedPackages.playerHumanoidUtil)
local schedulerUtil = require(ReplicatedStorage.core.sharedPackages.schedulerUtil)

local BASE_PLAYER_HUMANOID_PROPERTY_VALUE_MULTIPLIER_IDENTIFIER = "Player_%s_Humanoid_%s"
local PLAYER_HUMANOID_PROPERTY_UPDATE_BASED_OFF_OF_VALUE_MULTIPLER_SCHEDULER_CALLBACK_IDENTIFIER =
	"UpdatePlayerHumanoidPropertyValuesBasedOffOfValueMultiplier"

local playerHumanoids = {}

local playerHumanoidValueMultipliersService = {}

local function setupPlayerValueMultipliers(player: Player)
	local playerTrove = instanceTroveUtil.instanceTrove(player)

	for targetHumanoidProperty, playerHumanoidPropertyValueMultiplierData in
		playerHumanoidPropertyValueMultiplierConfig.humanoidPropertyValuesToConsiderForValueMultiplier
	do
		playerTrove:Add(
			ValueMultiplier.new(
				playerHumanoidValueMultipliersService.playerHumanoidPropertyValueMultiplierIdentifier(
					player,
					targetHumanoidProperty
				),
				playerHumanoidPropertyValueMultiplierData.initialValue,
				playerHumanoidPropertyValueMultiplierData.initialBaseValue,
				playerHumanoidPropertyValueMultiplierData.initialMultiplier
			)
		)
	end
end

local function updatePlayerHumanoidValueMultipliers(player: Player, humanoid: Humanoid)
	for targetHumanoidProperty in
		playerHumanoidPropertyValueMultiplierConfig.humanoidPropertyValuesToConsiderForValueMultiplier
	do
		instancePropertyUtil.observeProperty(
			humanoid,
			targetHumanoidProperty,
			function(newValue, oldValue)
				local valueMultiplierForHumanoidProperty = ValueMultiplier.fromIdentifier(
					playerHumanoidValueMultipliersService.playerHumanoidPropertyValueMultiplierIdentifier(
						player,
						targetHumanoidProperty
					)
				)

				-- We need to ensure that the new value is not actually the value
				-- based off of the multiplier, in order to set the correct value as
				-- the base value!
				if oldValue ~= nil then
					if newValue == valueMultiplierForHumanoidProperty:updatedValue() then
						return
					end
				end

				valueMultiplierForHumanoidProperty:setValue(newValue)
				valueMultiplierForHumanoidProperty:setBaseValue(newValue)
			end
		)
	end
end

local function managePlayer(player: Player)
	local playerTrove = instanceTroveUtil.instanceTrove(player)
	setupPlayerValueMultipliers(player)

	playerEventsUtil.usePlayerCharacterAdded(player, function()
		playerHumanoidUtil
			.playerHumanoidPromise(player)
			:andThen(function(humanoid)
				playerHumanoids[player] = humanoid
				updatePlayerHumanoidValueMultipliers(player, humanoid)
			end)
			:catch(function() end)
	end)

	playerTrove:Add(function()
		playerHumanoids[player] = nil
	end)
end

local function updatePlayerHumanoidPropertyValuesBasedOffOfValueMultipliers()
	schedulerUtil.schedule(
		schedulerUtil.RunServiceEvent.Heartbeat,
		PLAYER_HUMANOID_PROPERTY_UPDATE_BASED_OFF_OF_VALUE_MULTIPLER_SCHEDULER_CALLBACK_IDENTIFIER,
		function()
			for player, humanoid in playerHumanoids do
				for targetHumanoidProperty in
					playerHumanoidPropertyValueMultiplierConfig.humanoidPropertyValuesToConsiderForValueMultiplier
				do
					local valueMultiplier = ValueMultiplier.fromIdentifier(
						playerHumanoidValueMultipliersService.playerHumanoidPropertyValueMultiplierIdentifier(
							player,
							targetHumanoidProperty
						)
					)

					if valueMultiplier ~= nil then
						humanoid[targetHumanoidProperty] = valueMultiplier:updatedValue()
					end
				end
			end
		end
	)

	playerEventsUtil.usePlayerAdded(managePlayer)
end

function playerHumanoidValueMultipliersService.start()
	playerEventsUtil.usePlayerAdded(managePlayer)
	updatePlayerHumanoidPropertyValuesBasedOffOfValueMultipliers()
end

function playerHumanoidValueMultipliersService.playerHumanoidPropertyValueMultiplierIdentifier(
	player: Player,
	humanoidProperty: string
)
	return string.format(
		BASE_PLAYER_HUMANOID_PROPERTY_VALUE_MULTIPLIER_IDENTIFIER,
		player.Name,
		humanoidProperty
	)
end

function playerHumanoidValueMultipliersService.resetPlayerHumanoidPropertyValueMultiplier(
	player: Player,
	targetHumanoidProperty: string
)
	local playerHumanoidWalkSpeedValueMultiplier = ValueMultiplier.fromIdentifier(
		playerHumanoidValueMultipliersService.playerHumanoidPropertyValueMultiplierIdentifier(
			player,
			targetHumanoidProperty
		)
	)
	if playerHumanoidWalkSpeedValueMultiplier ~= nil then
		local playerHumanoidPropertyValueMultiplierData =
			playerHumanoidPropertyValueMultiplierConfig.humanoidPropertyValuesToConsiderForValueMultiplier[targetHumanoidProperty]
		playerHumanoidWalkSpeedValueMultiplier:setMultiplier(
			playerHumanoidPropertyValueMultiplierData.initialMultiplier
		)
	end
end

return table.freeze(playerHumanoidValueMultipliersService)
