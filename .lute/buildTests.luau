local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local cli = require("@batteries/cli")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

local args = cli.parser()

args:add("filter", "option", {
	help = "Specify a filepath pattern to match for when running tests",
})
args:add("output", "option", {
	help = "Path to the test place file to build",
	default = tostring(path.join(system.tmpdir(), "tests-place.rbxl")),
})

args:parse({ ... })

local output = args:get("output")
assert(typeof(output) == "string", `bad value for output (string expected, got {typeof(output)})`)

local filter = args:get("filter")
process.env.JEST_TEST_PATH_PATTERN = if filter then filter else ""

run("lute", { "run", "build", "plugin", "--channel", "dev", "--clean", "--skip-reload" })

local placePath = rojoBuild({
	output = output,
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

print(`Built test place: {placePath}`)
