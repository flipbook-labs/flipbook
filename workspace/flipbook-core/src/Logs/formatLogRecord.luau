local HttpService = game:GetService("HttpService")

local Archivist = require("@pkg/Archivist")

export type Colors = {
	muted: Color3,
	level: Color3,
}

local function stringify(value: unknown): string
	if typeof(value) == "table" then
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, value)
		if ok then
			return encoded
		end
	end
	return tostring(value)
end

--[[
	Renders a log record as one line of rich text for Help > Logs: the local
	time, the level in its color, and the logger's name, all muted, then each
	argument of the log call and any fields the record carries. Tables render as
	JSON, falling back to `tostring` when they can't be encoded.
]]
local function formatLogRecord(record: Archivist.LogRecord, colors: Colors): string
	local timestamp = DateTime.fromUnixTimestamp(record.timestamp):FormatLocalTime("YYYY-MM-DD hh:mm:ss A", "en-us")
	local level = `<font color="#{colors.level:ToHex()}">{record.level:lower()}</font>`
	local info = `<font color="#{colors.muted:ToHex()}">{timestamp} {level} {record.name}</font>`

	local parts = {}
	for index = 1, record.args.n do
		table.insert(parts, stringify(record.args[index]))
	end
	if record.fields then
		table.insert(parts, stringify(record.fields))
	end

	return `{info}: {table.concat(parts, " ")}`
end

return formatLogRecord
