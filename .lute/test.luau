local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")

local dotenv = FlipbookBatteries.dotenv
local run = FlipbookBatteries.run

dotenv()

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:add("filter", "option", {
	help = "Specify a filepath pattern to match for when running tests",
})

args:add("strict", "flag", {
	help = "Locks down the testing environment to limit what Roblox APIs can be interacted with",
})

args:parse({ ... })

local filter = args:get("filter")
local strict = args:has("strict")
local apiKey = args:get("apiKey")

if strict then
	if process.env.ROBLOX_STRICT_SANDBOX_API_KEY then
		apiKey = process.env.ROBLOX_STRICT_SANDBOX_API_KEY
	end
else
	if process.env.ROBLOX_API_KEY then
		apiKey = process.env.ROBLOX_API_KEY
	end
end

--  or process.env.ROBLOX_API_KEY or process.env.ROBLOX_STRICT_SANDBOX_API_KEY

if apiKey == "" or apiKey == nil then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

-- This gets picked up by the build step which uses Darklua to inject globals
process.env.JEST_TEST_PATH_PATTERN = if filter then filter else ""

run("lute", { "run", "build", "plugin", "--channel", "dev", "--clean", "--skip-reload" })

local experience = if strict then project.EXPERIENCES.forkSandbox else project.EXPERIENCES.unitTesting

run("rocale", {
	"run",
	"--script",
	".lute/tasks/run-tests.luau",
	"--load.project",
	project.ROJO_TESTS_PROJECT,
	"--universeId",
	experience.universeId,
	"--placeId",
	experience.placeId,
	"--output",
	tostring(path.join(system.tmpdir(), "tests.rbxl")),
}, {
	env = {
		ROBLOX_API_KEY = apiKey,
	},
})
