local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type SelectControl = types.SelectControl
type Mapping = types.Mapping

local function createSelectControl<T>(options: { T }, mapping: Mapping?): SelectControl
	return {
		control = ControlType.Select,
		options = options,
		mapping = mapping,
	}
end

return createSelectControl
