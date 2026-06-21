-- FIXME: This is still a Lune script for now because rbxasset is not yet ported
-- to Lute. Follow this PR for updates: https://github.com/Roblox/rbxasset/pull/5

local process = require("@lune/process")
local rbxasset = require("@luaupkg/rbxasset")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local args = parseArgs(process.args)

local channel = if args.channel then args.channel else "dev"
assert(
	channel == "dev" or channel == "beta" or channel == "prod",
	`bad value for channel (must be one of "dev", "beta", or "prod", got "{channel}")`
)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

run("lute", { "run", "build", "plugin", "--channel", channel, "--output", "Flipbook.rbxm" })

type ChannelName = "dev" | "beta" | "prod"
type AssetName = "dev" | "prod" | "smoketest"

local ASSET_NAMES_BY_CHANNEL: { [ChannelName]: AssetName } = {
	dev = "dev",
	beta = "dev",
	prod = "prod",
}

local assetName: AssetName = if args.smoketest then "smoketest" else ASSET_NAMES_BY_CHANNEL[channel]

-- Each of the assets defined in rbxasset.toml corresponds to a deploy target.
-- Multiple channels can share the same asset (e.g. beta reuses dev).
rbxasset.publishPackageAsync(process.cwd, assetName, apiKey)
