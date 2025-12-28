local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type DateControl = types.DateControl
type Mapping = types.Mapping

local function createDateControl(default: DateTime?): DateControl
	return {
		control = ControlType.Date,
		default = default,
	}
end

return createDateControl
