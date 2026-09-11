local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local rbxasset = require("@luaupkg/rbxasset@main")

local project = require("@repo/project")

local run = FlipbookBatteries.run

dotenv.config()

local args = cli.parser()

args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})

args:add("channel", "option", {
	help = "Channel to publish for",
	aliases = { "c" },
	default = "prod",
})

args:add("apiKey", "option", {
	help = "Open Cloud API key used for publishing the plugin. Must include `asset:write` and `asset:read` scopes",
	aliases = { "k" },
})
args:add("smoketest", "flag", {
	help = "Publish to the smoketest asset",
})

args:parse({ ... })

local channel = args:get("channel")
assert(
	channel == "dev" or channel == "beta" or channel == "prod",
	`bad value for channel (must be one of "dev", "beta", or "prod", got "{channel}")`
)

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
assert(
	apiKey,
	"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
)

run("lute", {
	"run",
	"build",
	"plugin",
	"--channel",
	channel,
	"--output",
	tostring(path.join(project.REPO_PATH, project.PLUGIN_FILENAME)),
})

type ChannelName = "dev" | "beta" | "prod"
type AssetName = "dev" | "prod" | "smoketest"

local ASSET_NAMES_BY_CHANNEL: { [ChannelName]: AssetName } = {
	dev = "dev",
	beta = "dev",
	prod = "prod",
}

local assetName: AssetName = if args:has("smoketest") then "smoketest" else ASSET_NAMES_BY_CHANNEL[channel]

-- Each of the assets defined in rbxasset.toml map to one of the options of
-- `--channel` for simplicity
rbxasset.publishPackageAsync(tostring(project.REPO_PATH), assetName, apiKey)
