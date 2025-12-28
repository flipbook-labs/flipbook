local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type SliderControl = types.SliderControl

local function createSliderControl(default: number?, range: NumberRange?, step: number?): SliderControl
	return {
		control = ControlType.Slider,
		default = default,
		range = range,
		step = step,
	}
end

return createSliderControl
