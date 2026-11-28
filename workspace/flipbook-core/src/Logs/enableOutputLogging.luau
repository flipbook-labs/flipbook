local logger = require("@root/logger")
local outputSink = require("@root/Logs/outputSink")

--[[
	Turns on Studio Output for Flipbook's logger. The plugin writes to Output
	only in builds that set `ENABLE_OUTPUT_LOGGING`, but embedded Flipbook runs
	in a playtest or an experience, where Output is the place to read its logs.
	So the embedded starter scripts call this before they log anything.

	The sink is removed before it's added, so calling this twice, or in a build
	that already writes to Output, doesn't print every line twice.
]]
local function enableOutputLogging()
	logger.removeSink(outputSink)
	logger.addSink(outputSink)
end

return enableOutputLogging
