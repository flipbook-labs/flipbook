local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")
local toml = require("@luaupkg/lute@v1.0.0/batteries/toml")

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

local apiKey = assert(
	process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY,
	"ROBLOX_STORYBOOK_PREVIEW_API_KEY must be set"
)

-- Build processed workspace (darklua-transformed scripts with correct require paths)
run("lute", { "run", "build", "workspace", "--channel", "dev", "--clean" })

-- Build prod Flipbook.rbxm so we deploy the local build rather than the
-- latest release — this lets us catch embedding issues before cutting a release.
run("lute", { "run", "build", "plugin", "--channel", "prod", "--skip-reload", "--clean" })

-- Upload Flipbook.rbxm as the storybook-runtime asset and update rbxasset.lock
run("lune", { "run", "publish-plugin", "--assetName", "storybook-runtime", "--apiKey", apiKey })

-- Read the asset ID that rbxasset just wrote to the lock file
local lockContent = fs.readStringFromFile("rbxasset.lock")
local lock = toml.deserialize(lockContent) :: any
local assetId = assert(
	lock.assets["storybook-runtime"] and lock.assets["storybook-runtime"].assetId,
	"storybook-runtime assetId not found in rbxasset.lock after publish"
)

-- Build a base place that includes the workspace scripts alongside the Packages
-- and RobloxPackages they depend on, all under ReplicatedStorage.Stories so
-- require walks from workspace scripts resolve correctly.
local basePlacePath = path.join(system.tmpdir(), "storybook-base.rbxl")
local builtWorkspacePath = tostring(path.join(project.BUILD_PATH, "dev", "roblox", "workspace"))

rojoBuild({
	output = basePlacePath,
	project = {
		name = "StorybookBase",
		emitLegacyScripts = false,
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				Stories = {
					Packages = { ["$path"] = tostring(project.PACKAGES_PATH) },
					RobloxPackages = { ["$path"] = tostring(project.ROBLOX_PACKAGES_PATH) },
					workspace = { ["$path"] = builtWorkspacePath },
				},
			},
		},
	},
})

local placeName = args:get("place-name")

local flipbookCliArgs: { string | number | path.Pathlike } = {
	"deploy",
	"--place-name",
	`"{placeName}"`,
	"--universe-id",
	project.ROBLOX_STORYBOOK_UNIVERSE_ID,
	"--place-file",
	basePlacePath,
	"--flipbook-asset",
	assetId,
}

if placeName == DEFAULT_PLACE_NAME then
	table.insert(flipbookCliArgs, "--place-id")
	table.insert(flipbookCliArgs, project.ROBLOX_STORYBOOK_PLACE_ID)
end

run("flipbook-cli", flipbookCliArgs, {
	env = {
		ROBLOX_API_KEY = apiKey,
	},
})
