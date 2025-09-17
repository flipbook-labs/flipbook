local constants = require("./lib/constants")
local run = require("./lib/run")

local globalDefsPath = "globalTypes.d.luau"

run("curl", {
	"-s",
	"-o",
	globalDefsPath,
	"-O",
	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua",
})

run("rojo", {
	"sourcemap",
	constants.ROJO_ANALYSIS_PROJECT,
	"-o",
	constants.SOURCEMAP_PATH,
})

run("luau-lsp", {
	"analyze",
	`--sourcemap={constants.SOURCEMAP_PATH}`,
	`--defs={globalDefsPath}`,
	"--settings=./.vscode/settings.json",
	"--ignore=**/_Index/**",
	constants.SOURCE_PATH,
	constants.LUNE_SCRIPTS_PATH,
	constants.WORKSPACE_PATH,
})
