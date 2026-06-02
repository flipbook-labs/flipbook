-- Uploads Flipbook.rbxm to the Roblox storybook universe as a Package asset
-- using Luau Execution. No rbxasset manifest required.
--
-- Usage:
--   lune run upload-storybook-runtime --apiKey <key> [--assetId <id>]
--
-- Prints ASSET_ID=<id> as the last output line so callers can parse it.

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local task = require("@lune/task")

local parseArgs = require("./lib/parseArgs")
local run = require("./lib/run")

local UNIVERSE_ID = 10183204244
local PLACE_ID = 78927494985490
local CREATOR_ID = 1343930
local CREATOR_TYPE = "User"
local MODEL_PATH = "Flipbook.rbxm"
local TEMP_DIR = "upload-runtime-temp"

local args = parseArgs(process.args)
local apiKey = assert(args.apiKey, "--apiKey must be supplied")
local existingAssetId: (string | boolean)? = args.assetId

-- Build a temp place with Flipbook.rbxm in ReplicatedStorage so the Luau
-- task can reach it via ReplicatedStorage:GetChildren()[1].
if fs.isDir(TEMP_DIR) then
	fs.removeDir(TEMP_DIR)
end
fs.writeDir(TEMP_DIR)

local projectPath = TEMP_DIR .. "/upload.project.json"
local placePath = TEMP_DIR .. "/upload.rbxl"
fs.writeFile(projectPath, serde.encode("json", {
	name = "UploadPlace",
	emitLegacyScripts = false,
	tree = { ["$className"] = "DataModel" },
}))
run("rojo", { "build", projectPath, "-o", placePath })

local game = roblox.deserializePlace(fs.readFile(placePath))
local model = roblox.deserializeModel(fs.readFile(MODEL_PATH))
local replicatedStorage = game:GetService("ReplicatedStorage")
for _, child in model do
	child.Parent = replicatedStorage
end
fs.writeFile(placePath, roblox.serializePlace(game))

-- Publish the place (Saved, not Published) so the model is live for
-- the Luau Execution task.
local publishRes = net.request({
	url = `https://apis.roblox.com/universes/v1/{UNIVERSE_ID}/places/{PLACE_ID}/versions?versionType=Saved`,
	method = "POST",
	headers = {
		["x-api-key"] = apiKey,
		["Content-Type"] = "application/xml",
		["Accept"] = "application/json",
	},
	body = fs.readFile(placePath),
})
assert(publishRes.ok, `Failed to publish place: {publishRes.statusCode} {publishRes.statusMessage}`)

-- Build the Luau task script. When --assetId is provided we update the
-- existing asset version; otherwise we create a new Package asset.
local assetBlock: string
if existingAssetId and typeof(existingAssetId) == "string" then
	assetBlock = table.concat({
		`local _ok, _ver = AssetService:CreateAssetVersionAsync(`,
		`  instance, Enum.AssetType.Model, "{existingAssetId}", {{`,
		`    CreatorId = {CREATOR_ID}, CreatorType = Enum.AssetCreatorType.{CREATOR_TYPE},`,
		`  }})`,
		`local assetId = "{existingAssetId}"`,
	}, "\n")
else
	assetBlock = table.concat({
		`local _ok, rawId = AssetService:CreateAssetAsync(`,
		`  instance, Enum.AssetType.Model, {{`,
		`    Name = instance.Name, CreatorId = {CREATOR_ID},`,
		`    CreatorType = Enum.AssetCreatorType.{CREATOR_TYPE}, IsPackage = true,`,
		`  }})`,
		`local assetId = tostring(rawId)`,
	}, "\n")
end

local taskScript = table.concat({
	"local AssetService = game:GetService(\"AssetService\")",
	"local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
	"",
	"local instance = ReplicatedStorage:GetChildren()[1]",
	"assert(instance, \"no model found in ReplicatedStorage\")",
	"",
	assetBlock,
	"",
	"print(\"ASSET_ID=\" .. assetId)",
}, "\n")

-- Submit the Luau Execution task
local taskRes = net.request({
	url = `https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/places/{PLACE_ID}/luau-execution-session-tasks`,
	method = "POST",
	headers = {
		["Content-Type"] = "application/json",
		["x-api-key"] = apiKey,
	},
	body = serde.encode("json", { script = taskScript }),
})
assert(taskRes.ok, `Failed to create Luau task: {taskRes.statusCode} {taskRes.statusMessage}`)

local luauTask = serde.decode("json", taskRes.body) :: any
local taskPath = luauTask.path :: string

-- Poll until the task leaves PROCESSING state
while true do
	local pollRes = net.request({
		url = `https://apis.roblox.com/cloud/v2/{taskPath}`,
		headers = { ["x-api-key"] = apiKey },
	})
	luauTask = serde.decode("json", pollRes.body) :: any
	if luauTask.state ~= "PROCESSING" then
		break
	end
	task.wait(2)
end

assert(luauTask.state == "COMPLETE", `Luau task failed: {serde.encode("json", luauTask.error or {})}`)

-- Fetch logs and extract ASSET_ID=<id>
local logsRes = net.request({
	url = `https://apis.roblox.com/cloud/v2/{taskPath}/logs`,
	headers = { ["x-api-key"] = apiKey },
})
local logs = serde.decode("json", logsRes.body) :: any
local messages: { string } = if logs.luauExecutionSessionTaskLogs
		and #logs.luauExecutionSessionTaskLogs > 0
	then logs.luauExecutionSessionTaskLogs[1].messages
	else {}

local assetId: string?
for _, msg in messages do
	print(msg)
	local id = msg:match("^ASSET_ID=(%S+)$")
	if id then
		assetId = id
	end
end

fs.removeDir(TEMP_DIR)

assert(assetId, "task completed but did not print ASSET_ID")

-- Print once more at the very end, cleanly, for callers parsing stdout
print("ASSET_ID=" .. (assetId :: string))
