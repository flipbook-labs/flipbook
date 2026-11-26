local Archivist = require("@lpm/archivist@v0.3.1")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

--[[
	This module creates the scripts' logger as soon as a script requires it, and
	Archivist reads `LOG_LEVEL` at that moment. Some scripts call `dotenv()`
	only after requiring this module, and others never call it. So this module
	loads `.env` first, and a `LOG_LEVEL` set there takes effect.
]]
FlipbookBatteries.dotenv()

return Archivist.createLogger("Flipbook")
