--# selene: allow(incorrect_standard_library_use)
local BUILD_INFO_SCRIPT_NAME = "buildInfo"

local remoteGameDevConfig = {
	buildInfoScriptInfo = {
		name = BUILD_INFO_SCRIPT_NAME,
		parents = {
			ServerScriptService = "Script",
			ReplicatedFirst = "LocalScript",
		},
		shouldSetup = true,
	},

	localProjectFileDir = "basegameV1.rbxl",
	localProjectAssetsDir = "project",
	remoteUniverseId = 0,
	remotePlaceId = 0,
	cloudApiPublishingKey = "",

	scriptAssets = {
		ServerScriptService = { "earlyStartup", BUILD_INFO_SCRIPT_NAME },
		ServerStorage = { "server", "serverPackages" },
		ReplicatedStorage = { "shared", "client", "sharedPackages" },
		StarterPlayer = { StarterPlayerScripts = { "lateStartup", "packetprofiler" } },
		ReplicatedFirst = { "client", BUILD_INFO_SCRIPT_NAME },
	},

	services = {
		"ServerStorage",
		"ReplicatedFirst",
		"ReplicatedStorage",
		"ServerScriptService",
		"Workspace",
		"StarterPack",
		"StarterPlayer",
		"Lighting",
		"TextChatService",
		"Teams",
		"StarterGui",
		"SoundService",
		"Players",
		"MaterialService",
		"Chat",
	},
}

return table.freeze(remoteGameDevConfig)
