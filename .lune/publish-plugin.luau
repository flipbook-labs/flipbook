local process = require("@lune/process")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")
local clean = require("./lib/clean")
local compile = require("./lib/compile")
local project = require("../project")

local args = parseArgs(process.args)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

clean()
compile("dev")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local publishPluginAssetTask = "build/publish-plugin-asset.luau"

do -- mini darklua for swapping out globals in the task with real values
	run("cp", { ".lune/tasks/publish-plugin-asset.luau", publishPluginAssetTask })

	local GLOBAL_SUBSTITUTIONS = {
		ROBLOX_CREATOR_ID = project.ROBLOX_ASSET_CREATOR_ID,
		ROBLOX_ASSET_ID = project.ROBLOX_PLUGIN_ASSET_ID_DEV,
	}

	for global, value in GLOBAL_SUBSTITUTIONS do
		run("sed", { "-i", "-e", `s/_G.{global}/{value}/g`, publishPluginAssetTask })
	end
end

local output, success = run("python3", {
	".lune/open-cloud/upload_and_run_task.py",
	"tests.rbxl",
	publishPluginAssetTask,
}, {
	env = {
		ROBLOX_UNIVERSE_ID = project.ROBLOX_UNIVERSE_ID,
		ROBLOX_PLACE_ID = project.ROBLOX_PLACE_ID,
		ROBLOX_API_KEY = apiKey,
	},
})

run("rm", { "tests.rbxl" })

if not success then
	print(output)
	process.exit(1)
end
