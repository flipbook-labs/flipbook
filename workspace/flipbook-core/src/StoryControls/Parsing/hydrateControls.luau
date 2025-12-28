local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type StoryControlsSchema = types.StoryControlsSchema
type StoryControls = types.StoryControls

local transformControlValue = require("@root/StoryControls/Parsing/transformControlValue")
local validateControlSchema = require("@root/StoryControls/Parsing/validateControlSchema")
local validateListControlValue = require("@root/StoryControls/Parsing/validateListControlValue")

--[[
	As a principle:
	1. Throw when there's an issue with the schema
	2. Constrain when there's an issue with a control

	For example, if a Number control's schema defined the default value as out
	of range then that should cause an error. But if a user supplies a value out
	of range, we constrain the value that gets passed off to the story to make
	sure its within the range.
]]

local function hydrateControls(schema: StoryControlsSchema, controls: StoryControls): StoryControls
	local hydrated: StoryControls = {}

	for controlName, controlSchema in schema do
		local controlValue = controls[controlName]

		validateControlSchema(controlName, controlSchema)

		if
			controlSchema.control == ControlType.Check
			or controlSchema.control == ControlType.MultiSelect
			or controlSchema.control == ControlType.Radio
			or controlSchema.control == ControlType.Select
		then
			validateListControlValue(controlName, controlSchema, controlValue)
		end

		controlValue = transformControlValue(controlSchema, controlValue)

		if controlValue ~= nil then
			hydrated[controlName] = controlValue
		end
	end

	return hydrated
end

return hydrateControls
