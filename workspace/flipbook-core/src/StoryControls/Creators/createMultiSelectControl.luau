local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type MultiSelectControl = types.MultiSelectControl
type Mapping = types.Mapping

local function createMultiSelectControl<T>(options: { T }, mapping: Mapping?): MultiSelectControl
	return {
		control = ControlType.MultiSelect,
		options = options,
		mapping = mapping,
	}
end

return createMultiSelectControl
