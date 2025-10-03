local process = require("@lune/process")
local project = require("@repo/project")
local roblox = require("@lune/roblox")

local compile = require("./lib/compile")
local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")
local watch = require("./lib/watcher/watch")

local args = parseArgs(process.args)

local channel = if args.channel then args.channel else "prod"
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local output = if args.output then args.output else `{roblox.studioPluginPath()}/{project.PLUGIN_FILENAME}`
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local function build()
	compile(channel)

	local dest = `{project.BUILD_PATH}/{project.PLUGIN_FILENAME}`
	run("rojo", { "build", "-o", dest })
	run("cp", { dest, output })
end

build()

if args.watch then
	watch({
		filePatterns = {
			"src/.*%.luau",
			"workspace/.*%.luau",
		},
		onChanged = build,
	})
end
