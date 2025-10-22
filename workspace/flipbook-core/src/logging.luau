local Log = require("@pkg/Log")

local function stringToLogLevel(_logLevel: string)
	return Log.LogLevel.Information
end

local logger = Log.Logger.new({
	Log.Common.Enrichers.LogLevelEnricher(),
}, {
	Log.Common.RobloxLogSink(),
}, {
	Log.Common.Filters.MinLevelFilter(stringToLogLevel(_G.LOG_LEVEL or "info")),
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
