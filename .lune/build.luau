local cli = require("@batteries/cli")
local project = require("@repo/project")

local compile = require("./lib/compile")
local getStudioPluginsPath = require("./lib/getStudioPluginsPath")
local run = require("./lib/run")
local watch = require("./lib/watcher/watch")

local args = cli.parser()

args:add("channel", "flag", {
	help = "Input file",
	aliases = { "c" },
	default = "prod",
})
args:add("target", "flag", {
	help = "Output file",
	aliases = { "t" },
	default = "roblox",
})
args:add("output", "flag", {
	help = "Folder to output to",
	aliases = { "o" },
	default = `{getStudioPluginsPath()}/{project.PLUGIN_FILENAME}`,
})
args:add("watch", "flag", {
	help = "Watch for changes and recompile automatically",
	aliases = { "w" },
	default = false,
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
	compile(channel, target)

	local dest = `{project.BUILD_PATH}/{project.PLUGIN_FILENAME}`
	run("rojo", { "build", "-o", dest })
	run("cp", { dest, output })
end

build()

if args:get("watch") then
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
