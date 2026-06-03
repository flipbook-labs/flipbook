local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local getUniverseStartPlaceAsync = require("@scripts/lib/getUniverseStartPlaceAsync")
local project = require("@repo/project")
local rojoBuild = require("@scripts/lib/rojoBuild")
local runTaskAsync = require("@scripts/lib/runTaskAsync")

local MODEL_PATH = "Flipbook.rbxm"

dotenv.config()

local args = cli.parser()

args:add("name", "option", {
	help = "Name of the asset to create in Roblox (defaults to the name of the model)",
	required = true,
})
args:add("model", "option", {
	help = "Path to the model to upload",
	required = true,
})

args:add("api-key", "option", {
	help = "Roblox Open Cloud API key (can also be set via ROBLOX_ASSET_UPLOADER_API_KEY env var)",
})

args:parse({ ... })

local assetName = args:get("name") :: string
local modelPath = args:get("model") :: string

local apiKey = assert(
	args:get("api-key") or process.env.ROBLOX_ASSET_UPLOADER_API_KEY,
	"--api-key or ROBLOX_ASSET_UPLOADER_API_KEY must be supplied"
)

local placePath = path.join(system.tmpdir(), "flipbook-upload.rbxl")

rojoBuild({
	output = placePath,
	project = {
		name = "UploadPlace",
		emitLegacyScripts = false,
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				Flipbook = {
					["$path"] = tostring(path.resolve(modelPath)),
				},
			},
		},
	},
})

local placeId = getUniverseStartPlaceAsync(project.ASSET_UPLOADER_UNIVERSE_ID, apiKey)
print(`using placeId {placeId} for the Luau Execution session`)

local taskScript = [[
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local instance = ReplicatedStorage:GetChildren()[1]
assert(instance, "no model found in ReplicatedStorage")

local _, assetId = AssetService:CreateAssetAsync(ReplicatedStorage.Flipbook, Enum.AssetType.Model, {
	Name = _G.ASSET_NAME,
	CreatorId = tonumber(_G.SERVICE_ACCOUNT_USER_ID),
	CreatorType = Enum.AssetCreatorType.User,
	IsPackage = true,
})
print(assetId)
]]

local assetId = assert(
	runTaskAsync(taskScript, {
		ASSET_NAME = assetName,
		SERVICE_ACCOUNT_USER_ID = project.SERVICE_ACCOUNT_USER_ID,
	}, {
		apiKey = apiKey,
		universeId = project.ASSET_UPLOADER_UNIVERSE_ID,
		placeId = placeId,
		placePath = placePath,
	}),
	"task did not return ASSET_ID"
)

fs.remove(placePath)

print("ASSET_ID=" .. tostring(assetId))
