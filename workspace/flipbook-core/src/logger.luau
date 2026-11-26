local Archivist = require("@pkg/Archivist")

local LogsStore = require("@root/Logs/LogsStore")

--[[
	`_G.LOG_LEVEL` and `_G.ENABLE_OUTPUT_LOGGING` are build globals. The build
	replaces each read of them in Flipbook's own source with the value from
	`.env`, but it leaves packages alone, and nothing sets them at runtime. So
	Archivist's own read of `_G.LOG_LEVEL` would find nil. Instead, the level is
	looked up here and passed to Archivist. A missing or unrecognized level falls
	back to "Warn".
]]
local LOG_LEVELS: { [string]: Archivist.LogLevel } = {
	trace = "Trace",
	debug = "Debug",
	info = "Info",
	warn = "Warn",
	warning = "Warn",
	err = "Err",
}

local sinks: { Archivist.Sink } = {
	Archivist.createCallbackSink(function(record)
		LogsStore.get().addRecord(record)
	end),
}

if _G.ENABLE_OUTPUT_LOGGING == "true" then
	table.insert(
		sinks,
		Archivist.createConsoleSink({
			formatter = Archivist.createPrettyFormatter({
				middleware = {
					Archivist.middleware.name,
				},
			}),
		})
	)
end

return Archivist.createLogger("Flipbook", {
	level = LOG_LEVELS[_G.LOG_LEVEL] or "Warn",
	sinks = sinks,
})
