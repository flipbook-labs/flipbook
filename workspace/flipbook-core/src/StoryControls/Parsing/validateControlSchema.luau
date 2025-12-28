local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type StoryControl = types.StoryControl

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

return validateControlSchema
