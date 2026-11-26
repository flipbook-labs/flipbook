local Archivist = require("@pkg/Archivist")
local JestGlobals = require("@pkg/JestGlobals")

local formatLogRecord = require("./formatLogRecord")

local expect = JestGlobals.expect
local test = JestGlobals.test

local TIMESTAMP = 1795731202

local COLORS: formatLogRecord.Colors = {
	muted = Color3.fromRGB(128, 128, 128),
	level = Color3.fromRGB(0, 255, 0),
}

local function createRecord(level: Archivist.LogLevel, ...: unknown): Archivist.LogRecord
	return {
		timestamp = TIMESTAMP,
		level = level,
		name = "Flipbook",
		args = table.pack(...),
	}
end

test("show the time, level, and logger name before the message", function()
	local timestamp = DateTime.fromUnixTimestamp(TIMESTAMP):FormatLocalTime("YYYY-MM-DD hh:mm:ss A", "en-us")

	local line = formatLogRecord(createRecord("Info", "mounted app"), COLORS)

	expect(line).toBe(
		`<font color="#808080">{timestamp} <font color="#00ff00">info</font> Flipbook</font>: mounted app`
	)
end)

test("join every argument, including nil", function()
	local line = formatLogRecord(createRecord("Warn", "read", nil, 3), COLORS)

	expect(line:match(": (.*)$")).toBe("read nil 3")
end)

test("render tables and fields as JSON", function()
	local record = createRecord("Debug", "settings:", { ready = true })
	local fields: { [string]: unknown } = {
		requestId = "abc",
	}
	record.fields = fields

	local line = formatLogRecord(record, COLORS)

	expect(line:match(": (.*)$")).toBe('settings: {"ready":true} {"requestId":"abc"}')
end)

test("fall back to tostring for a table JSON can't encode", function()
	local unencodable: { [string]: unknown } = {}
	unencodable.self = unencodable

	local line = formatLogRecord(createRecord("Err", unencodable), COLORS)

	expect(line:match(": (.*)$")).toBe(tostring(unencodable))
end)
