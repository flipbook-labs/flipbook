local fs = require("@lune/fs")
local process = require("@lune/process")

local clean = require("./lib/clean")
local compile = require("./lib/compile")
local constants = require("./lib/constants")
local getPluginsPath = require("./lib/getPluginsPath")
local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")
local watch = require("./lib/watcher/watch")

local args = parseArgs(process.args)

local target = if args.target then args.target else "prod"
assert(target == "dev" or target == "prod", `bad value for target (must be one of "dev" or "prod", got "{target}")`)

local output = if args.output then args.output else `{getPluginsPath(process.os)}/{constants.PLUGIN_FILENAME}`
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local gameEnginePath = args.gameEnginePath
assert(
	not gameEnginePath or typeof(gameEnginePath) == "string",
	`bad value for gameEnginePath (string expected, got {typeof(output)}`
)

local PRUNED_FILES = {
	"*.spec.luau",
	"*.story.luau",
	"*.storybook.luau",
}

local function build()
	if not fs.isDir("Packages") then
		run("lune", { "run", "wally-install" })
	end

	clean()
	compile(target)

	if target == "prod" then
		for _, pattern in PRUNED_FILES do
			run("find", { constants.BUILD_PATH, "-type", "f", "-name", pattern, "-delete" })
		end
	end

	if gameEnginePath then
		local engineBuildPath = run("find", { `{gameEnginePath}/build`, "-name", "optimized" })
		assert(fs.isDir(engineBuildPath), `failed to find optimized engine build under {gameEnginePath}`)

		local builtInPlugins = run("find", { engineBuildPath, "-name", "BuiltInPlugins", "-print", "-quit" })
		assert(fs.isDir(builtInPlugins), `failed to find built-in plugins under {engineBuildPath}`)

		output = `{builtInPlugins}/Optimized_Embedded_Signature/{constants.PLUGIN_FILENAME}`
	end

	run("rojo", { "build", "-o", output })
end

build()

if args.watch then
	watch({
		filePatterns = {
			"src/.*%.luau",
			"example/.*%.luau",
		},
		onChanged = build,
	})
end
