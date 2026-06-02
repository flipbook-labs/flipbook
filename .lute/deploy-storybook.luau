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

local apiKey = assert(
	process.env.ROBLOX_STORYBOOK_PREVIEW_API_KEY,
	"ROBLOX_STORYBOOK_PREVIEW_API_KEY must be set"
)

-- Build processed workspace (darklua-transformed scripts with correct require paths)
run("lute", { "run", "build", "workspace", "--channel", "dev", "--clean" })

-- Build prod Flipbook.rbxm so we deploy the local build rather than the
-- latest release — this lets us catch embedding issues before cutting a release.
run("lute", { "run", "build", "plugin", "--channel", "prod", "--skip-reload", "--clean" })

-- Upload Flipbook.rbxm directly as the storybook-runtime asset and capture
-- the asset ID from the script's output (no rbxasset manifest involved).
local uploadOutput = assert(
	run("lute", { "run", "upload-storybook-runtime", "--api-key", apiKey }, { captureOutput = true }),
	"upload-storybook-runtime produced no output"
)
local assetId: string?
for line in uploadOutput:gmatch("[^\n]+") do
	local id = line:match("^ASSET_ID=(%S+)$")
	if id then
		assetId = id
	end
end
assert(assetId, "upload-storybook-runtime did not print an ASSET_ID")

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
