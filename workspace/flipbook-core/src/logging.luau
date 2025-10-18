local Log = require("@pkg/Log")

local logger = Log.Logger.new({
	Log.Enrichers.TimestampEnricher(true, true),
	Log.Enrichers.DynSourceEnricher(true),
	Log.Enrichers.LogLevelEnricher(),
	Log.Enrichers.TraceEnricher(),
}, {
	Log.RobloxLogSink(),
})

local logging = {}

function logging.debug(...: any)
	logger:Debug(...)
end
function logging.info(...: any)
	logger:Info(...)
end
function logging.warn(...: any)
	logger:Warning(...)
end
function logging.err(...: any)
	logger:Err(...)
end

return logging
