local clean = require("./lib/clean")
local compile = require("./lib/compile")
local constants = require("./lib/constants")
local getPluginsPath = require("./lib/getPluginsPath")
local parseArgs = require("./lib/parseArgs")
local process = require("@lune/process")
local run = require("./lib/run")
local watch = require("./lib/watcher/watch")

local args = parseArgs(process.args)

local target = if args.target then args.target else "prod"
assert(target == "dev" or target == "prod", `bad value for target (must be one of "dev" or "prod", got "{target}")`)

local output = if args.output then args.output else `{getPluginsPath(process.os)}/{constants.PLUGIN_FILENAME}`
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local PRUNED_FILES = {
	"*.spec.luau",
	"*.story.luau",
	"*.storybook.luau",
}

local function build()
	clean()
	compile(target)

	if target == "prod" then
		for _, pattern in PRUNED_FILES do
			run("find", { constants.BUILD_PATH, "-type", "f", "-name", pattern, "-delete" })
		end
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
