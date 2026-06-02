local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local dotenv = require("@luaupkg/dotenv@v0.1.0/src")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local task = require("@std/task")

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
	args:get("api-key") or _G.env and _G.env.ROBLOX_API_KEY,
	"--api-key or ROBLOX_API_KEY must be supplied"
)

-- Multipart form data helpers
local BOUNDARY = "FlipbookUploadBoundary" .. tostring(math.random(100000, 999999))

local function buildMultipart(fields: { { name: string, value: string, contentType: string, filename: string? } }): string
	local parts = {}
	for _, field in fields do
		local disposition = `Content-Disposition: form-data; name="{field.name}"`
		if field.filename then
			disposition ..= `; filename="{field.filename}"`
		end
		table.insert(parts, "--" .. BOUNDARY .. "\r\n" .. disposition .. "\r\nContent-Type: " .. field.contentType .. "\r\n\r\n" .. field.value)
	end
	return table.concat(parts, "\r\n") .. "\r\n--" .. BOUNDARY .. "--\r\n"
end

local function request(url: string, options: { method: string?, headers: { [string]: string }?, body: string? })
	local res = net.request(url, {
		method = options.method or "GET",
		headers = options.headers,
		body = options.body,
	})
	if not res.ok then
		local ok, body = pcall(json.deserialize, res.body)
		local message = if ok and (body :: any).message then (body :: any).message else res.body
		error(`HTTP {res.status} from {url}: {message}`, 2)
	end
	return res
end

-- Upload Flipbook.rbxm to the Open Cloud Assets API
local fileContent = fs.readStringFromFile(MODEL_PATH)

local body = buildMultipart({
	{
		name = "request",
		contentType = "application/json",
		value = json.serialize({
			assetType = "Model",
			displayName = ASSET_NAME,
			description = ASSET_DESCRIPTION,
			creationContext = {
				creator = { userId = tostring(CREATOR_ID) },
			},
		}),
	},
	{
		name = "fileContent",
		contentType = "application/octet-stream",
		filename = MODEL_PATH,
		value = fileContent,
	},
})

local createRes = request("https://apis.roblox.com/assets/v1/assets", {
	method = "POST",
	headers = {
		["x-api-key"] = apiKey,
		["Content-Type"] = `multipart/form-data; boundary={BOUNDARY}`,
	},
	body = body,
})

local createBody = json.deserialize(createRes.body) :: any
local operationId = assert(createBody.operationId, "no operationId in upload response")

-- Poll until the operation completes
local assetId: string?
for attempt = 1, MAX_POLL_ATTEMPTS do
	task.wait(POLL_DELAY)

	local pollRes = request(`https://apis.roblox.com/assets/v1/operations/{operationId}`, {
		headers = { ["x-api-key"] = apiKey },
	})
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
