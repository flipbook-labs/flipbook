local project = require("@repo/project")

local run = require("./lib/run")

local globalDefsPath = `{project.BUILD_PATH}/globalTypes.d.luau`

run("curl", {
	"-s",
	"-o",
	globalDefsPath,
	"-O",
	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua",
})

run("rojo", {
	"sourcemap",
	project.ROJO_ANALYSIS_PROJECT,
	"-o",
	project.SOURCEMAP_PATH,
})

run("luau-lsp", {
	"analyze",
	`--sourcemap={project.SOURCEMAP_PATH}`,
	`--defs={globalDefsPath}`,
	"--settings=./.vscode/settings.json",
	"--ignore=**/_Index/** --ignore=**/RobloxPackages/**",
	project.SOURCE_PATH,
	project.LUNE_SCRIPTS_PATH,
	project.WORKSPACE_PATH,
})
