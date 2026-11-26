--[[
	Saves what Roblox Studio's viewport shows to an image file, so an agent can
	attach it to a pull request.

	Agents control Studio through Studio MCP, the Model Context Protocol server
	that ships with Studio. Its `screen_capture` tool returns the image to the
	agent but doesn't write it anywhere. This script starts its own copy of that
	server, the `StudioMCP` program, and calls the same tool through the
	server's standard input and output. Then it decodes the image and writes it
	to disk.

	Open the Story first, for example with `openStory` through
	`FlipbookAgentGateway`. The file shows whatever the viewport shows when this
	runs.

	The defaults assume macOS: the path to `StudioMCP` is where macOS installs
	Studio, and `sips`, which converts the capture to other formats, ships with
	macOS.
]]

local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")

local DEFAULT_STUDIO_MCP_PATH = "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"
local RESPONSE_TIMEOUT_SECONDS = 30

--[[
	Bash runs the MCP session because Lute can't write to a running process's
	input. The script starts the server with file descriptor 3 connected to its
	input, so each `echo ... >&3` sends one request. The server writes its
	responses to the output file, and the script waits for each response, found
	by its request id, before sending the next request.

	Until the server has connected to Studio, it rejects tool calls as an
	unknown method (-32601 in JSON-RPC, the message format MCP uses). So the
	script repeats the call until the server accepts it. Each attempt gets a new
	id, because the rejected attempt's response stays in the output file. The
	request arrives without an id, and `${request:1}` drops its opening brace
	so the id can go in front.

	The script prints the accepted call's response, then closes file
	descriptor 3, which ends the server's input so the server exits.
]]
local SESSION_SCRIPT = [==[
set -euo pipefail
server="$1"; output="$2"; request="$3"; timeout="$4"

exec 3> >("$server" > "$output" 2>/dev/null)
deadline=$((SECONDS + timeout))

waitFor() {
	until grep -q "\"id\":$1," "$output" 2>/dev/null; do
		if ((SECONDS >= deadline)); then
			echo "timed out waiting for Studio MCP" >&2
			exit 1
		fi
		sleep 0.1
	done
}

echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"flipbook-screenshot","version":"1.0.0"}}}' >&3
waitFor 1
echo '{"jsonrpc":"2.0","method":"notifications/initialized"}' >&3

id=2
while true; do
	echo "{\"jsonrpc\":\"2.0\",\"id\":$id,${request:1}" >&3
	waitFor "$id"
	response=$(grep "\"id\":$id," "$output")
	if [[ "$response" != *'"code":-32601'* ]]; then
		echo "$response"
		break
	fi
	id=$((id + 1))
	sleep 0.25
done
exec 3>&-
]==]

type McpContent = {
	type: string,
	text: string?,
	data: string?,
}

-- MCP names this field, so it can't follow the `err` convention.
-- lute-lint-ignore(no_error_field)
type McpResponse = {
	error: unknown?,
	result: {
		isError: boolean?,
		content: { McpContent },
	}?,
}

type StudioList = {
	studios: { { id: string, name: string } },
}

