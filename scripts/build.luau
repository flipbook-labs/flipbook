local cli = require("@batteries/cli")
local process = require("@lute/process")
local project = require("@repo/project")

local compile = require("./lib/compile")
local dotenv = require("./lib/dotenv")
local getStudioPluginsPath = require("./lib/getStudioPluginsPath")
local run = require("./lib/run")
local watch = require("./lib/watch")

dotenv()

local args = cli.parser()

args:add("channel", "option", {
	help = "Channel to build for",
	aliases = { "c" },
	default = "prod",
})
args:add("target", "option", {
	help = "Target to build for",
	aliases = { "t" },
	default = "roblox",
})
args:add("output", "option", {
	help = "Full path to the rbxm file to build",
	aliases = { "o" },
	default = `{getStudioPluginsPath()}/{project.PLUGIN_FILENAME}`,
})
args:add("watch", "flag", {
	help = "Watch for changes and recompile automatically",
	aliases = { "w" },
})
args:add("no-reload", "flag", {
	help = "Prevents the plugin from being built to Roblox Studio, disabling reloading",
})

args:parse({ ... })

local channel = args:get("channel")
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local target = args:get("target")
assert(
	target == "roblox" or target == "rotriever",
	`bad value for target (must be one of "roblox" or "rotriever", got "{target}")`
)

local output = args:get("output")
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local function build()
	local startTime = os.clock()

	compile(channel, target)

	local dest = `{project.BUILD_PATH}/{project.PLUGIN_FILENAME}`
	run("rojo", { "build", "-o", dest })

	if not args:has("no-reload") then
		run("cp", { dest, output })
	end

	print(`build completed in {("%.2f"):format(os.clock() - startTime)}s`)
end

build()

if args:has("watch") then
	watch({
		roots = {
			`{process.cwd()}/src`,
			`{process.cwd()}/workspace`,
		},
		excludedFilePatterns = {
			".*Packages",
			"build",
		},
		onChanged = build,
	})
end
