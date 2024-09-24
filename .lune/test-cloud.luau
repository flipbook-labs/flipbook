local process = require("@lune/process")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local args = parseArgs(process.args)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local success, output = run("python3", {
	".lune/python/upload_and_run_task.py",
	"tests.rbxl",
	"tests/run-tests.luau",
}, {
	env = {
		ROBLOX_UNIVERSE_ID = 6548431902,
		ROBLOX_PLACE_ID = 114070117184786,
		ROBLOX_API_KEY = apiKey,
	},
})

run("rm", { "tests.rbxl" })

if not success then
	print(output)
	process.exit(1)
end
