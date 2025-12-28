local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type BooleanControl = types.BooleanControl

local function createBooleanControl(default: boolean): BooleanControl
	return {
		control = ControlType.Boolean,
		default = default,
	}
end

return createBooleanControl
