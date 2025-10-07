local root = script.Parent.Parent

local getFFlagUGCValidatePreciseFloatEquals = require(root.flags.getFFlagUGCValidatePreciseFloatEquals)

local EPSILON = 1e-12

local function floatEquals(a: number, b: number, tolInput: number?): boolean
	if getFFlagUGCValidatePreciseFloatEquals() then
		local tolVal = if tolInput then tolInput else EPSILON
		return math.abs(a - b) <= tolVal
	else
		return math.abs(a - b) <= EPSILON
	end
end

return floatEquals
