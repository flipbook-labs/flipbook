local cli = require("@batteries/cli")
local process = require("@lute/process")

local compile = require("./lib/compile")
local dotenv = require("./lib/dotenv")
local run = require("./lib/run")

dotenv()

local args = cli.parser()

args:add("apiKey", "flag", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:parse({ ... })

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
if not apiKey then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

compile("dev", "roblox")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local success, err = pcall(function()
	run("python3", {
		".lune/python/upload_and_run_task.py",
		"tests.rbxl",
		".lune/tasks/run-tests.luau",
	}, {
		env = {
			ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
			ROBLOX_PLACE_ID = process.env.ROBLOX_UNIT_TESTING_PLACE_ID,
			ROBLOX_API_KEY = tostring(apiKey),
		},
	})
end)

run("rm", { "tests.rbxl" })

assert(success, err)
