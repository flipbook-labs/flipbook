local process = require("@lune/process")

local compile = require("./lib/compile")
local dotenv = require("./lib/dotenv")
local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

dotenv()

local args = parseArgs(process.args)

local apiKey = process.env.ROBLOX_API_KEY or args.apiKey
if not apiKey then
	print(
		"err: A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
	process.exit(1)
end

compile("dev")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local success, err = pcall(function()
	run("python3", {
		".lune/python/upload_and_run_task.py",
		"tests.rbxl",
		"tests/run-tests.luau",
	}, {
		env = {
			ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
			ROBLOX_PLACE_ID = process.env.ROBLOX_UNIT_TESTING_PLACE_ID,
			ROBLOX_API_KEY = tostring(apiKey),
		},
		stdio = "forward",
	})
end)

run("rm", { "tests.rbxl" })

if not success then
	print(err)
	process.exit(1)
end
