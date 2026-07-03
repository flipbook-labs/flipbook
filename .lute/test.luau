local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

-- Anchor .env to the repo root so this task works regardless of the working
-- directory, and skip it when absent (e.g. fresh clones and worktrees) so the
-- ROBLOX_API_KEY environment variable can supply the key on its own
local envPath = path.join(path.dirname(debug.info(1, "s")), "..", ".env")
if fs.exists(envPath) then
	dotenv.config({ path = envPath } :: dotenv.ConfigOptions)
end

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

-- An empty string (e.g. a blank ROBLOX_API_KEY= line copied from
-- .env.template) is truthy in Luau, so treat it the same as unset
local apiKey = args:get("apiKey") or process.env.ROBLOX_API_KEY
if not apiKey or apiKey == "" then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

local filter = args:get("filter")

-- This gets picked up by the build step which uses Darklua to inject globals
process.env.JEST_TEST_PATH_PATTERN = if filter then filter else ""

run("lute", { "run", "build", "plugin", "--channel", "dev", "--clean", "--skip-reload" })

local placePath = rojoBuild({
	output = path.join(system.tmpdir(), "tests-place.rbxl"),
	project = {
		name = "Flipbook",
		tree = {
			["$className"] = "DataModel",
			ServerScriptService = {
				["$properties"] = {
					LoadStringEnabled = true,
				},
			},
			ReplicatedStorage = {
				Flipbook = {
					["$path"] = tostring(path.join(project.BUILD_PATH, "dev", "roblox")),
				},
			},
		},
	},
})

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
