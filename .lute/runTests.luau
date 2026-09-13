local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local cli = require("@batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local run = FlipbookBatteries.run

dotenv.config()

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})
args:add("place", "option", {
	help = "Path to the test place file to run",
})

args:parse({ ... })

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
if not apiKey or apiKey == "" then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

local placePath = args:get("place")
assert(typeof(placePath) == "string", "--place must be supplied with a test place file")

run("rocale", {
	"run",
	"--script",
	".lute/tasks/run-tests.luau",
	"--load.place",
	placePath,
	"--universeId",
	process.env.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
	"--placeId",
	process.env.ROBLOX_UNIT_TESTING_PLACE_ID,
	"--output",
	tostring(path.join(system.tmpdir(), "tests.rbxl")),
}, {
	env = {
		ROBLOX_API_KEY = apiKey,
	},
})
