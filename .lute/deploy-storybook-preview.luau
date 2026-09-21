local cli = require("@batteries/cli")
local process = require("@std/process")

local args = cli.parser()

args:add("script", "positional", {
	hidden = true,
})
args:add("universe-id", "option", {
	help = "Required. Universe containing the Storybook preview place.",
})
args:add("place-name", "option", {
	help = "Required. Name of the preview place to update or create.",
})
args:add("place-file", "option", {
	help = "Path to the Storybook place file.",
	default = "build/flipbook-storybook.rbxl",
})
args:add("flipbook-rbxm", "option", {
	help = "Path to the Flipbook runtime to embed.",
	default = "build/prod/Flipbook.rbxm",
})
args:add("api-key", "option", {
	help = "Roblox API key. Can also use ROBLOX_API_KEY.",
})
args:add("help", "flag", {
	help = "Show this help message.",
})

args:parse({ ... })

if args:has("help") then
	print(args:usage("lute run deploy-storybook-preview"))
	print("")
	print(args:help())
	return
end

local universeId = assert(args:get("universe-id"), "--universe-id is required")
assert(tonumber(universeId), `--universe-id must be a number, got "{universeId}"`)
local placeName = assert(args:get("place-name"), "--place-name is required")
local placeFile = args:get("place-file") :: string
local flipbookRbxm = args:get("flipbook-rbxm") :: string
local apiKey = assert(args:get("api-key") or process.env.ROBLOX_API_KEY, "--api-key or ROBLOX_API_KEY is required")

local result = process.run({
	"flipbook-cli",
	"deploy",
	"--universe-id",
	universeId,
	"--place-name",
	placeName,
	"--place-file",
	placeFile,
	"--flipbook-rbxm",
	flipbookRbxm,
}, {
	env = {
		ROBLOX_API_KEY = apiKey,
	},
	stdio = "inherit",
})

if not result.ok then
	process.exit(result.exitcode)
end
