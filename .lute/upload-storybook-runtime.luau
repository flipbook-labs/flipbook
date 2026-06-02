local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")
local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")
local task = require("@std/task")

local createRojoProjectAsync = require("@scripts/lib/createRojoProjectAsync")

local run = FlipbookBatteries.run

local UNIVERSE_ID = 10183204244
local PLACE_ID = 78927494985490
local CREATOR_ID = 1343930
local CREATOR_TYPE = "User"
local MODEL_PATH = "Flipbook.rbxm"
local ASSET_NAME = "Flipbook"
local MAX_POLL_ATTEMPTS = 15
local POLL_DELAY = 2

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

-- Luau task: create a Package asset from the model in ReplicatedStorage
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

local taskRes = net.request(
	`https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/places/{PLACE_ID}/luau-execution-session-tasks`,
	{
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			["x-api-key"] = apiKey,
		},
		body = json.serialize({ script = taskScript }),
	}
)
assert(taskRes.ok, `failed to create Luau task ({taskRes.status}): {taskRes.body}`)

local luauTask = json.deserialize(taskRes.body) :: any
local taskPath = luauTask.path :: string

-- Poll until the task leaves PROCESSING state
for attempt = 1, MAX_POLL_ATTEMPTS do
	task.wait(POLL_DELAY)
	local pollRes = net.request(`https://apis.roblox.com/cloud/v2/{taskPath}`, {
		headers = { ["x-api-key"] = apiKey },
	})
	assert(pollRes.ok, `failed to poll task ({pollRes.status}): {pollRes.body}`)
	luauTask = json.deserialize(pollRes.body) :: any
	if luauTask.state ~= "PROCESSING" then
		break
	end
	assert(attempt < MAX_POLL_ATTEMPTS, `task did not complete after {MAX_POLL_ATTEMPTS} attempts`)
end

assert(luauTask.state == "COMPLETE", `task failed: {json.serialize(luauTask.error or {})}`)

-- Fetch logs and extract ASSET_ID=<id>
local logsRes = net.request(`https://apis.roblox.com/cloud/v2/{taskPath}/logs`, {
	headers = { ["x-api-key"] = apiKey },
})
assert(logsRes.ok, `failed to fetch task logs ({logsRes.status}): {logsRes.body}`)

local logs = json.deserialize(logsRes.body) :: any
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

print("ASSET_ID=" .. assert(assetId, "task did not print ASSET_ID"))
