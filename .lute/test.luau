local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")

local run = FlipbookBatteries.run

dotenv.config()

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:add("filter", "option", {
	help = "Specify a filepath pattern to match for when running tests",
})

args:parse({ ... })

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
if not apiKey then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

local filter = args:get("filter")

-- This gets picked up by the build step which uses Darklua to inject globals
process.env.JEST_TEST_PATH_PATTERN = if filter then filter else ""

run("lute", { "run", "build", "plugin", "--channel", "dev", "--clean", "--skip-reload" })

run("rocale", {
	"run",
	"--script",
	".lute/tasks/run-tests.luau",
	"--load.project",
	project.ROJO_TESTS_PROJECT,
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
