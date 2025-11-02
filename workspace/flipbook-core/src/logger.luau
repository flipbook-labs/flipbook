local Log = require("@pkg/Log")

local function stringToLogLevel(logLevel: string)
	if logLevel == "info" then
		return Log.LogLevel.Information
	elseif logLevel == "warn" or logLevel == "warning" then
		return Log.LogLevel.Warning
	elseif logLevel == "debug" then
		return Log.LogLevel.Debugging
	elseif logLevel == "err" or logLevel == "error" then
		return Log.LogLevel.Error
	end
	return Log.LogLevel.Information
end

local logger = Log.Logger.new({
	Log.LogEnricher.new(function(_event)
		return "flipbook", nil
	end),
	Log.Common.Enrichers.LogLevelEnricher(),
}, {
	Log.Common.RobloxLogSink(),
}, {
	Log.Common.Filters.MinLevelFilter(stringToLogLevel(_G.LOG_LEVEL) or Log.LogLevel.Warning),
})

return logger
