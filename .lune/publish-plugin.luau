local process = require("@lune/process")
local rbxasset = require("@lunepkg/rbxasset")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local args = parseArgs(process.args)

local target = if args.target then args.target else "dev"
assert(target == "dev" or target == "prod", `bad value for target (must be one of "dev" or "prod", got "{target}")`)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

run("lune", { "run", "build", "--target", target, "--output", "Flipbook.rbxm" })

-- Each of the assets defined in rbxasset.toml map to one of the options of
-- `--target` for simplicity
rbxasset.publishPackageAsync(process.cwd, target, apiKey)
