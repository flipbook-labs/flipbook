--[[
	Publishes a built Flipbook plugin to the Creator Store.

	Usage:
	  lute run publish-plugin --channel <dev | beta | prod> [--file <path>]
	  lute run publish-plugin --smoketest [--file <path>]

	Build the plugin first with `lute run build plugin`. This only uploads the
	`.rbxm` it's given, which is `Flipbook.rbxm` by default. The channel picks
	the asset, as `ASSET_NAMES_BY_CHANNEL` in `creator-store.luau` maps it, so
	beta builds land on the dev asset. `--smoketest` publishes to the smoketest
	asset whatever the channel is.

	The Open Cloud API key comes from ROBLOX_API_KEY, set in the environment or
	in `.env`. When that's empty, `--apiKey` supplies it.
]]
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local process = require("@std/process")

local creatorStore = require("@repo/creator-store")
local logger = require("@scripts/lib/logger")
local project = require("@repo/project")
local publishPluginAsync = require("@scripts/lib/creator-store/publishPluginAsync")

FlipbookBatteries.dotenv()

local args = cli.parser()
args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})
args:add("channel", "option", {
	help = `The channel being published: "dev", "beta", or "prod"`,
	default = "dev",
})
args:add("smoketest", "flag", {
	help = "Publish to the smoketest asset that pull requests use",
})
args:add("file", "option", {
	help = "The plugin build to upload",
	default = project.PLUGIN_FILENAME,
})
args:add("apiKey", "option", {
	help = "Open Cloud API key, used when the ROBLOX_API_KEY environment variable is empty",
	aliases = { "k" },
})
args:parse({ ... })

-- `--channel` takes the lowercase names that `lute run build` uses.
local channelArg = assert(args:get("channel"))
local channel: creatorStore.ChannelName? = nil
for name in creatorStore.ASSET_NAMES_BY_CHANNEL do
	if name:lower() == channelArg then
		channel = name
	end
end
assert(channel, `bad value for channel (must be one of "dev", "beta", or "prod", got "{channelArg}")`)

local apiKey = process.env.ROBLOX_API_KEY
if apiKey == nil or apiKey == "" then
	apiKey = args:get("apiKey")
end
assert(apiKey ~= nil and apiKey ~= "", "An Open Cloud API key must be supplied with either --apiKey or ROBLOX_API_KEY")

local file = assert(args:get("file"))
assert(fs.exists(file), `{file} doesn't exist. Build it first with \`lute run build plugin\``)

local assetName = if args:has("smoketest")
	then creatorStore.AssetName.Smoketest
	else creatorStore.ASSET_NAMES_BY_CHANNEL[channel]
local assetId = creatorStore.ASSETS[assetName].assetId

logger.info(`Publishing {file} to the {assetName} asset ({string.format("%d", assetId)})`)
local versionNumber = publishPluginAsync(file, assetName, apiKey)
logger.info(`Published version {versionNumber}: https://create.roblox.com/store/asset/{string.format("%d", assetId)}`)
