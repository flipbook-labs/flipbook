local Charm = require("@pkg/Charm")
local Log = require("@pkg/Log")
local Sift = require("@pkg/Sift")

type LogEvent = typeof(Log.LogEvent.new(Log.LogLevel.Information, {}, {}))

local function createLogsStore()
	local getHistory, setHistory = Charm.signal({})

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
