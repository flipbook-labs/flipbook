local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type CheckControl<T> = types.CheckControl<T>
type Mapping = types.Mapping

local function createCheckControl<T>(options: { T }, default: T?, mapping: Mapping?): CheckControl<T>
	return {
		control = ControlType.Check,
		options = options,
		default = default,
		mapping = mapping,
	}
end

return createCheckControl
