local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local fs = require("@lute/fs")
local pp = require("@luaupkg/batteries/pp")
local process = require("@lute/process")
local richterm = require("@luaupkg/batteries/richterm")
local toml = require("@luaupkg/batteries/toml")

local buildSystem = require("@scripts/lib/build-system")
local getStudioPluginsPath = require("@scripts/lib/getStudioPluginsPath")
local project = require("@repo/project")

local dotenv = FlipbookBatteries.dotenv
local run = FlipbookBatteries.run
local watch = FlipbookBatteries.watch

local copyInto = require("@scripts/lib/flipbook-batteries/copyInto")

type BuildContext = buildSystem.BuildContext

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
args:add("plugin", "flag", {
	help = "Builds an rbxm of the plugin to Roblox Studio's plugins folder",
	aliases = { "p" },
})
args:add("clean", "flag", {
	help = "Performs a full rebuild of the project",
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

local function readWallyManifestAsync()
	local wallyTomlHandle = fs.open("wally.toml", "r")
	local contents = fs.read(wallyTomlHandle)
	fs.close(wallyTomlHandle)
	return toml.deserialize(contents)
end

local function getCommitHash()
	local commitHash = run("git", { "rev-parse", "--short", "HEAD" }, {
		stdio = "default",
	})
	assert(commitHash ~= nil and commitHash ~= "", "commit hash is empty")
	return commitHash
end

local context: BuildContext = {
	channel = channel,
	target = target,
	shouldRebuild = args:has("clean"),
	dest = `{process.cwd()}/{project.BUILD_PATH}/plugin`,
	env = {
		BUILD_VERSION = (readWallyManifestAsync() :: any).package.version,
		BUILD_CHANNEL = if channel == "prod" then "production" else "development",
		BUILD_HASH = getCommitHash(),
		BASE_URL = process.env.BASE_URL,
	},
	cache = buildSystem.readBuildCacheAsync(),
}

local function build()
	local startTime = os.clock()

	print(richterm.dim(`build context: {pp(context)}`))

	buildSystem.compileAsync(context)

	if args:has("plugin") then
		buildSystem.runBuildGroupAsync({
			name = "🔌 plugin binary",
			paths = { context.dest },
			context = context,
			step = function()
				local dest = `{context.dest}/../{project.PLUGIN_FILENAME}`
				run("rojo", { "build", "-o", dest })

				copyInto(dest, output)
			end,
		})
	end

	buildSystem.writeBuildCacheAsync(context.cache)

	print(`build completed in {("%.2f"):format(os.clock() - startTime)}s`)
end

build()

if args:has("watch") then
	local function onChanged(filePath: string)
		if filePath:match(project.WORKSPACE_PATH) then
			local memberPath = filePath:match(`({project.WORKSPACE_PATH}/[%w%-]+)/`)
			buildSystem.compileWorkspaceMemberAsync(memberPath, context)
			buildSystem.writeBuildCacheAsync(context.cache)
		else
			build()
		end
	end

	watch({
		roots = {
			`{process.cwd()}/src`,
			`{process.cwd()}/workspace`,
		},
		excludedFilePatterns = {
			".*Packages",
			"build",
		},
		onChanged = onChanged,
	})
end
