--!strict
-- Captures a Flipbook story screenshot from a running Roblox Studio and writes
-- it to disk.
--
-- Connects directly to the StudioMCP WebSocket proxy endpoint at
-- ws://127.0.0.1:13469/proxy. The proxy protocol wraps MCP JSON-RPC in an outer
-- {"type":"json_rpc",...} envelope; control messages (proxy_hello, tools_updated)
-- use {"type":"control","control_type":"..."}. We wait for tools_updated before
-- sending the tool call so there are no arbitrary timing delays.
--
-- Usage: lute run .lute/tasks/capture-story.luau <output.png> [capture_id]

local fs = require("@std/fs")
local json = require("@std/json")
local netClient = require("@lute/net/client")
local process = require("@std/process")
local task = require("@std/task")

-- process.args[1] is the script path; user arguments start at index 2.
local outputPath = process.args[2]
local captureId = process.args[3] or "lute_capture"
if type(outputPath) ~= "string" or outputPath == "" then
	error("usage: lute run .lute/tasks/capture-story.luau <output.png> [capture_id]")
end

local function base64Decode(input: string): string
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local lookup: { [string]: number } = {}
	for i = 1, #chars do
		lookup[chars:sub(i, i)] = i - 1
	end
	local out = {}
	local bits, bitCount = 0, 0
	for i = 1, #input do
		local v = lookup[input:sub(i, i)]
		if v then
			bits = bits * 64 + v
			bitCount += 6
			if bitCount >= 8 then
				bitCount -= 8
				local divisor = 2 ^ bitCount
				table.insert(out, string.char(math.floor(bits / divisor) % 256))
				-- Mask off consumed bits to prevent double-precision overflow on large images.
				bits %= divisor
			end
		end
	end
	return table.concat(out)
end

local imageData: string? = nil
local errorText: string? = nil
local done = false
local wsError: string? = nil

local ws: any
ws = netClient.websocket("ws://127.0.0.1:13469/proxy", {
	onopen = function()
		ws:send(json.serialize({
			type = "control",
			control_type = "proxy_hello",
		}))
	end,
	onmessage = function(raw: string | buffer)
		local text = if type(raw) == "buffer" then buffer.tostring(raw) else raw
		local ok, decoded = pcall(json.deserialize, text)
		if not ok or type(decoded) ~= "table" then
			return
		end
		local d = decoded :: any
		if d.type == "control" and d.control_type == "tools_updated" then
			-- Server is ready; fire the tool call
			ws:send(json.serialize({
				type = "json_rpc",
				jsonrpc = "2.0",
				id = 1,
				method = "tools/call",
				params = {
					name = "screen_capture",
					arguments = { capture_id = captureId },
				},
			}))
		elseif d.type == "json_rpc" and d.id == 1 then
			local res = d.result
			if res and res.content then
				for _, c in res.content do
					if c.type == "image" and c.data then
						imageData = c.data
					elseif c.type == "text" and c.text then
						errorText = c.text
					end
				end
			end
			done = true
		end
	end,
	onclose = function(code: number, reason: string)
		if not done then
			wsError = string.format("WebSocket closed unexpectedly: %d %s", code, reason)
			done = true
		end
	end,
	onerror = function(err: string)
		wsError = "WebSocket error: " .. err
		done = true
	end,
})

print("Connecting to StudioMCP and requesting screen_capture...")

local timeout = 30
local elapsed = 0
while not done and elapsed < timeout do
	task.wait(0.1)
	elapsed += 0.1
end

ws:close()

if wsError then
	error(wsError)
end
if not done then
	error(string.format("Timed out after %ds waiting for screen_capture response", timeout))
end
if not imageData then
	error("No image returned. Server said: " .. (errorText or "<nothing>"))
end

local bytes = base64Decode(imageData :: string)

-- screen_capture returns JPEG bytes. Re-encode to the requested format via sips
-- if the output extension is not jpg.
local extension = (outputPath:match("%.([%a%d]+)$") or ""):lower()
if extension == "jpg" or extension == "jpeg" or extension == "" then
	fs.writeStringToFile(outputPath, bytes)
else
	local tempPath = "/tmp/.flipbook_capture_raw.jpg"
	fs.writeStringToFile(tempPath, bytes)
	local convert = process.system(
		string.format("sips -s format %s %s --out %s", extension, tempPath, outputPath)
	)
	fs.remove(tempPath)
	if not convert.ok then
		error("sips conversion to ." .. extension .. " failed:\n" .. convert.stderr)
	end
end

print(string.format("Wrote %s (%d bytes decoded)", outputPath, #bytes))
