local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type ControlType = ControlType.ControlType
type StoryControlsSchema = types.StoryControlsSchema
type StoryControls = types.StoryControls

local function hydrateControls(schema: StoryControlsSchema, controls: StoryControls): StoryControls
	local hydrated: StoryControls = {}

	for controlName, controlSchema in schema do
		local controlValue = controls[controlName]
		local controlValueOrDefault = if controlValue then controlValue else controlSchema.default

		if controlSchema.control == ControlType.Number then
			assert(
				typeof(controlValueOrDefault) == "number",
				`failed to hydrate "{controlName}" (number expected, got "{typeof(controlValueOrDefault)})`
			)

			local range = controlSchema.range
			if range then
				assert(
					typeof(controlValueOrDefault) == "number"
						and controlValueOrDefault >= range.Min
						and controlValueOrDefault <= range.Max,
					`failed to hydrate "{controlName}" (default value "{controlValueOrDefault}" must be a number within the range [{range.Min}, {range.Max}])`
				)
			end
		end

		if
			controlSchema.control == ControlType.Check
			or controlSchema.control == ControlType.MultiSelect
			or controlSchema.control == ControlType.Select
			or controlSchema.control == ControlType.Radio
		then
			if controlSchema.default then
				assert(
					table.find(controlSchema.options, controlSchema.default),
					`failed to hydrate "{controlName}" (default value "{controlSchema.default}" not found in 'options')`
				)
			end

			local mapping = controlSchema.mapping
			if mapping then
				controlValueOrDefault = mapping[controlValueOrDefault]
			end

			if not controlValueOrDefault then
				controlValueOrDefault = {}
			end
		end

		if controlValueOrDefault ~= nil then
			hydrated[controlName] = controlValueOrDefault
		end
	end

	return hydrated
end

return hydrateControls
