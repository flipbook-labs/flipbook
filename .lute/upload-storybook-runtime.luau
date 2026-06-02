local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")

local run = FlipbookBatteries.run

local UNIVERSE_ID = 10183204244
local PLACE_ID = 78927494985490
local CREATOR_ID = 1343930
local CREATOR_TYPE = "User"
local MODEL_PATH = "Flipbook.rbxm"
local ASSET_NAME = "Flipbook"

dotenv.config()

local args = cli.parser()

args:add("api-key", "option", {
	help = "Roblox Open Cloud API key (can also be set via ROBLOX_API_KEY env var)",
})

args:parse({ ... })

local apiKey = assert(
	args:get("api-key") or process.env.ROBLOX_API_KEY,
	"--api-key or ROBLOX_API_KEY must be supplied"
)

-- Build a temp place with Flipbook.rbxm in ReplicatedStorage using Rojo so
-- AssetService:CreateAssetAsync can reach the instance via Luau Execution.
local placePath = path.join(system.tmpdir(), "flipbook-upload.rbxl")
local projectPath = path.join(system.tmpdir(), "flipbook-upload.project.json")

createRojoProjectAsync(projectPath, {
	name = "UploadPlace",
	emitLegacyScripts = false,
	tree = {
		["$className"] = "DataModel",
		ReplicatedStorage = {
			[ASSET_NAME] = { ["$path"] = tostring(path.resolve(MODEL_PATH)) },
		},
	},
})
run("rojo", { "build", projectPath, "--output", placePath })

-- Publish the place (Saved) so the model is available to the Luau task
local publishRes = net.request(
	`https://apis.roblox.com/universes/v1/{UNIVERSE_ID}/places/{PLACE_ID}/versions?versionType=Saved`,
	{
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/xml",
			["Accept"] = "application/json",
		},
		body = fs.readFileToString(tostring(placePath)),
	}
)
assert(publishRes.ok, `failed to publish place ({publishRes.status}): {publishRes.body}`)

run("rm", { "-f", placePath })

-- Write the Luau task script to a temp file for rocale
local taskScript = string.format(
	[[
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local instance = ReplicatedStorage:GetChildren()[1]
assert(instance, "no model found in ReplicatedStorage")

local _ok, rawId = AssetService:CreateAssetAsync(instance, Enum.AssetType.Model, {
	Name = instance.Name,
	CreatorId = %d,
	CreatorType = Enum.AssetCreatorType.%s,
	IsPackage = true,
})
print("ASSET_ID=" .. tostring(rawId))
]],
	CREATOR_ID,
	CREATOR_TYPE
)

local scriptPath = tostring(path.join(system.tmpdir(), "flipbook-upload-task.luau"))
fs.writeStringToFile(scriptPath, taskScript)

-- Run the task via rocale and parse ASSET_ID from its output
local output = assert(
	run("rocale", {
		"run",
		"--script",
		scriptPath,
		"--universeId",
		UNIVERSE_ID,
		"--placeId",
		PLACE_ID,
	}, {
		captureOutput = true,
		env = { ROBLOX_API_KEY = apiKey },
	}),
	"rocale produced no output"
)

run("rm", { "-f", scriptPath })

local assetId: string?
for line in output:gmatch("[^\n]+") do
	local id = line:match("^ASSET_ID=(%S+)$")
	if id then
		assetId = id
	end
end

print("ASSET_ID=" .. assert(assetId, "task did not print ASSET_ID"))
