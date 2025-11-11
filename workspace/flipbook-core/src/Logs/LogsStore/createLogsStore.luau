local Log = require("@pkg/Log")
local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")

type LogEvent = typeof(Log.LogEvent.new(Log.LogLevel.Information, {}, {}))

local function createLogsStore(_scope: Signals.scope)
	local getHistory, setHistory = Signals.createSignal({})

	local function addLine(event: LogEvent)
		setHistory(function(prev)
			return Sift.List.append(prev, event)
		end)
	end

	return {
		getHistory = getHistory,

		addLine = addLine,
	}
end

return createLogsStore
