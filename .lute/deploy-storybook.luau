local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

dotenv.config()

local args = cli.parser()

args:add("place-name", "option", {
	help = "The name of the place to create or update when deploying",
	default = "Storybook Preview",
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

local flipbookCliArgs: { string | number | path.Pathlike } = {
	"deploy",
	"--place-name",
	`"{args:get("place-name")}"`,
	"--universe-id",
	project.ROBLOX_STORYBOOK_UNIVERSE_ID,
	"--stories",
	workspaceRbxmPath,
	"--flipbook-rbxm",
	path.resolve("./build/dev/Flipbook.rbxm"),
}

-- run("flipbook-cli", flipbookCliArgs, {
-- 	env = {
-- 		FLIPBOOK_ROCALE_CMD = "rocale",
-- 		ROBLOX_API_KEY = process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY,
-- 	},
-- })
do -- Debugging. We'll be uncommenting the above once ready to ship
	local luteArgs = {
		"run",
		"/Users/marin/Code/flipbook-cli/cli.luau",
	}
	for _, arg in flipbookCliArgs do
		table.insert(luteArgs, tostring(arg))
	end
	run("lute", luteArgs, {
		stdio = "inherit",
		env = {
			FLIPBOOK_ROCALE_CMD = "rocale",
			ROBLOX_API_KEY = process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY,
		},
	})
end
