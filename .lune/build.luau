local process = require("@lune/process")
local roblox = require("@lune/roblox")

local compile = require("./lib/compile")
local constants = require("./lib/constants")
local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")
local watch = require("./lib/watcher/watch")

local args = parseArgs(process.args)

local target = if args.target then args.target else "prod"
assert(target == "dev" or target == "prod", `bad value for target (must be one of "dev" or "prod", got "{target}")`)

local output = if args.output then args.output else `{roblox.studioPluginPath()}/{constants.PLUGIN_FILENAME}`
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local function build()
	compile(target)

	local dest = `{constants.BUILD_PATH}/{constants.PLUGIN_FILENAME}`
	run("rojo", { "build", "-o", dest })
	run("cp", { dest, output })
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
