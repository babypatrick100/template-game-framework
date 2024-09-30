local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedEnums = require(ReplicatedStorage.core.shared.miscellaneous.sharedEnums)

local weatherTags = {
	thunderstorm = sharedEnums.Tag.Thunderstorm,
	cloudy = sharedEnums.Tag.Cloudy,
	windy = sharedEnums.Tag.Windy,
	rain = sharedEnums.Tag.Rain,
	drizzle = sharedEnums.Tag.Drizzle,
}

return table.freeze(weatherTags)
