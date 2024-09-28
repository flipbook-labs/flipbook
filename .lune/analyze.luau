local process = require("@lune/process")

local constants = require("./lib/constants")
local rmrf = require("./lib/rmrf")
local run = require("./lib/run")

local GLOBAL_DEFS_PATH = "globalTypes.d.luau"
local GLOBAL_DEFS_URL = "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua"

run("curl", { "-s", "-o", GLOBAL_DEFS_PATH, "-O", GLOBAL_DEFS_URL })

run("rojo", {
	"sourcemap",
	constants.ROJO_ANALYSIS_PROJECT,
	"-o",
	constants.SOURCEMAP_PATH,
})

local success = pcall(function()
	return run("luau-lsp", {
		"analyze",
		`--sourcemap={constants.SOURCEMAP_PATH}`,
		`--defs={GLOBAL_DEFS_PATH}`,
		"--settings=./.vscode/settings.json",
		"--ignore=**/_Index/**",
		constants.SOURCE_PATH,
		constants.LUNE_SCRIPTS_PATH,
		constants.EXAMPLE_PATH,
	})
end)

rmrf(GLOBAL_DEFS_PATH)
rmrf(constants.SOURCEMAP_PATH)

if not success then
	process.exit(1)
end
