--!nocheck
--!nolint
--# selene: allow(incorrect_standard_library_use)
local processUtil = require("./utilities/other/processUtil")
local wallyInstall = require("./utilities/other/wallyInstall")

local PACKAGES_DIRS = { "Packages", "ServerPackages" }

local clockBefore = os.clock()

print("[update.luau]: Installing wally packages..")
wallyInstall()
print("[update.luau]: Generating new Rojo sourcemap..")
processUtil.spawn("rojo", { "sourcemap", "--output", "sourcemap.json" })

print(
	string.format(
		"[update.luau]: Running `wally-package-types` on package directories: [%s]..",
		table.concat(PACKAGES_DIRS, ", ")
	)
)
for _, dir in PACKAGES_DIRS do
	processUtil.spawn("wally-package-types", { "--sourcemap", "sourcemap.json", string.format("%s/", dir) })
end

print(string.format("[update.luau]: ✅ Project successfully updated! (%.2fs)", os.clock() - clockBefore))
