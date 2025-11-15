local project = require("@repo/project")

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
	project.ROJO_BUILD_PROJECT,
	"-o",
	project.SOURCEMAP_PATH,
})

local defaultArgs = {
	"analyze",
	`--defs={globalDefsPath}`,
	"--settings=./.vscode/settings.json",
	`--ignore="**/_Index/**"`,
	`--ignore="**/RobloxPackages/**"`,
	`--ignore="**/LuauPackages/**"`,
}

do
	local args = table.clone(defaultArgs)
	table.insert(args, "--platform=standard")
	table.insert(args, "--flag:LuauSolverV2=true")
	table.insert(args, project.SCRIPTS_PATH)

	run("luau-lsp", args)
end

do
	local args = table.clone(defaultArgs)
	table.insert(args, `--sourcemap={project.SOURCEMAP_PATH}`)
	table.insert(args, project.SOURCE_PATH)
	table.insert(args, project.WORKSPACE_PATH)

	run("luau-lsp", args)
end
