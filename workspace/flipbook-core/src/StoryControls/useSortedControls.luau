local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Array = Sift.Array
local Dictionary = Sift.Dictionary

local useMemo = React.useMemo

export type Control = {
	key: string,
	value: any,
}

local function filterControls(controlA: Control, controlB: Control)
	return controlA.key < controlB.key
end

local function useSortedControls(controls: { [string]: any }): { Control }
	return useMemo(function()
		return Array.sort(
			Array.map(Dictionary.entries(controls), function(entry)
				return { key = entry[1], value = entry[2] }
			end),
			filterControls
		)
	end, { controls })
end

return useSortedControls
