-- FIXME: This is still a Lune script for now because rbxasset is not yet ported
-- to Lute. Follow this PR for updates: https://github.com/Roblox/rbxasset/pull/5

local process = require("@lune/process")
local rbxasset = require("@luaupkg/rbxasset")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local args = parseArgs(process.args)

local channel = if args.channel then args.channel else "dev"
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

-- --assetName lets callers target a specific rbxasset.toml entry directly
-- (e.g. "storybook-runtime"). When omitted the asset name is derived from
-- --channel / --smoketest as before.
local assetName: string
if args.assetName then
	assetName = args.assetName
	-- For non-plugin assets the model file must already be built by the caller
else
	run("lute", { "run", "build", "plugin", "--channel", channel, "--output", "Flipbook.rbxm" })
	assetName = if args.smoketest then "smoketest" else channel
end

-- Each of the assets defined in rbxasset.toml map to one of the options of
-- `--channel` for simplicity
rbxasset.publishPackageAsync(process.cwd, assetName, apiKey)
