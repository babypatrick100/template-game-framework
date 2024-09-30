--!nocheck
--!nolint
--# selene: allow(incorrect_standard_library_use)
local buildPlace = require("./utilities/remotePlace/buildPlace")
local config = require("config")
local processUtil = require("./utilities/other/processUtil")

print(
	string.format(
		'[build.luau]: Building local place file "%s" from remote place [%d]..',
		config.localProjectFileDir,
		config.remotePlaceId
	)
)

local clockBefore = os.clock()
local wasSuccessful, response = buildPlace(config.remotePlaceId)
if not wasSuccessful then
	print(
		string.format(
			'[build.luau]: ❌ Failed to build local place file "%s" from remote place [%d]. Error: \n\t %s',
			config.remotePlaceId,
			response
		)
	)
	return
end

processUtil.spawn("rojo", { "build", "build.project.json", "--output", config.localProjectFileDir })
print(
	string.format(
		'[build.luau]: ✅ Successfully built "%s" from remote place [%d]! (%.2fs)',
		config.localProjectFileDir,
		config.remotePlaceId,
		os.clock() - clockBefore
	)
)
