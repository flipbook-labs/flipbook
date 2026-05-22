local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local path = require("@std/path")
local system = require("@std/system")

local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")

local run = FlipbookBatteries.run

dotenv.config()

local args = cli.parser()

args:add("main-place", "flag", {
	help = "Deploy to the main place instead of a PR-specific place",
})

args:parse({ ... })

run("lute", { "run", "build", "workspace", "--channel", "dev" })

local workspaceRbxmPath = path.join(system.tmpdir(), "workspace.rbxm")

rojoBuild({
	output = workspaceRbxmPath,
	project = {
		name = "FlipbookWorkspace",
		tree = {
			["$path"] = tostring(path.resolve("./build/dev/roblox/workspace")),
		},
	},
})

local flipbookCliArgs: { string | number | path.Pathlike } = {
	"deploy",
	"--universe-id",
	project.ROBLOX_STORYBOOK_UNIVERSE_ID,
	"--stories",
	workspaceRbxmPath,
}

if args:has("main-place") then
	table.insert(flipbookCliArgs, "--place-id")
	table.insert(flipbookCliArgs, project.ROBLOX_STORYBOOK_PLACE_ID)
end

run("flipbook-cli", flipbookCliArgs)
