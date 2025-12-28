local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type RadioControl = types.RadioControl

local function createRadioControl<T>(options: { T }): RadioControl
	return {
		control = ControlType.Radio,
		options = options,
	}
end

return createRadioControl
