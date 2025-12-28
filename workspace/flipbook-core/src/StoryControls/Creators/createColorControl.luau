local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type ColorControl = types.ColorControl
type Mapping = types.Mapping

local function createColorControl(default: Color3?): ColorControl
	return {
		control = ControlType.Color,
		default = default,
	}
end

return createColorControl
