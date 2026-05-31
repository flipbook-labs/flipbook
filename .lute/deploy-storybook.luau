local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

local DEFAULT_PLACE_NAME = "Storybook Preview"

dotenv.config()

local args = cli.parser()

args:add("place-name", "option", {
	help = "The name of the place to create or update when deploying",
	default = DEFAULT_PLACE_NAME,
})

args:parse({ ... })

run("lute", { "run", "build", "workspace", "--channel", "dev", "--clean" })

local workspaceRbxmPath = path.join(system.tmpdir(), "workspace.rbxm")

rojoBuild({
	output = workspaceRbxmPath,
	project = {
		name = "FlipbookWorkspace",
		emitLegacyScripts = false,
		tree = {
			["$path"] = tostring(path.resolve("./build/dev/roblox/workspace")),
		},
	},
})

run("lute", { "run", "build", "plugin", "--channel", "prod", "--skip-reload", "--clean" })

local placeName = args:get("place-name")

local flipbookCliArgs: { string | boolean | number | path.Pathlike } = {
	"deploy",
	"--place-name",
	`"{placeName}"`,
	"--universe-id",
	project.ROBLOX_STORYBOOK_UNIVERSE_ID,
	"--stories",
	workspaceRbxmPath,
	"--flipbook-rbxm",
	path.resolve("./build/prod/Flipbook.rbxm"),
}

if placeName == DEFAULT_PLACE_NAME then
	table.insert(flipbookCliArgs, "--place-id")
	table.insert(flipbookCliArgs, project.ROBLOX_STORYBOOK_PLACE_ID)
end

run("flipbook-cli", flipbookCliArgs, {
	env = {
		FLIPBOOK_ROCALE_CMD = "rocale",
		ROBLOX_API_KEY = process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY,
	},
})
