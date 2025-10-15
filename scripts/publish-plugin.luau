local cli = require("@batteries/cli")
local process = require("@lute/process")
local rbxasset = require("@luaupkg/rbxasset")

local run = require("./lib/run")

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for publishing the plugin",
	aliases = { "k" },
	required = true,
})
args:add("channel", "option", {
	help = "Channel to build for",
	aliases = { "c" },
	default = "prod",
})

args:parse({ ... })

local channel = args:get("channel")
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local apiKey = args:get("apiKey")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

run("lune", { "run", "build", "--channel", channel, "--output", "Flipbook.rbxm" })

-- Each of the assets defined in rbxasset.toml map to one of the options of
-- `--channel` for simplicity
rbxasset.publishPackageAsync(process.cwd(), channel, apiKey)
