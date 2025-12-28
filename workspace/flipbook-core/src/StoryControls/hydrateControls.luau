local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type ControlType = ControlType.ControlType
type StoryControlsSchema = types.StoryControlsSchema
type StoryControls = types.StoryControls
type StoryControl = types.StoryControl

--[[
	As a principle:
	1. Throw when there's an issue with the schema
	2. Constrain when there's an issue with a control

	For example, if a Number control's schema defined the default value as out
	of range then that should cause an error. But if a user supplies a value out
	of range, we constrain the value that gets passed off to the story to make
	sure its within the range.
]]

local function validateControlSchema(controlName: string, controlSchema: StoryControl)
	local defaultValue = controlSchema.default

	if defaultValue then
		if controlSchema.control == ControlType.Number or controlSchema.control == ControlType.Slider then
			assert(
				typeof(defaultValue) == "number",
				`failed to hydrate "{controlName}" (number expected for default value, got "{typeof(defaultValue)})`
			)

			local range = controlSchema.range
			if range then
				assert(
					typeof(defaultValue) == "number" and defaultValue >= range.Min and defaultValue <= range.Max,
					`failed to hydrate "{controlName}" (default value "{defaultValue}" must be a number within the range [{range.Min}, {range.Max}])`
				)
			end
		end

		if controlSchema.control == ControlType.Check or controlSchema.control == ControlType.MultiSelect then
			assert(
				typeof(defaultValue) == "table",
				`failed to hydrate "{controlName}" (array expected for default value, got "{typeof(defaultValue)}")`
			)

			for _, option in defaultValue :: { [any]: any } do
				assert(
					table.find(controlSchema.options, option),
					`failed to hydrate "{controlName}" (value "{option}" not found in 'options')`
				)
			end
		end

		if controlSchema.control == ControlType.Radio or controlSchema.control == ControlType.Select then
			assert(
				table.find(controlSchema.options, defaultValue),
				`failed to hydrate "{controlName}" (value "{defaultValue}" not found in 'options')`
			)
		end
	end
end

local function transformControlValue(controlSchema: StoryControl, controlValue: unknown?): unknown?
	local controlValueOrDefault = if controlValue then controlValue else controlSchema.default

	if controlSchema.control == ControlType.Number or controlSchema.control == ControlType.Slider then
		if typeof(controlValueOrDefault) == "number" then
			local range = controlSchema.range

			if range then
				return math.clamp(controlValueOrDefault, range.Min, range.Max)
			end
		end
	end

	if controlSchema.control == ControlType.Check or controlSchema.control == ControlType.MultiSelect then
		if typeof(controlValueOrDefault) == "table" then
			local result = {}
			local mapping = controlSchema.mapping

			for _, option in controlValueOrDefault :: { [any]: any } do
				if mapping then
					table.insert(result, mapping[option])
				else
					table.insert(result, option)
				end
			end
			return result
		end
	end

	if controlSchema.control == ControlType.Radio or controlSchema.control == ControlType.Select then
		local mapping = controlSchema.mapping

		if mapping then
			local mappedControlValue = mapping[controlValueOrDefault]
			if mappedControlValue then
				return mappedControlValue
			end
		end

		return controlSchema.options[1]
	end

	return controlValueOrDefault
end

local function hydrateControls(schema: StoryControlsSchema, controls: StoryControls): StoryControls
	local hydrated: StoryControls = {}

	for controlName, controlSchema in schema do
		validateControlSchema(controlName, controlSchema)

		local controlValue = transformControlValue(controlSchema, controls[controlName])

		if controlValue ~= nil then
			hydrated[controlName] = controlValue
		end
	end

	return hydrated
end

return hydrateControls
