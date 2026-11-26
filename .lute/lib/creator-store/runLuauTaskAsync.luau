local json = require("@std/json")
local net = require("@std/net")
local task = require("@std/task")

local LuauExecution = require("@lpm/open-cloud-luau-execution@v0.2.0")
local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")

local logger = require("@scripts/lib/logger")

-- How long to wait between checks on whether a task has finished.
local POLL_INTERVAL_SECONDS = 2

-- A task fails if its script runs longer than this. Five minutes is also Open
-- Cloud's default, so this only makes the limit visible here.
local TASK_TIMEOUT = "300s"

export type Options = {
	universeId: number,
	placeId: number,
	-- Each entry is set as a `_G` global before the script runs.
	globals: { [string]: string | number },
	-- Bytes the script receives as `({ ... })[1].BinaryInput`, such as the
	-- contents of an `.rbxm` file.
	binaryInput: string?,
}

-- Open Cloud names a task by a path such as
-- `universes/1/places/2/versions/3/luau-execution-sessions/4/tasks/5`. Looking
-- the task up and reading its logs take each of those IDs as its own argument.
type TaskIds = {
	universe_id: string,
	place_id: string,
	version_id: string,
	luau_execution_session_id: string,
	task_id: string,
}

local function parseTaskPath(taskPath: string): TaskIds
	local universeId, placeId, versionId, sessionId, taskId = taskPath:match(
		"^universes/([^/]+)/places/([^/]+)/versions/([^/]+)/luau%-execution%-sessions/([^/]+)/tasks/([^/]+)$"
	)
	if universeId and placeId and versionId and sessionId and taskId then
		return {
			universe_id = universeId,
			place_id = placeId,
			version_id = versionId,
			luau_execution_session_id = sessionId,
			task_id = taskId,
		}
	end

	error(`Unexpected Luau execution task path: {taskPath}`, 0)
end

-- Open Cloud hands back a signed URL for the binary input. The signature
-- authorizes the upload, so it doesn't take the API key.
local function uploadBinaryInputAsync(client: OpenApiRuntime.Client, universeId: string, contents: string): string
	local reserved = LuauExecution.createLuauExecutionSessionTaskBinaryInput(client, {
		universe_id = universeId,
		body = {
			size = #contents,
		},
	})

	local uploadUri = assert(reserved.uploadUri, "The binary input has no upload URI")
	local response = net.request(uploadUri, {
		method = "PUT",
		headers = { ["Content-Type"] = "application/octet-stream" },
		body = contents,
	})
	if not response.ok then
		error(`Uploading the binary input failed with {response.status}\n{response.body}`, 0)
	end

	return assert(reserved.path, "The binary input has no resource path")
end

--[[
	Runs a script in a place through Open Cloud Luau Execution and waits for it
	to finish. The script's output is printed here as it would be in Studio, and
	the messages are returned in order so the caller can read values the script
	printed. A task that fails or times out raises an error with Open Cloud's
	reason.
]]
local function runLuauTaskAsync(client: OpenApiRuntime.Client, script: string, options: Options): { string }
	local universeId = string.format("%d", options.universeId)

	local preamble = {}
	for name, value in options.globals do
		table.insert(preamble, `_G[{json.serialize(name)}] = {json.serialize(value)}\n`)
	end

	local binaryInputPath = if options.binaryInput
		then uploadBinaryInputAsync(client, universeId, options.binaryInput)
		else nil

	local created = LuauExecution.createLuauExecutionSessionTaskUsingUniverses(client, {
		universe_id = universeId,
		place_id = string.format("%d", options.placeId),
		body = {
			script = table.concat(preamble) .. script,
			timeout = TASK_TIMEOUT,
			binaryInput = binaryInputPath,
		},
	})
	local ids = parseTaskPath(assert(created.path, "The created task has no resource path"))

	local finished: LuauExecution.LuauExecutionSessionTask
	repeat
		task.wait(POLL_INTERVAL_SECONDS)
		finished = LuauExecution.getLuauExecutionSessionTask(client, {
			universe_id = ids.universe_id,
			place_id = ids.place_id,
			version_id = ids.version_id,
			luau_execution_session_id = ids.luau_execution_session_id,
			task_id = ids.task_id,
		})
	until finished.state ~= "QUEUED" and finished.state ~= "PROCESSING"

	-- The logs come in pages of chunks, each holding some of the messages.
	local messages: { string } = {}
	local pageToken: string? = nil
	repeat
		local page = LuauExecution.listLuauExecutionSessionTaskLogs(client, {
			universe_id = ids.universe_id,
			place_id = ids.place_id,
			version_id = ids.version_id,
			luau_execution_session_id = ids.luau_execution_session_id,
			task_id = ids.task_id,
			pageToken = pageToken,
		})
		for _, chunk in page.luauExecutionSessionTaskLogs or {} do
			for _, message in chunk.messages or {} do
				logger.info(message)
				table.insert(messages, message)
			end
		end
		pageToken = page.nextPageToken
	until pageToken == nil or pageToken == ""

	if finished.state ~= "COMPLETE" then
		local reason = if finished.error then `: {finished.error.code} - {finished.error.message}` else ""
		error(`The Luau execution task ended as {finished.state}{reason}`, 0)
	end

	return messages
end

return runLuauTaskAsync
