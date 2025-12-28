local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type StoryControl = types.StoryControl

local function transformControlValue<T>(controlSchema: StoryControl, controlValue: Tunknown): unknown?
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

return transformControlValue
