local process = require("@lune/process")

local clean = require("./lib/clean")
local compile = require("./lib/compile")
local parseArgs = require("./lib/parseArgs")
local project = require("../project")
local run = require("./lib/run")

local args = parseArgs(process.args)

local target = if args.target then args.target else "dev"
assert(target == "dev" or target == "prod", `bad value for target (must be one of "dev" or "prod", got "{target}")`)

local apiKey = assert(args.apiKey, "--apiKey must be supplied with a valid Open Cloud API key")
assert(typeof(apiKey) == "string", `bad value for apiKey (string expected, got {typeof(apiKey)})`)

clean()
compile("prod")

run("rojo", { "build", "tests.project.json", "-o", "tests.rbxl" })

local publishPluginAssetTask = "build/publish-plugin-asset.luau"

do -- mini darklua for swapping out globals in the task with real values
	run("cp", { ".lune/tasks/publish-plugin-asset.luau", publishPluginAssetTask })

	local GLOBAL_SUBSTITUTIONS = {
		ROBLOX_CREATOR_ID = project.ROBLOX_ASSET_CREATOR_ID,
		ROBLOX_ASSET_ID = if target == "dev"
			then project.ROBLOX_PLUGIN_ASSET_ID_DEV
			else project.ROBLOX_PLUGIN_ASSET_ID_PROD,
	}

	for global, value in GLOBAL_SUBSTITUTIONS do
		run("sed", { "-i", "-e", `s/_G.{global}/{value}/g`, publishPluginAssetTask })
	end
end

local success, result = pcall(function()
	return run("python3", {
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
end)

run("rm", { "tests.rbxl" })

if not success then
	print(result)
	process.exit(1)
end
