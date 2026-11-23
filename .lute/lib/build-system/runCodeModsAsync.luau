local CodeQuality = require("@lpm/code-quality@v0.8.0")
local json = require("@std/json")
local path = require("@std/path")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

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

--[[
	The build copies Luau source into its output folder, then runs CodeQuality's
	build over the copies to turn them into code Roblox can run. It converts
	string requires such as `require("@pkg/React")` into instance requires such
	as `require(script.Parent.Packages.React)`, looking each file up in the
	sourcemap `compileAsync` writes. A require it can't resolve stops the build.
	It then replaces reads of the globals in `project.BUILD_GLOBALS`, such as
	`_G.BUILD_CHANNEL`, with their values, and removes the code those values
	make unreachable, such as a dev-only branch in a prod build.
]]
local function runCodeModsAsync(options: Options)
	local paths: { string } = {}
	for _, target in options.paths do
		table.insert(paths, path.format(target))
	end

	--[[
		The build sets most globals' values in `context.env`. A global missing
		from there is read from the environment variable of the same name, which
		`{"env": "NAME"}` asks for. One that isn't set there either becomes
		`nil`, with a warning.
	]]
	local globals: { [string]: json.Value } = {}
	for _, name in project.BUILD_GLOBALS do
		local value = options.context.env[name]
		globals[name] = if value ~= nil then value else { env = name }
	end

	CodeQuality.build({
		sourceFolder = path.format(options.sourceFolder),
		buildFolder = path.format(options.buildFolder),
		paths = paths,
		sourcemap = path.format(project.BUILD_SOURCEMAP_PATH),
		globals = globals,
	})
end

return runCodeModsAsync
