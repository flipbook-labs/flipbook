local FlipbookBatteres = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local path = require("@std/path")
local process = require("@std/process")
local rbxasset = require("@luaupkg/rbxasset")

local project = require("@repo/project")

local run = FlipbookBatteres.run
local dotenv = FlipbookBatteres.dotenv

dotenv()

local args = cli.parser()

args:add("channel", "option", {
	help = "Channel to publish for",
	aliases = { "c" },
	default = "prod",
})

args:add("apiKey", "option", {
	help = "Open Cloud API key used for publishing the plugin. Must include `asset:write` and `asset:read` scopes",
	aliases = { "k" },
})

args:parse({ ... })

local channel = args:get("channel")
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
assert(
	apiKey,
	"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
)

run("lute", {
	"scripts/build.luau",
	"plugin",
	"--channel",
	channel,
	"--output",
	tostring(path.join(project.REPO_PATH, project.PLUGIN_FILENAME)),
})

local assetName = if args.smoketest then "smoketest" else channel

-- Each of the assets defined in rbxasset.toml map to one of the options of
-- `--channel` for simplicity
rbxasset.publishPackageAsync(tostring(project.REPO_PATH), assetName, apiKey)