local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function decodeBase64(input: string): buffer
	local values = {}
	for index = 1, #BASE64_ALPHABET do
		values[BASE64_ALPHABET:byte(index)] = index - 1
	end

	local output = buffer.create(#input * 3 // 4)
	local length = 0
	local bits = 0
	local bitCount = 0
	for index = 1, #input do
		local value = values[input:byte(index)]
		if value then
			bits = bit32.bor(bit32.lshift(bits, 6), value)
			bitCount += 6
			if bitCount >= 8 then
				bitCount -= 8
				buffer.writeu8(output, length, bit32.band(bit32.rshift(bits, bitCount), 0xFF))
				length += 1
				bits = bit32.band(bits, bit32.lshift(1, bitCount) - 1)
			end
		end
	end

	local trimmed = buffer.create(length)
	buffer.copy(trimmed, 0, output, 0, length)
	return trimmed
end

local function callTool(serverPath: string, name: string, arguments: { [string]: unknown }): { McpContent }
	local outputPath = path.join(process.env.TMPDIR or "/tmp", `flipbook-screenshot-{process.pid()}.jsonl`)
	-- Lute's JSON encoder writes an empty table as an array, but MCP requires
	-- `arguments` to be an object.
	local request = json.serialize({
		method = "tools/call",
		params = {
			name = name,
			arguments = arguments,
		},
	}):gsub('"arguments":%[%]', '"arguments":{}')

	local result = process.run({
		"bash",
		"-c",
		SESSION_SCRIPT,
		"bash",
		serverPath,
		tostring(outputPath),
		request,
		tostring(RESPONSE_TIMEOUT_SECONDS),
	})
	if fs.exists(outputPath) then
		fs.remove(outputPath)
	end
	if not result.ok then
		error(`Studio MCP session failed: {result.stderr}`)
	end

	local response = json.deserialize(result.stdout) :: McpResponse
	local toolResult = response.result
	if response.error or not toolResult then
		error(`{name} failed: {result.stdout}`)
	end
	if toolResult.isError then
		error(`{name} failed: {result.stdout}`)
	end
	return toolResult.content
end

local function findOnlyStudio(serverPath: string): string
	local content = callTool(serverPath, "list_roblox_studios", {})
	local studios = (json.deserialize(content[1].text or "{}") :: StudioList).studios
	if #studios ~= 1 then
		local names = {}
		for _, studio in studios do
			table.insert(names, `{studio.id} ({studio.name})`)
		end
		error(`expected one open Studio, found {#studios}. Pass --studio with one of: {table.concat(names, ", ")}`)
	end
	return studios[1].id
end

local args = cli.parser()
args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})
args:add("output", "positional", {
	help = "Where to write the image. Studio captures JPEG, and sips converts it for other extensions",
})
args:add("studio", "option", {
	help = "Studio instance to capture, from Studio MCP's list_roblox_studios. Defaults to the only open one",
})
args:add("studio-mcp", "option", {
	help = "Path to Studio's StudioMCP program",
	default = DEFAULT_STUDIO_MCP_PATH,
})
args:parse({ ... })

local outputArg = args:get("output")
assert(outputArg, "pass the path to write the image to")
local outputPath = path.resolve(outputArg)
local serverPath = args:get("studio-mcp") or DEFAULT_STUDIO_MCP_PATH
local extension = (tostring(outputPath):match("%.(%w+)$") or ""):lower()
assert(extension ~= "", "give the output file an extension, such as .png")
local studioId = args:get("studio") or findOnlyStudio(serverPath)

local content = callTool(serverPath, "screen_capture", {
	studio_id = studioId,
	capture_id = "flipbook-screenshot",
})

local imageData: string? = nil
for _, item in content do
	if item.type == "image" then
		imageData = item.data
	end
end
if not imageData then
	local messages = {}
	for _, item in content do
		table.insert(messages, item.text or item.type)
	end
	error(`screen_capture returned no image: {table.concat(messages, " ")}`)
end

local image = buffer.tostring(decodeBase64(imageData :: string))
fs.createDirectory(path.dirname(outputPath), {
	makeParents = true,
})
if extension == "jpg" or extension == "jpeg" then
	fs.writeStringToFile(outputPath, image)
else
	local jpegPath = tostring(path.join(process.env.TMPDIR or "/tmp", `flipbook-screenshot-{process.pid()}.jpg`))
	fs.writeStringToFile(jpegPath, image)
	local converted = process.run({
		"sips",
		"-s",
		"format",
		extension,
		jpegPath,
		"--out",
		tostring(outputPath),
	})
	fs.remove(jpegPath)
	if not converted.ok then
		error(`sips couldn't convert the capture to .{extension}: {converted.stderr}`)
	end
end

print(`Wrote {outputPath}`)
