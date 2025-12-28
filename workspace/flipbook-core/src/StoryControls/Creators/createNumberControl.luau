local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type NumberControl = types.NumberControl

local function createNumberControl(default: number?, range: NumberRange?, step: number?): NumberControl
	if default and range then
		assert(default >= range.Min and default <= range.Max, "default value must be within the range")
	end

	return {
		control = ControlType.Number,
		default = default,
		range = range,
		step = step,
	}
end

return createNumberControl
