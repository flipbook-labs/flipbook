local process = require("@lune/process")

local compile = require("./lib/compile")
local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local args = parseArgs(process.args)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")

compile("dev")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local output, success = run("python3", {
	".lune/python/upload_and_run_task.py",
	"tests.rbxl",
	"tests/run-tests.luau",
}, {
	env = {
		ROBLOX_UNIVERSE_ID = "6599100156",
		ROBLOX_PLACE_ID = "123506190725771",
		ROBLOX_API_KEY = apiKey,
	},
})

run("rm", { "tests.rbxl" })

if not success then
	print(output)
	process.exit(1)
end
