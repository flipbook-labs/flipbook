local root = script.Parent.Parent

local Types = require(root.util.Types)
local getFIntUGCValidationMaxMsPerFrame = require(root.flags.getFIntUGCValidationMaxMsPerFrame)

local MAX_SECONDS_PER_FRAME = getFIntUGCValidationMaxMsPerFrame() / 1000

return function(validationContext: Types.ValidationContext)
	if validationContext.shouldYield then
		local elapsedSeconds = tick() - validationContext.lastTickSeconds :: number
		if elapsedSeconds >= MAX_SECONDS_PER_FRAME then
			task.wait()
			validationContext.lastTickSeconds = tick()
		end
	end
end
