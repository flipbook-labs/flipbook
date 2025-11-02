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
	return Log.LogLevel.Warning
end

local logger = Log.Logger.new({
	Log.LogEnricher.new(function(_event)
		return "flipbook", nil
	end),
	Log.Common.Enrichers.LogLevelEnricher(),
	Log.Common.Enrichers.DynSourceEnricher(true),
}, {
	Log.Common.RobloxLogSink(),
}, {
	Log.Common.Filters.MinLevelFilter(stringToLogLevel(_G.LOG_LEVEL)),
})

return logger
