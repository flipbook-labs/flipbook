local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")
local task = require("@std/task")

local createFormData = require("@scripts/lib/createFormData")

local CREATOR_ID = 1343930
local MODEL_PATH = "Flipbook.rbxm"
local ASSET_NAME = "Flipbook"
local ASSET_DESCRIPTION = "Flipbook is a storybook plugin that previews UI components in a sandboxed environment."
local MAX_POLL_ATTEMPTS = 10
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

local formData = createFormData({
	request = {
		contentType = "application/json",
		value = {
			assetType = "Model",
			displayName = ASSET_NAME,
			description = ASSET_DESCRIPTION,
			creationContext = {
				creator = { userId = tostring(CREATOR_ID) },
			},
		},
	},
	fileContent = {
		contentType = "application/octet-stream",
		filename = MODEL_PATH,
		value = fs.readStringFromFile(MODEL_PATH),
	},
})

local createRes = net.request("https://apis.roblox.com/assets/v1/assets", {
	method = "POST",
	headers = {
		["x-api-key"] = apiKey,
		["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
	},
	body = formData.body,
})
assert(createRes.ok, `failed to upload asset ({createRes.status}): {createRes.body}`)

local createBody = json.deserialize(createRes.body) :: any
local operationId = assert(createBody.operationId, "no operationId in upload response")

local assetId: string?
for attempt = 1, MAX_POLL_ATTEMPTS do
	task.wait(POLL_DELAY)

	local pollRes = net.request(`https://apis.roblox.com/assets/v1/operations/{operationId}`, {
		headers = { ["x-api-key"] = apiKey },
	})
	assert(pollRes.ok, `failed to poll operation ({pollRes.status}): {pollRes.body}`)

	local pollBody = json.deserialize(pollRes.body) :: any

	if pollBody.done then
		local response = pollBody.response :: any
		assetId = tostring(assert(response and response.assetId, "operation completed but has no assetId"))
		break
	end

	if attempt == MAX_POLL_ATTEMPTS then
		error(`operation {operationId} did not complete after {MAX_POLL_ATTEMPTS} attempts`)
	end
end

print("ASSET_ID=" .. (assetId :: string))
