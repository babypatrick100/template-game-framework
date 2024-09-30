--# selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")

local CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH = "dev/remoteGameDevConfig.luau"
local CUSTOM_CONFIG_MODULE_RELATIVE_PATH = "../dev/remoteGameDevConfig.luau"
local CONFIG_TEMPLATE = {
	buildInfoScriptInfo = {
		name = "buildInfo",
		parents = {},
		shouldSetup = true,
	},

	localProjectFileDir = "",
	localProjectAssetsDir = "",
	remoteUniverseId = "",
	remotePlaceId = "",
	cloudApiPublishingKey = "",

	scriptAssets = {},
	services = {},
}

if not fs.isFile(CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH) then
	error(
		string.format(
			'❌ Custom config module ["%s"] is not a valid file or does not exist!',
			CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH
		)
	)
end

local projectSpecificConfig = require(CUSTOM_CONFIG_MODULE_RELATIVE_PATH)
if typeof(projectSpecificConfig) ~= "table" then
	error(
		string.format(
			'❌ Invalid config module return value ["%s"]. Expected type "table", but got "%s" instead.',
			CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH,
			typeof(projectSpecificConfig)
		)
	)
end

for key in CONFIG_TEMPLATE do
	if projectSpecificConfig[key] == nil then
		print(
			string.format(
				'[config.luau]:⚠️ Missing member "%s"; please specify it in config module ["%s"]!',
				key,
				CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH
			)
		)
	end
end

for key in projectSpecificConfig do
	if CONFIG_TEMPLATE[key] == nil then
		print(
			string.format(
				'[config.luau]:⚠️  Unknown member "%s" was found in config module ["%s"] - are you sure this is a valid member?',
				key,
				CUSTOM_CONFIG_MODULE_ABSOLUTE_PATH
			)
		)
	end
end

return projectSpecificConfig
