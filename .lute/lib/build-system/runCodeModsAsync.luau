local CodeQuality = require("@lpm/code-quality@v0.5.0")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local json = require("@std/json")
local path = require("@std/path")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local run = FlipbookBatteries.run

export type Options = {
	-- The folder the copied files came from. The Rojo sourcemap names files
	-- there, not in `buildFolder`.
	sourceFolder: path.Pathlike,
	-- The folder holding the copies.
	buildFolder: path.Pathlike,
	-- The files and folders inside `buildFolder` to rewrite.
	paths: { path.Path },
	context: types.BuildContext,
}

-- The build copies Luau source into its output folder, then runs CodeQuality's
-- code mods over the copies to turn them into code Roblox can run. Each mod
-- runs once under `lute transform`, which rewrites the files in place:
--
-- 1. `convertRequire` turns string requires such as `require("@pkg/React")`
--    into instance requires such as `require(script.Parent.Packages.React)`.
--    It resolves each require through the nearest `.config.luau` or `.luaurc`
--    and looks the file up in the sourcemap `compileAsync` writes. A require
--    it can't resolve stops the build.
-- 2. `injectGlobalValue` replaces reads of the globals in
--    `project.BUILD_GLOBALS`, such as `_G.BUILD_CHANNEL`, with their values
--    from the build's environment. A global with no value there becomes `nil`,
--    and the mod prints a warning.
-- 3. The rest fold the expressions those values make constant and remove the
--    code that can never run, such as a dev-only branch in a prod build.
--
-- The mods go in the order CodeQuality's README lists, since a later mod
-- cleans up what an earlier one leaves behind:
-- https://github.com/flipbook-labs/code-quality#building-without-darklua
local function runCodeModsAsync(options: Options)
	local targets: { string } = {}
	for _, target in options.paths do
		table.insert(targets, path.format(target))
	end
	local targetList = table.concat(targets, " ")

	local function transform(mod: string, ...: string)
		run("lute", {
			"transform",
			path.format(path.join(CodeQuality.MODS_PATH, `{mod}.luau`)),
			targetList,
			"--",
			...,
		}, {
			env = options.context.env,
		})
	end

	-- `{"env": "NAME"}` tells `injectGlobalValue` to read the value from the
	-- environment variable of that name.
	local globals: json.Object = {}
	for _, name in project.BUILD_GLOBALS do
		globals[name] = {
			env = name,
		}
	end

	transform(
		"convertRequire",
		"--sourcemap",
		path.format(project.BUILD_SOURCEMAP_PATH),
		"--sourceFolder",
		path.format(options.sourceFolder),
		"--buildFolder",
		path.format(options.buildFolder)
	)
	-- `run` passes the command through a shell, so the JSON is quoted to
	-- keep its braces and quotes intact.
	transform("injectGlobalValue", "--globals", `'{json.serialize(globals)}'`)
	transform("computeExpression")
	transform("removeUnusedIfBranch")
	transform("removeUnusedWhile")
	transform("filterAfterEarlyReturn")
	transform("removeNilDeclaration")
	transform("removeEmptyDo")
end

return runCodeModsAsync
