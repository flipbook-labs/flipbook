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

local target = if args.target then args.target else "roblox"
assert(
	target == "roblox" or target == "rotriever",
	`bad value for target (must be one of "roblox" or "rotriever", got "{target}")`
)

local output = if args.output then args.output else `{roblox.studioPluginPath()}/{project.PLUGIN_FILENAME}`
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local function build()
	local startTime = os.clock()

	compile(channel, target)

	local dest = `{project.BUILD_PATH}/{project.PLUGIN_FILENAME}`
	run("rojo", { "build", "-o", dest })
	run("cp", { dest, output })

	print(`build completed in {("%.2f"):format(os.clock() - startTime)}s`)
end

build()

if args.watch then
	watch({
		filePatterns = {
			"src/.*%.luau",
			"workspace/.*%.luau",
		},
		excludedFilePatterns = {
			".*Packages",
			"build",
		},
		onChanged = build,
	})
end
