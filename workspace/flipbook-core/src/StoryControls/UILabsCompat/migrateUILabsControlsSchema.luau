local UILabsTypes = require("@root/StoryControls/UILabsCompat/UILabsTypes")
local migrateUILabsControl = require("@root/StoryControls/UILabsCompat/migrateUILabsControl")
local migrateUILabsControlGroup = require("@root/StoryControls/UILabsCompat/migrateUILabsControlGroup")
local types = require("@root/StoryControls/types")

type UILabsControlsSchema = UILabsTypes.ControlsSchema
type StoryControlsSchema = types.StoryControlsSchema

local function migrateUILabsControlsSchema(schema: UILabsControlsSchema): StoryControlsSchema
	local newSchema: StoryControlsSchema = {}

	for key, value in schema do
		if value.EntryType == "Control" then
			local migrated = migrateUILabsControl(value)

			if migrated then
				newSchema[key] = migrated
			end
		elseif value.EntryType == "ControlGroup" then
			local migrated = migrateUILabsControlGroup(value)

			if migrated then
				for groupKey, groupValue in migrated do
					newSchema[groupKey] = groupValue
				end
			end
		end
	end

	return newSchema
end

return migrateUILabsControlsSchema
