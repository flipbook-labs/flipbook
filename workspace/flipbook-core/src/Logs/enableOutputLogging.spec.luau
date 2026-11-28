local Archivist = require("@pkg/Archivist")
local JestGlobals = require("@pkg/JestGlobals")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

-- Required in beforeEach, after the Output sink is mocked.
local enableOutputLogging: typeof(require("./enableOutputLogging"))
local logger: typeof(require("@root/logger"))

local outputRecords: { Archivist.LogRecord }

beforeEach(function()
	jest.resetModules()
	outputRecords = {}

	jest.mock(script.Parent.outputSink, function()
		return Archivist.createCallbackSink(function(record)
			table.insert(outputRecords, record)
		end)
	end)

	enableOutputLogging = require("./enableOutputLogging")
	logger = require("@root/logger")

	-- The logger's level and sinks come from the build's `.env`, so each test
	-- starts from a known state: every level logged, and nothing in Output.
	logger.setLevel("Trace")
	logger.removeSink(require("./outputSink"))
end)

test("send the logger's records to Output once enabled", function()
	logger.warn("before")
	enableOutputLogging()
	logger.warn("after")

	expect(#outputRecords).toBe(1)
	expect(outputRecords[1].args[1]).toBe("after")
end)

test("write each record once when enabled twice", function()
	enableOutputLogging()
	enableOutputLogging()
	logger.warn("hello")

	expect(#outputRecords).toBe(1)
end)
