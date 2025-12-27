local UILabsTypes = require("@root/StoryControls/UILabsCompat/UILabsTypes")
local migrateUILabsControl = require("@root/StoryControls/UILabsCompat/migrateUILabsControl")
local types = require("@root/StoryControls/types")

type ControlGroup = UILabsTypes.ControlGroup

local function migrateUILabsControlGroup(controlGroup: ControlGroup): types.StoryControlsSchema?
	local controls: types.StoryControlsSchema = {}

	local hasControls = false

	for key, control in controlGroup.Controls do
		hasControls = true

		local migrated = migrateUILabsControl(control)

		if migrated then
			controls[key] = migrated
		end
	end

	if not hasControls then
		return nil
	end

	return controls
end

return migrateUILabsControlGroup
