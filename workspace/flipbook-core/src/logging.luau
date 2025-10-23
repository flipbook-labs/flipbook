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
	Log.Common.Enrichers.LogLevelEnricher(),
}, {
	Log.Common.RobloxLogSink(),
}, {
	Log.Common.Filters.MinLevelFilter(stringToLogLevel(_G.LOG_LEVEL) or Log.LogLevel.Information),
})

local logging = {}

function logging.debug(...: any)
	logger:Debug(...)
end

function logging.info(...: any)
	logger:Info(...)
end

function logging.warn(...: any)
	logger:Warn(...)
end

function logging.err(...: any)
	logger:Error(...)
end

return logging
