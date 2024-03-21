local React = require("@pkg/React")

local ZOOM_INCREMENT = 0.25

local function useZoom(story: ModuleScript)
	local value, setValue = React.useState(0)

	local zoomIn = React.useCallback(function()
		setValue(value + ZOOM_INCREMENT)
	end, { value, setValue })

	local zoomOut = React.useCallback(function()
		setValue(value - ZOOM_INCREMENT)
	end, { value, setValue })

	React.useEffect(function()
		setValue(0)
	end, { story })

	return {
		value = value,
		zoomIn = zoomIn,
		zoomOut = zoomOut,
	}
end

return useZoom
