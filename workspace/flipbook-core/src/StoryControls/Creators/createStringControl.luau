local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type StringControl = types.StringControl

local function createStringControl(default: string?, placeholder: string?): StringControl
	return {
		control = ControlType.String,
		default = default,
		placeholder = placeholder,
	}
end

return createStringControl
