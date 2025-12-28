local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type ControlType = ControlType.ControlType
type StoryControlsSchema = types.StoryControlsSchema
type StoryControls = types.StoryControls
type StoryControl = types.StoryControl
type ListBasedStoryControl = types.ListBasedStoryControl

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

local function validateControlValueMapping(
	controlName: string,
	controlSchema: ListBasedStoryControl,
	controlValue: unknown?
)
	if controlSchema.mapping then
		local mappedControlValue = if controlSchema.mapping then controlSchema.mapping[controlValue] else nil

		assert(
			mappedControlValue,
			`failed to hydrate "{controlName}" (could not map control value "{controlValue}" to one of the values in 'mapping')`
		)

		for _, choice in controlValue :: { [any]: any } do
			validateControlValueMapping(controlName, controlSchema, choice)
		end

		if mappedControlValue then
			assert(
				table.find(controlSchema.options, mappedControlValue),
				`failed to hydrate "{controlName}" (could not map control value "{controlValue}" to one of the values in 'options')`
			)
		end
	else
		assert(
			table.find(controlSchema.options, controlValue),
			`failed to hydrate "{controlName}" (expected control value "{controlValue}" to be included in 'options')`
		)
	end
end

local function validateListControlValue(
	controlName: string,
	controlSchema: ListBasedStoryControl,
	controlValue: unknown?
)
	local options = {}

	if typeof(controlValue) == "table" then
		for _, value in controlValue :: { [any]: any } do
			table.insert(options, value)
		end
	else
		table.insert(options, controlValue)
	end

	for _, optionValue in options do
		if controlSchema.mapping then
			local mappedOptionValue = if controlSchema.mapping then controlSchema.mapping[optionValue] else nil

			assert(
				mappedOptionValue,
				`failed to hydrate "{controlName}" (could not map "{optionValue}" to one of the values in 'mapping')`
			)

			assert(
				table.find(controlSchema.options, mappedOptionValue),
				`failed to hydrate "{controlName}" (could not map "{mappedOptionValue}" to one of the values in 'options')`
			)
		else
			assert(
				table.find(controlSchema.options, optionValue),
				`failed to hydrate "{controlName}" (expected control value "{optionValue}" to be included in 'options')`
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

		if table.find(controlSchema.options, controlValueOrDefault) then
			return controlValueOrDefault
		end
	end

	return controlValueOrDefault
end

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

		controlValue = transformControlValue(controlSchema, controls[controlName])

		if controlValue ~= nil then
			hydrated[controlName] = controlValue
		end
	end

	return hydrated
end

return hydrateControls
