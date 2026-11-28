local Archivist = require("@pkg/Archivist")
local Charm = require("@pkg/Charm")
local Sift = require("@pkg/Sift")

local function createLogsStore()
	local getHistory, setHistory = Charm.signal<<{ Archivist.LogRecord }>>({})

	local function addRecord(record: Archivist.LogRecord)
		setHistory(function(prev)
			return Sift.List.append(prev, record)
		end)
	end

	return {
		getHistory = getHistory,

		addRecord = addRecord,
	}
end

return createLogsStore
